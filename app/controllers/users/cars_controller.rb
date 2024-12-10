# frozen_string_literal: true

module Users
  class CarsController < ApplicationController
    before_action :set_user

    def index
      @pagy, @cars = pagy(
        UserCars.new(@user).call(query_params)
      )
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def query_params
      params.permit(:query, :price_min, :price_max)
    end
  end
end
