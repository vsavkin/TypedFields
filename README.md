# Typed Fields

## Introduction
Using ActiveRecord to implement domain objects causes a lot of grief. Often it's just impossible as there is no table that you map your domain objects to. 

ActiveModel is a big step forward and I highly recommend using it. It does a pretty good job doing what AR used to do but without coupling your domain objects to the database. One of a few things I miss though is is typed fields. ActiveRecord takes care of all type conversations. You just pass a bunch of strings and it knows what to do with them. You need to do it manually if you use ActiveModel.

That's where the TypedFields gem comes into play. It allows you to specify types for your fields which eases the migration from ActiveRecord to ActiveModel.


## How to use
```ruby
class Person
  include TypedFields

  string :first_name, :last_name
  integer :age
  decimal :income

  def initialize params
    initialize_fields params
  end
end
```

As you can see from the example above including TypedFields adds several class methods (such as string, integer) and an instance method initializing fields.

## Advanced Features

### Using Custom Types
Besides having such basic types as integers, decimals, strings and booleans you can specify custom types. 

```ruby
module UppercaseString
  def self.parse str
    str.upcase
  end
end

class Person
  include TypedFields
  custom :name, type: UppercaseString
end

p = Person.new
p.initialize_fields name: "abc" # @name == ABC
```

### Arrays
```ruby
class Service
  include TypedFields
  array_of_integers :object_ids
end

s = Service.new
s.initialize_fields object_ids => ["1", "2"] # @object_ids == [1,2]
```
  
### Default Values
```ruby
class Person
  include TypedFields
  string :name
  integer :age, default: 100
end

p = Person.new
p.initialize_fields name: "John" #@name == "John", @age == 100
```

### Using Proc as a Default Value
```ruby
class Person
  include TypedFields
  string :name, default: Proc.new{"default value"}
end

p = Person.new
p.initialize_fields({}) #@name == "default_value"