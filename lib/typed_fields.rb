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

  class ProcType
    def initialize proc
      @proc = proc
    end

    def parse obj
      @proc.call obj
    end
  end

  TypeInfo = Struct.new(:field_name, :type, :default)
  
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
        class_variable_set(name, [])
      end
    end
    
    private
    def declare_fields params, type
      options = params.last.is_a?(Hash) ? params.pop : {}
      type = extract_type(options, type)
      default = extract_default(options)
      
      params.each do |field_name|
        saved_type_info << TypeInfo.new(field_name, type, default)
      end
    end

    def extract_type options, type
      t = options[:type] || type
      t.respond_to?(:call) ? ProcType.new(t) : t
    end

    def extract_default options
      options[:default]
    end
  end

  module InstanceMethods
    def initialize_fields params
      self.class.saved_type_info.each do |type_info|
        value = value_for params, type_info
        set_value type_info.field_name, value
      end
    end
    
    private

    def value_for params, type_info
      if passed_value_for? params, type_info
        value = parse_passed_value params, type_info
      else
        value = default_value type_info
      end
    end

    def passed_value_for? params, type_info
       params.has_key?(type_info.field_name)
    end

    def default_value type_info
      d = type_info.default
      d.respond_to?(:call) ? d.call(self) : d
    end

    def parse_passed_value params, type_info
      passed_value = params[type_info.field_name]
      type_info.type.parse(passed_value) 
    end
    
    def set_value field_name, value
      instance_variable_set "@#{field_name.to_s}", value
    end
  end
       
  def self.included clazz
    clazz.send :include, InstanceMethods
    clazz.extend ClassMethods
  end
end
