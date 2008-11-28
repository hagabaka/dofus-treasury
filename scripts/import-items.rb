#!/usr/bin/ruby

# Collect recipes and items from paste of wikia page and save to db
#
# Provide the name of input file in argument or pipe it
#
# Format of input file:
# One recipe per line
# Example line:
# Product Item  2 Ingredient A, 3 Ingredient B, 1 Ingredient C
# (Two or more spaces between product and the ingredient list)
#
# Example input files are in doc/examples

require 'ramaze'
acquire 'models/*'

ARGF.each_line do |line|
  line.strip
  (product_name, ingredient_list) = line.strip.split(/\s{2,}/)
  next unless product_name && ingredient_list
  puts product_name
  product = Item.named(product_name)
  product.save
  ingredients = {}
  ingredient_list.split(', ').each do |ingredient|
    if ingredient =~ /([1-9]\d*) (.+)/
      (quantity, item_name) = Integer($1), $2
      puts item_name
      item = Item.named(item_name) 
      item.save
      ingredients[item] = quantity
    else
      warn "Cannot parse #{ingredient}"
    end
  end
  Recipe.defined(product, ingredients).save
end

