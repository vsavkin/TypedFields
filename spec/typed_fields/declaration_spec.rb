require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TypedFields::Declaration do

  let(:clazz) do
    clazz = Class.new
    clazz.send :include, TypedFields::Declaration
    clazz
  end

  let(:object) do
    clazz.new
  end

  context "basic" do
    it "should declare an object field" do
      clazz.object :object_field
      object.initialize_fields :object_field => "value"
      
      f(:object_field).should == "value"
    end

    it "should declare many object fields" do
      clazz.object :field1, :field2
      object.initialize_fields :field1 => "value1", :field2 => "value2"
      
      f(:field1).should == "value1"
      f(:field2).should == "value2"
    end
  end

  context "default values" do
    it "should be used when field values are not passed" do
      clazz.object :field, :default => "default"
      object.initialize_fields({})
      f(:field).should == "default"
    end

    it "should not use default values specified for other fields" do
      clazz.object :field1, :default => "default"
      clazz.object :field2
      object.initialize_fields({})
      f(:field1).should == "default"
      f(:field2).should be_nil
    end
  end

#  context "#generate_initialize"

  private

  def f field_name
    object.instance_variable_get "@#{field_name.to_s}"
  end
end
