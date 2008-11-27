#!/usr/bin/ruby

require 'ramaze'
require "#{__DIR__}/models"

class MainController < Ramaze::Controller
  engine :Haml

  helper :aspect

  layout '/page'

  PAGES = []
  def self.page(name,
                location="/#{name}",
                title=name.gsub(/\b([[:lower:]])/) {$1.upcase},
               &block)
    define_method(name) do
      @current_page = name
      @title = title
      instance_eval(&block) if block_given?
    end
    PAGES << {:name => name, :location => location}
  end

  page 'index', '/'
  page('items') {@items = Item.all}
  page('recipes') {@recipes = Recipe.all}
  page 'inventory'

  def item(name)
    @item = Item.get!(name)
  end

  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end

  before {@pages = PAGES}

  private
  def render_item(item)
    render_template 'item-element.haml', :item => item
  end

  def render_recipes(recipes)
    render_template 'recipes-element.haml', :recipes => recipes
  end
end

Ramaze.start
