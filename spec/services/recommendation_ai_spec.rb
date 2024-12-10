# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecommendationAI, type: :service do
  let(:user_id) { 1 }
  let(:service) { described_class.new(user_id) }
  let(:response_body) { [
    { 'car_id' => 179, 'rank_score' => 0.945 },
    { 'car_id' => 5, 'rank_score' => 0.4552 }
  ] }

  before do
    allow(Rails.cache).to receive(:fetch).and_call_original
    stub_request(:get, 'https://bravado-images-production.s3.amazonaws.com/recomended_cars.json')
      .with(query: { user_id: user_id })
      .to_return(
        status: 200,
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe '#call' do
    it 'returns an array of recommended cars' do
      result = service.call
      expect(result).to eq(response_body)
    end

    it 'caches the response' do
      service.call
      expect(Rails.cache).to have_received(:fetch).with(
        [described_class.name, user_id], expires: 1.hour
      )
    end

    context 'when an error occurs' do
      before do
        allow(service.class).to receive(:get).and_raise(StandardError.new('error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'returns an empty array and logs the error' do
        result = service.call
        expect(result).to eq([])
        expect(Rails.logger).to have_received(:error).with('RecommendationAIService Error: error')
      end
    end
  end
end
