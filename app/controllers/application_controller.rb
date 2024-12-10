# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pagy::Backend
  after_action { pagy_headers_merge(@pagy) if @pagy }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    head :not_found
  end
end
