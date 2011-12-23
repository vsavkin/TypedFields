module TypedFields
  module Declaration
    def self.included clazz
      clazz.extend ClassMethods
    end

    def initialize_fields params
      set_default_values
      params.each do |field_name, value|
        set_value field_name, value
      end
    end
    
    module ClassMethods
      def object *params
        options = params.last.is_a?(Hash) ? params.pop : {}
        options[:type] = :object
        
        @fields_type_information ||= {}
        params.each do |field_name|
          @fields_type_information[field_name] = options
        end
      end
    end

    private

    def saved_type_info
      self.class.instance_variable_get("@fields_type_information") || {}
    end

    def set_value field_name, value
      instance_variable_set "@#{field_name.to_s}", value
    end

    def set_default_values
      saved_type_info.each do |field_name, options|
        set_value field_name, options[:default]
      end
    end
  end
end
