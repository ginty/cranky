class Cranky

  VERSION = "0.0.4"

#  Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/*.rb").each do |file|
#    require file
#    # Auto include all modules found in the directory
#    file =~ /.*[\/\\](.*)\.rb/
#    begin
#      include $1.to_s.camelcase.constantize
#    rescue
#    end
#  end

  attr_accessor :debug

  def initialize
    @what = []
    @attrs = []
    @n = 0
  end

  def build(what, attrs={})
    crank_it(what, false, attrs)
  end

  def create(what, attrs={})
    crank_it(what, true, attrs)
  end

  def reset
    self.instance_variables.each do |var|
      instance_variable_set(var, nil)
    end
    initialize
  end

  def attributes_for(what, attrs={})
    build(what, attrs).attributes
  end

  private

    def n
      @n += 1
    end

    def inherit(what, attrs={})
      build(what, attrs.merge(options))
    end

    def crank_it(what, save, attrs)
      @attrs << attrs; @what << what
      item = self.send(what)
      @attrs.pop; @what.pop
      if @debug && !item.valid?
        raise "Oops, the #{what} created by the Factory has the following errors: #{item.errors}"
      end
      item.save if save
      item
    end

    def define(attrs={})
      final_attrs = attrs.merge(@attrs.last)
      #item = (attrs[:class] ? attrs[:class] : @what.last).to_s.camelcase.constantize.new
      item = get_constant(attrs[:class] ? attrs[:class] : @what.last).new
      final_attrs.delete(:class)
      final_attrs.each do |attr, value|
        item.send("#{attr}=", value) if item.respond_to?("#{attr}=")
      end
      item
    end

    # Nicked from here: http://gist.github.com/301173 
    def get_constant(name_sym)
      name = name_sym.to_s.split('_').collect {|s| s.capitalize }.join('')
      Object.const_defined?(name) ? Object.const_get(name) : Object.const_missing(name)
    end

    def options
      @attrs.last
    end

end

Factory = Cranky.new unless defined?(Factory)

