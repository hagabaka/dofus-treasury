require "#{__DIR__}/resources"

class Item
  def self.named(name)
    first_or_create(:name => name)
  end
end

class Recipe
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
