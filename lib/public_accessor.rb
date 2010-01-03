module RescueRangers
  module PublicAccessor
    def public_accessor(*args)
      options = args.extract_options!
      names = self.column_names - args.map(&:to_s)
      MethodDefiner.new(names, self).define_both
      MethodDefiner.new(args, self).define_setters if options[:readonly]
    end
  end
  
  class MethodDefiner
    UNALLOWED = %w(id type)
    
    module RaiseMethods
      def raise_private_error(name)
        caller = caller(2).first
        unless caller =~ /active_record|#{self.class.name.underscore}/i
          raise(NoMethodError, "private method #{name} called for #<#{self.class}:0x#{self.object_id}>")
        end
      end
    end
    
    def initialize(names, klass)
      @klass = klass
      @klass.send(:include, RaiseMethods)
      @names = names.select{ |n| !UNALLOWED.include?(n.to_s) && !(n =~ /_id$/) }
    end
    
    def define_both
      @names.each do |name|
        define_getter(name)
        define_setter(name)
      end
    end
    
    def define_setters
      @names.each{ |name| define_setter(name) }
    end
    
  private
    
    def define_getter(name)
      @klass.class_eval do
        define_method(name) do
          raise_private_error(name)
        end
      end
    end
    
    def define_setter(name)
      @klass.class_eval do
        define_method("#{name}=") do |value|
          raise_private_error("#{name}=")
          self[name] = value
        end
      end
    end
    
  end
end
