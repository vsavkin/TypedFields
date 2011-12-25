require "typed_fields/version"
require 'bigdecimal'

module TypedFields
  class ObjectType
    def parse obj
      obj
    end
  end
  
  class IntegerType
    def parse obj
      return nil if obj.nil?
      obj.to_i
    end
  end

  class DecimalType
    def parse obj
      return nil if obj.nil?
      BigDecimal.new(obj)
    end
  end

  class StringType
    def parse obj
      return nil if obj.nil?
      obj.to_s
    end
  end

  class BooleanType
    def parse obj
      return nil if obj.nil?
      obj == "true"
    end
  end

  class ArrayType
    def initialize type
      @type = type
    end
    
    def parse obj
      return nil if obj.nil?
      obj.map{|o| @type.parse o}
    end
  end
  
  module ClassMethods
    { :object => ObjectType.new,
      :integer => IntegerType.new,
      :decimal => DecimalType.new,
      :string => StringType.new,
      :boolean => BooleanType.new,
      :custom => nil}.each do |method_name, type|

      define_method method_name do |*params|
        declare_fields params, type
      end

      array_method = "array_of_#{method_name}s"
      define_method array_method do |*params|
        declare_fields params, ArrayType.new(type)
      end
    end

    def saved_type_info
      name = :@@fields_type_information
      if class_variable_defined?(name)
        class_variable_get(name)
      else
        class_variable_set(name, {})
      end
    end
    
    private
    def declare_fields params, type
      options = params.last.is_a?(Hash) ? params.pop : {}
      options[:type] ||= type
      
      params.each do |field_name|
        saved_type_info[field_name] = options
      end
    end
  end

  module InstanceMethods
    def initialize_fields params
      set_default_values
      params.each do |field_name, value|
        set_value field_name, value
      end
    end
    
    private
    
    def set_value field_name, value
      type_info = self.class.saved_type_info[field_name]
      return unless type_info 
      type = type_info[:type]
      parsed_value = type.parse(value)
      instance_variable_set "@#{field_name.to_s}", parsed_value
    end

    def set_default_values
      self.class.saved_type_info.each do |field_name, options|
        default_value = options[:default]
        default_value = default_value.call(self) if default_value.respond_to? :call
        set_value field_name, default_value
      end
    end
  end
       
  def self.included clazz
    clazz.send :include, InstanceMethods
    clazz.extend ClassMethods
  end
end
