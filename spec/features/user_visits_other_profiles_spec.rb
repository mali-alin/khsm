require 'rails_helper'

RSpec.feature 'User visits other profiles', type: :feature do
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  let!(:games) { 
    [
     FactoryBot.create(:game, user: user1, finished_at: '08.06.2021 16:10:00', created_at: '08.06.2021 15:50:10', current_level: 4, prize: 0),
     FactoryBot.create(:game, user: user1, finished_at: '07.06.2021 16:56:00', created_at: '07.06.2021 16:30:10', current_level: 2, prize: 0)
    ]
    }

  before(:each) do
    login_as user2
  end

  scenario 'success' do
    visit "/users/#{user1.id}"

    expect(page).not_to have_content('Сменить имя и пароль')
    expect(page).to have_content("#{user1.name}")
    expect(page).to have_content('деньги')
    expect(page).to have_content('08 июня, 15:50')
    expect(page).to have_content('07 июня, 16:30')
    expect(page).to have_content('0 ₽')
    expect(page).to have_content('50/50')

    save_and_open_page
  end
end
