require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup :default,
                 :adapter => 'postgres',
                 :host => 'localhost',
                 :port => 5432,
                 :username => 'dofus_treasury',
                 :password => 'dofus_treasury',
                 :database => 'dofus_treasury'


# Items are identified by names, for example, Bread
# A recipe has one product item, and a few ingredient items each dosed with a
# quantity, for example, Bread = 2 Flour + 1 Yeast + 1 Water
# A dosage is to used to hold one ingredient item and its quantity

class Item
  include DataMapper::Resource

  property      :name,                  String, :key => true
  has n,        :dosages

  has n,        :producing_recipes,     :class_name => 'Recipe',
                                        :child_key => [:product_name]
  has n,        :consuming_recipes,     :class_name => 'Recipe',
                                        :through => :dosages,
                                        :remote_relationship_name => :recipe

  def derivatives
    consuming_recipes.map(&:product)
  end

  # has n,        :derivatives,           :class_name => 'Item',
  #                                      :through => :consuming_recipes,
  #                                      :remote_relationship_name => :product
  has n,        :materials,             :class_name => 'Item',
                                        :through => :producing_recipes,
                                        :remote_relationship_name =>
                                                :ingredients,
                                        :child_key => [:product_name]
end

class Stack
  include DataMapper::Resource
  property      :id,                    Serial
  property      :type,                  Discriminator
  property      :quantity,              Integer
  property      :item_name,             String

  belongs_to    :item
end

class Dosage < Stack
  property      :recipe_id,             Integer
  belongs_to    :recipe
end

class Recipe
  include DataMapper::Resource

  property      :id,                    Serial
  belongs_to    :product,               :class_name => 'Item',
                                        :child_key => [:product_name]
  has n,        :dosages
  has n,        :ingredients,           :class_name => 'Item',
                                        :through => :dosages,
                                        :remote_relationship_name => :item
end

class Identity
  include DataMapper::Resource

  property      :url,                   String, :key => true
  has 1,        :inventory
  has n,        :items,                 :through => :inventory
end

class Inventory
  include DataMapper::Resource

  property      :id,                    Serial
  has n,        :containments
  belongs_to    :identity
end

class Containment < Stack
  property      :inventory_id,          Integer
  belongs_to    :inventory
end

DataMapper.auto_upgrade!

