require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  before(:each) do
    @user = assign(:user, FactoryBot.create(:user, name: 'Alina'))
        
    render
  end
  
  context 'User signed in' do
    before(:each) do
      sign_in(@user) 

      render
    end

    it 'renders user name' do
      expect(rendered).to match 'Alina'
    end

    it 'renders change name&password button' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'renders game fragment' do        
      assign(:games, [FactoryBot.build_stubbed(:game)])
  
      stub_template 'users/_game.html.erb' => 'Game goes here'
  
      render
  
      expect(rendered).to have_content 'Game goes here'            
    end
  end

  context 'Anonymous user' do
    it 'does not render change name&password button' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end
