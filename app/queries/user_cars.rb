# frozen_string_literal: true

class UserCars
  def initialize(user, scope: Car)
    @user = user
    @scope = scope
  end

  def call(filters = {})
    subquery = add_rank_scores(add_labels(Car))

    scope = @scope
              .includes(:brand)
              .select('cars.id, cars.model, cars.price, cars.rank_score, cars.label, cars.brand_id')
              .from(subquery, :cars)

    apply_sort(apply_filters(scope, filters))
  end

  private

  # Generate car-to-user matching labels
  def add_labels(scope)
    preferred_brands = @user.preferred_brand_ids.join(', ')
    scope.select(
      "cars.*,
       (CASE
            WHEN cars.brand_id IN (#{preferred_brands})
                AND cars.price BETWEEN #{@user.preferred_price_range.min}
                AND #{@user.preferred_price_range.max} THEN 'perfect_match'
            WHEN cars.brand_id IN (#{preferred_brands}) THEN 'good_match'
       END) AS label"
    )
  end

  # Merge cars with rank score from AI service
  def add_rank_scores(scope)
    scope.select('NULL::float AS rank_score'); return if recommended_cars.empty?

    rank_scores = recommended_cars
                    .map { |r| "(#{r['car_id']}, #{r['rank_score']})" }
                    .join(', ')
    scope
      .joins("LEFT JOIN (VALUES #{rank_scores}) AS car_scores (car_id, rank_score) ON cars.id = car_scores.car_id")
      .select('car_scores.rank_score::float AS rank_score')
  end

  def apply_filters(scope, filters)
    scope.tap do |s|
      s.joins!(:brand).where!('brands.name ILIKE ?', "%#{filters[:query]}%") if filters[:query].present?
      s.where!('cars.price >= ?', filters[:price_min]) if filters[:price_min].present?
      s.where!('cars.price <= ?', filters[:price_max]) if filters[:price_max].present?
    end
  end

  # Order cars by label, rank score, and price
  def apply_sort(scope)
    label = Arel.sql("CASE
                                WHEN cars.label = 'perfect_match' THEN 0
                                WHEN cars.label = 'good_match' THEN 1
                                ELSE 2
                              END")
    scope.order(label, 'cars.rank_score DESC NULLS LAST', :price)
  end

  def recommended_cars
    @recommended_cars ||= RecommendationAI.new(@user.id).call
  end
end
