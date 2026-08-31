# frozen_string_literal: true

module Api
  module V1
    class HealthController < BaseController
      def index
        render json: { status: 'ok', version: 'v1' }
      end
    end
  end
end
