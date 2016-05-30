module Cranky
  class Factory

    attr_writer :debug

    def initialize
      # Factory jobs can be nested, i.e. a factory method can itself invoke another factory method to
      # build a dependent object. In this case jobs the jobs are pushed into a pipeline and executed
      # in a last in first out order. 
      @pipeline = []
      @n = 0
      @errors = []
    end
    
    def build(what, overrides={})
      crank_it(what, overrides)
    end

    def create(what, overrides={})
      item = build(what, overrides)
      item.save
      item
    end

    # Reset the factory instance, clear all instance variables 
    def reset
      self.instance_variables.each do |var|
        instance_variable_set(var, nil)
      end
      initialize
    end

    def attributes_for(what, attrs={})
      build(what, attrs.merge(:_return_attributes => true))
    end

    # Can be left in your tests as an alternative to build and to warn if your factory method 
    # ever starts producing invalid instances 
    def debug(*args)
      item = build(*args) 
      if !item.valid?
        if item.errors.respond_to?("messages")
          errors = item.errors.messages
        else
          errors = item.errors
        end
        raise "Oops, the #{item.class} created by the Factory has the following errors: #{errors}"
      end
      item
    end

    # Same thing for create
    def debug!(*args)
      item = debug(*args)
      item.save
      item
    end

    private

      def apply_traits(what, item)
        Array(options[:traits]).each do |t|
          trait_method_name = "apply_trait_#{t}_to_#{what}"
          fail("Invalid trait '#{t}'! No method '#{trait_method_name}' is defined.") unless respond_to?(trait_method_name)
          send(trait_method_name, item)
        end

        item
      end

      def n
        @n += 1
      end

      # Execute the requested factory method, crank out the target object!
      def crank_it(what, overrides)
        if what.to_s =~ /(.*)_attrs$/
          what = $1
          overrides = overrides.merge(:_return_attributes => true)
        end
        item = "TBD"
        new_job(what, overrides) do
          item = self.send(what)        # Invoke the factory method
          item = apply_traits(what, item)
        end
        item
      end

      # This method actually makes the required object instance, it gets called by the users factory 
      # method, where the name 'define' makes more sense than it does here!
      def define(defaults={})
        current_job.defaults = defaults   
        current_job.execute
      end

      def inherit(what, overrides={})
        overrides = overrides.merge(options)
        overrides = overrides.merge(:_return_attributes => true) if current_job.return_attributes
        build(what, overrides)
      end

      def current_job
        @pipeline.last  
      end

      # Returns a hash containing any top-level overrides passed in when the current factory was invoked
      def options
        current_job.overrides
      end

      # Adds a new job to the pipeline then yields to the caller to execute it 
      def new_job(what, overrides)
        @pipeline << Job.new(what, overrides)
        yield
        @pipeline.pop
      end

  end

end

