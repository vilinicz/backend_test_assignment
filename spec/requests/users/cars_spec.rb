# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Cars', type: :request do
  let(:user_id) { 1 }
  let(:ai_recommendations) { JSON.parse(File.read('spec/services/recommendation_ai_ref.json')) }
  let(:reference_response) { JSON.parse(File.read('spec/requests/users/user_cars_ref.json')) }

  before do
    allow_any_instance_of(RecommendationAI)
      .to receive(:call).and_return(ai_recommendations)
  end

  describe 'GET /index' do
    it 'matches required reference' do
      get "/users/#{user_id}/cars"
      expect(response.parsed_body).to eq(reference_response)
    end

    it 'filters by car brand name' do
      get "/users/#{user_id}/cars", params: { query: 'Volkswagen' }
      expect(
        response.parsed_body['data'].all? { |car| car['brand']['name'].eql? 'Volkswagen' }
      ).to eq(true)
    end
  end

  path '/users/{user_id}/cars' do
    get 'Retrieves a list of cars for a user' do
      tags 'Cars'
      produces 'application/json'
      parameter name: :user_id,
                in: :path, type: :integer, description: 'User ID'
      parameter name: :query,
                in: :query, type: :string, required: false,
                description: 'Car brand name or part of car brand name'
      parameter name: :price_min,
                in: :query, type: :number, required: false,
                description: 'Minimum car price'
      parameter name: :price_max,
                in: :query, type: :number, required: false,
                description: 'Maximum car price'

      response '200', 'cars found' do
        let(:user_id) { 1 }

        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       brand: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string }
                         }
                       },
                       model: { type: :string },
                       price: { type: :number },
                       rank_score: { type: :number, nullable: true },
                       label: { type: :string, nullable: true, enum: %w[perfect_match good_match] }
                     },
                     required: %w[id model price brand rank_score label]
                   }
                 }
               }

        run_test!
      end

      response '404', 'user not found' do
        let(:user_id) { 'invalid' }
        run_test!
      end
    end
  end
end
