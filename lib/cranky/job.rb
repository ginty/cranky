module Cranky
  class Job

    attr_writer :defaults
    attr_reader :overrides, :return_attributes

    def initialize(target, overrides={})
      @defaults = {}
      @target = target
      @overrides = overrides
      @return_attributes = overrides.delete(:_return_attributes)
    end

    def attributes
      @attributes ||= @defaults.merge(@overrides)
    end

    def defaults=(defs)
      @attributes = nil   # Needs to be re-calculated
      @defaults = defs
    end

    # Returns the created item
    def item
      return @item if @item
      if @return_attributes
        @item = Hash.new
      else
        @item = get_constant(attributes[:class] ? attributes.delete(:class) : @target).new
      end
    end

    # Assign the value to the given attribute of the item
    def assign(attribute, value)
      unless value == :skip || attribute == :class
        if item.respond_to?("#{attribute}=")
          item.send("#{attribute}=", value)
        elsif item.is_a?(Hash)
          item[attribute] = value
        end
      end
    end

    def execute
      values = attributes.reject { |attribute, value| value.respond_to?("call") }
      blocks = attributes.select { |attribute, value| value.respond_to?("call") }

      values.each { |attribute, value| assign(attribute, value) }
      blocks.each { |attribute, value| assign(attribute, value.call(*(value.arity > 0 ? [item] : []))) }

      item
    end

    private

      # Nicked from here: http://gist.github.com/301173
      def get_constant(name_sym)
        return name_sym if name_sym.is_a? Class

        name = name_sym.to_s.split('_').collect {|s| s.capitalize }.join('')
        Object.const_defined?(name) ? Object.const_get(name) : Object.const_missing(name)
      end

  end
end
