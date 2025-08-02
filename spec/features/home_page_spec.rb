# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home Page', type: :feature, js: true do
  scenario 'displays the welcome message' do
    visit '/en'
    expect(page).to have_content('Better Together')
  end
end
