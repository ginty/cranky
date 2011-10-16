module Cranky
  class Job

    attr_writer :defaults
    attr_reader :overrides

    def initialize(target, overrides={})
      @defaults = {}
      @target = target
      @overrides = overrides
    end

    def attributes
      @attributes ||= @defaults.merge(@overrides)
    end

    def defaults=(defs)
      @attributes = nil   # Needs to be re-calculated
      @defaults = defs
    end

    def execute
      item = get_constant(attributes[:class] ? attributes[:class] : @target).new
      # Assign all explicit attributes first
      attributes.each do |attribute, value|
        unless value == :skip
          item.send("#{attribute}=", value) if item.respond_to?("#{attribute}=") && !value.respond_to?("call")
        end
      end
      # Then call any blocks
      attributes.each do |attribute, value|
        item.send("#{attribute}=", value.call(item)) if item.respond_to?("#{attribute}=") && value.respond_to?("call")
      end
      item
    end

    private

      # Nicked from here: http://gist.github.com/301173 
      def get_constant(name_sym)
        name = name_sym.to_s.split('_').collect {|s| s.capitalize }.join('')
        Object.const_defined?(name) ? Object.const_get(name) : Object.const_missing(name)
      end

  end
end
