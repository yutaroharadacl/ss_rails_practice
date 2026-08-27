# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health', type: :request do
  it 'boots the app' do
    expect(Rails.application).to be_present
  end
end
