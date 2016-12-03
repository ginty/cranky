require 'spec_helper'

describe 'Factory.lint' do
  it 'raises when a factory is invalid' do
    error_message = <<-ERROR_MESSAGE.strip
The following factories are invalid:

* invalid_user - Validation failed: {:required_attr=>["can't be blank"]} (RuntimeError)
* user_hash - undefined method `save!' for [:name, "Fred"]:Array (NoMethodError)

The following callbacks are invalid:

after_create_not_existing_factory
    ERROR_MESSAGE

    expect do
      Factory.lint!
    end.to raise_error Cranky::Linter::InvalidFactoryError, error_message
  end

  it 'does not raise when all factories are valid' do
    error_message = <<-ERROR_MESSAGE.strip
The following callbacks are invalid:

after_create_not_existing_factory
        ERROR_MESSAGE
    expect do
      Factory.lint!(factory_names: [:admin_manually, :address])
    end.to raise_error Cranky::Linter::InvalidFactoryError, error_message
  end

  describe "trait validation" do
    context "enabled" do
      it "raises if a trait produces an invalid object" do
        error_message = <<-ERROR_MESSAGE.strip
The following factories are invalid:

* invalid_user - Validation failed: {:required_attr=>["can't be blank"]} (RuntimeError)
* user+invalid - Validation failed: {:required_attr=>["can't be blank"]} (RuntimeError)
* user_hash - undefined method `save!' for [:name, "Fred"]:Array (NoMethodError)

The following callbacks are invalid:

after_create_not_existing_factory
        ERROR_MESSAGE

        expect do
          Factory.lint!(traits: true)
        end.to raise_error Cranky::Linter::InvalidFactoryError, error_message
      end
    end
  end
end
