require 'rails_helper'

RSpec.describe GamesController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

  let(:admin) { FactoryGirl.create(:user, is_admin: true) } 

  let(:game_w_questions) { FactoryGirl.create(:game_with_questions, user: user) }

  context 'Anon' do
    it 'kick from #show' do
      get :show, id: game_w_questions.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #create' do
      post :create

      game = assigns(:game)

      expect(game).to be_nil
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #answer' do
      put :answer, id: game_w_questions.id
      
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
    
    it 'kick from #take_money' do
      put :take_money, id: game_w_questions.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

  context 'Usual user' do
    before(:each) do
      sign_in user
    end
    
    it 'creates game' do
      generate_questions(60)

      post :create

      game = assigns(:game)

      #check game status
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response).to redirect_to game_path(game)
      expect(flash[:notice]).to be
    end

    #user see his game
    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game) 
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response.status).to eq(200)
      expect(response).to render_template('show')
    end

    it '#show alien game' do
      alien_game = FactoryGirl.create(:game_with_questions)

      get :show, id: alien_game.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be
    end

    it 'answers correctly' do
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy
    end

    it 'takes money before the end of the game' do
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, id: game_w_questions.id
      game = assigns(:game)

      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(200)

      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    it 'try to create second game' do
      expect(game_w_questions.finished?).to be_falsey

      post :create
      
      game = assigns(:game)

      expect(game).to be_nil
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end
    
    it 'answers wrong' do
      wrong_answers = %w[a b c]

      put :answer, id: game_w_questions.id, letter: wrong_answers.sample

      game = assigns(:game)

      expect(game.status).to eq(:fail)
      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(0)
      expect(flash[:alert]).to be
      expect(response).to redirect_to(user_path(user))
    end
  end
end
