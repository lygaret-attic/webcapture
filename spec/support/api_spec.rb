# explicitly included, shared context generation, etc.
module APISpec
  extend ActiveSupport::Concern

  class_methods do
    # manage a suite wide model object
    # calls #reload and #delete!, so it should really be an ActiveRecord object
    def let_suite_model(sym, &block)
      fail ArgumentError, "Must include creation block!" unless block_given?

      before(:all) {
        value = instance_eval(&block)
        instance_variable_set("@#{sym}", value)
      }

      before(:each) {
        value = instance_variable_get("@#{sym}")
        value.reload if value.present?
      }

      after(:all) {
        value = instance_variable_get("@#{sym}")
        value.delete
      }
    end
  end
end
