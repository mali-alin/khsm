module MySpecHelper
  # Наш хелпер, для населения базы нужным количеством рандомных вопросов
  def generate_questions(number)
    number.times do
      create(:question)
    end
  end
end

RSpec.configure do |c|
  c.include MySpecHelper
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
