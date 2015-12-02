FactoryGirl.define do

  factory :user do
    email    { Forgery::Email.address }
    password { Forgery::Basic.password }
  end

  factory :capture do
    user
    content { Forgery::LoremIpsum.words(15) }
  end

end
