# frozen_string_literal: true

class RecommendationAI
  include HTTParty

  CACHE_TTL = 1.hour

  base_uri 'https://bravado-images-production.s3.amazonaws.com'
  default_timeout 1

  def initialize(user_id)
    @user_id = user_id
  end

  # Returns an array of recommended cars for a given user.
  # @example
  #   RecommendationAIService.new(1).call
  #   # => [{ "car_id" => 179, "rank_score" => 0.945 }, { "car_id" => 5, "rank_score" => 0.4552 }]
  # @return [Array<Hash>]
  def call
    Rails.cache.fetch([self.class.name, @user_id], expires: CACHE_TTL) do
      self.class.get(
        '/recomended_cars.json',
        query: { user_id: @user_id }
      ).parsed_response
    end
  rescue StandardError => e
    Rails.logger.error("RecommendationAIService Error: #{e.message}")
    []
  end
end
