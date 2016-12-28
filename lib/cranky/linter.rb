module Cranky
  class Linter

    def initialize(factory, factories_to_lint, linting_strategy)
      @factory = factory
      @factories_to_lint = factories_to_lint
      @linting_method = "lint_#{linting_strategy}"
      @invalid_factories = calculate_invalid_factories
      @invalid_callbacks = calculate_invalid_callbacks
    end

    def lint!
      if invalid_factories.any? || invalid_callbacks.any?
        raise InvalidFactoryError, error_message
      end
    end

    attr_reader :factories_to_lint, :invalid_factories, :invalid_callbacks
    private :factories_to_lint, :invalid_factories, :invalid_callbacks

    private

    def calculate_invalid_factories
      factories_to_lint.reduce(Hash.new([])) do |result, factory|
        errors = send(@linting_method, factory)
        result[factory] |= errors unless errors.empty?
        result
      end
    end

    def calculate_invalid_callbacks
      result = []

      regexp = /^(after_build|before_create|after_create)_(\w+)$/.freeze
      available_methods = @factory.private_methods(false) + @factory.public_methods(false)
      available_methods.select do |m|
        match = regexp.match(m)
        if match
          factory_name = match[2]

          unless @factory.respond_to?(factory_name)
            result << m
          end
        end
      end

      result
    end

    # Raised when any factory is considered invalid
    class InvalidFactoryError < RuntimeError; end

    class FactoryError
      def initialize(wrapped_error, factory_name)
        @wrapped_error = wrapped_error
        @factory_name  = factory_name
      end

      def message
        message = @wrapped_error.message
        "* #{location} - #{message} (#{@wrapped_error.class.name})"
      end

      def location
        @factory_name
      end
    end

    class FactoryTraitError < FactoryError
      def initialize(wrapped_error, factory_name, trait_name)
        super(wrapped_error, factory_name)
        @trait_name = trait_name
      end

      def location
        "#{@factory_name}+#{@trait_name}"
      end
    end

    def lint_factory(factory_name)
      result = []
      begin
        @factory.create!(factory_name)
      rescue => error
        result |= [FactoryError.new(error, factory_name)]
      end
      result
    end

    def lint_traits(factory_name)
      result = []
      @factory.traits_for(factory_name).each do |trait_name|
        begin
          @factory.create!(factory_name, traits: trait_name)
        rescue => error
          result |=
              [FactoryTraitError.new(error, factory_name, trait_name)]
        end
      end
      result
    end

    def lint_factory_and_traits(factory_name)
      errors = lint_factory(factory_name)
      errors |= lint_traits(factory_name)
      errors
    end

    def error_message
      [
        factories_error_message,
        callbacks_error_message
      ].compact.join("\n\n".freeze)
    end

    def factories_error_message
      lines = invalid_factories.map do |_factory, exceptions|
        exceptions.map(&:message)
      end.flatten

      return if lines.empty?

      "The following factories are invalid:\n\n#{lines.join("\n")}"
    end

    def callbacks_error_message
      return if invalid_callbacks.empty?

      "The following callbacks are invalid:\n\n#{invalid_callbacks.join("\n")}"
    end
  end
end
