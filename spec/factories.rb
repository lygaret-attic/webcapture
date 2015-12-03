FactoryGirl.define do
  factory :user do
    email    { Forgery::Email.address }
    password { Forgery::Basic.password }

    factory :user_with_captures do
      transient do
        count 3
      end

      after(:create) do |user, evaluator|
        create_list(:capture, evaluator.count, user: user)
      end
    end
  end

  factory :capture do
    association :user, factory: :user
    content { Forgery::LoremIpsum.words(15) }
  end
end
