require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do 
    assign(:users, [
      FactoryBot.build_stubbed(:user, name: 'Алина', balance: 5000),
      FactoryBot.build_stubbed(:user, name: 'Вася', balance: 4000)
    ])
  
    render
  end

  it 'render player names' do 
    expect(rendered).to match 'Алина'
    expect(rendered).to match 'Вася'
  end

  it 'renders player balance' do
    expect(rendered).to match '5 000 ₽'
    expect(rendered).to match '4 000 ₽'
  end

  it 'renders player names in right order' do
    expect(rendered).to match /Алина.*Вася/m
  end
end
