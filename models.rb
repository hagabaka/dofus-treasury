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

  def self.named(name)
    first_or_create(:name => name)
  end
end

class Dosage
  include DataMapper::Resource

  property     :quantity,               Integer
  property     :item_name,              String, :key => true
  property     :recipe_id,              Integer, :key => true

  belongs_to   :item
  belongs_to   :recipe
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

  # return recipe with the given product and ingredient/quantities,
  # creating if not existing
  #
  # Recipe.defined( Item.named('Bread'),
  #                 Item.named('Flour') => 2,
  #                 Item.named('Yeast') => 1,
  #                 Item.named('Water') => 1 )
  def self.defined(product, ingredients_and_quantities)
# FIXME the current implementation does not check for existing recipes with
#       the given product, ingredients and quantities; instead it assumes
#       that recipes are unique by product
#    first(:product => product,
#          :ingredients => ingredienst_and_quantities.keys,
#          :dosages.all? {|d| ingredients_and_quantities[d.item] == d.quantity}
#          # how to translate to query?
#         ) \
    (product.producing_recipes || []).first or
    begin
      r = Recipe.new
      r.product = product
      ingredients_and_quantities.each_pair do |ingredient, quantity|
        r.dosages << Dosage.new(:quantity => quantity, :item => ingredient)
      end
      r
    end
  end
end

DataMapper.auto_upgrade!

