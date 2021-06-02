require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }

  let(:admin) { create(:user, is_admin: true) } 

  let(:game_w_questions) { create(:game_with_questions, user: user) }

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
      expect(game.finished?).to be false
      expect(game.user).to eq(user)

      expect(response).to redirect_to game_path(game)
      expect(flash[:notice]).to be
    end

    #user see his game
    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game) 
      expect(game.finished?).to be false
      expect(game.user).to eq(user)

      expect(response.status).to eq(200)
      expect(response).to render_template('show')
    end

    it '#show alien game' do
      alien_game = create(:game_with_questions)

      get :show, id: alien_game.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be
    end

    it 'answers correctly' do
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be true
    end

    it 'takes money before the end of the game' do
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, id: game_w_questions.id
      game = assigns(:game)

      expect(game.finished?).to be true
      expect(game.prize).to eq(200)

      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    it 'try to create second game' do
      expect(game_w_questions.finished?).to be false

      post :create
      
      game = assigns(:game)

      expect(game).to be_nil
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end
    
    it 'answers wrong' do
      answers = %w[a b c d]
      
      random_wrong_answer = (answers.reject { |answer| answer == 'd' }).sample

      put :answer, id: game_w_questions.id, letter: random_wrong_answer

      game = assigns(:game)

      expect(game.status).to eq(:fail)
      expect(game.finished?).to be true
      expect(game.prize).to eq(0)
      expect(flash[:alert]).to be
      expect(response).to redirect_to(user_path(user))
    end

    it 'uses audience help' do
      # Проверяем, что у текущего вопроса нет подсказок
      expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      # И подсказка не использована
      expect(game_w_questions.audience_help_used).to be false
    
      # Пишем запрос в контроллер с нужным типом (put — не создаёт новых сущностей, но что-то меняет)
      put :help, id: game_w_questions.id, help_type: :audience_help
      game = assigns(:game)
    
      # Проверяем, что игра не закончилась, что флажок установился, и подсказка записалась
      expect(game.finished?).to be false
      expect(game.audience_help_used).to be true
      expect(game.current_game_question.help_hash[:audience_help]).to be
      expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      expect(response).to redirect_to(game_path(game))
    end
  end
end
