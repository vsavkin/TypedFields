# Typed Fields

## Introduction
Using ActiveRecord for your domain objects causes a lot of grief. Often it's just impossible as there is no table that you map your domain objects too. There are some adhoc solutions that were introducted like "BaseWithoutTable" that ease that pain a little bit. But fundamentaly the problem is still there. A pure domain object is tied to the implementation detail - AR. ActiveModel is a big step forward and I highly recommend to use it. But there are a few things I really miss when I use ActiveModel. One of them is typed fields. ActiveRecord handles all type conversations for you. You just pass a bunch of strings and it knows what to do with them. That's where the TypedFields gem comes into play. It allows you to specify types for your fields so migration from AR to AM won't be a problem.

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

As you can see from the exampel above including TypedFields adds several class methods (such as string, integer) and an instance method "initialize_fields".

## Advanced Features

### Using Custom Types
Besides having such basic types as integers, decimals, string and boolean you can specify custom types. 

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
  string :first_name, :last_name
  string :full_name, default: Proc.new{|p| "#{p.first_name} #{p.last_name}"}
end

p = Person.new
p.initialize_fields first_name: "John", last_name: "Coltrane" #@full_name == "John Coltrane" 
```
