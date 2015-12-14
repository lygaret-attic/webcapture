FactoryGirl.define do
  factory :user do
    email    { Forgery::Email.address }
    password { Forgery::Basic.password }

    factory :user_with_stuff do
      transient do
        count 3
      end

      after(:create) do |user, evaluator|
        create_list(:capture, evaluator.count, user: user)
        create_list(:template, evaluator.count, user: user)
      end
    end
  end

  factory :capture do
    association :user, factory: :user
    key { Forgery::Basic.encrypt[0, 32] }
    content { Forgery::LoremIpsum.words(15) }
  end

  factory :template do
    association :user, factory: :user
    key { Forgery::Basic.encrypt[0, 32] }

    template "* TODO %?"
    properties ({ slug: "[T]odo", description: "A todo item, obviously.", auto_refile: "blah" }.to_json)
  end
end
