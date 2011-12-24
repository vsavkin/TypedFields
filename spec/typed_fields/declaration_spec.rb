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

    it "should ignore fields that were not declared" do
      clazz.object :field
      object.initialize_fields :another_field => "value"
      f(:another_field).should be_nil
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

    it "should call default value when it is a block" do
      clazz.object :field, :default => Proc.new {"default"}
      object.initialize_fields({})
      f(:field).should == "default"
    end

    it "should pass the object being constructed to a default block" do
      default = double("default proc")
      clazz.object :field, :default => default
      
      default.stub(:respond_to?){true}
      default.should_receive(:call).with(object).and_return("default")

      object.initialize_fields({})
      f(:field).should == "default"
    end
  end

  context "types" do
    it "should parse integers" do
      clazz.integer :field
      object.initialize_fields(:field => "10")
      f(:field).should == 10
    end

    it "should parse decimals" do
      clazz.decimal :field
      object.initialize_fields(:field => "1.5")
      f(:field).should == 1.5
    end

    it "should parse strings" do
      clazz.string :field
      object.initialize_fields(:field => 100)
      f(:field).should == "100"
    end

    it "should parse booleans" do
      clazz.boolean :field
      object.initialize_fields(:field => "true")
      f(:field).should == true
    end

    it "should parse an array of integers" do
      clazz.array_of_integers :field
      object.initialize_fields(:field => ["1", "2"])
      f(:field).should == [1,2]
    end
    
    it "should call custom's type constructor when custom type is specified" do
    end
  end

  context "inheritance" do
  end
  
  private

  def f field_name
    object.instance_variable_get "@#{field_name.to_s}"
  end
end
