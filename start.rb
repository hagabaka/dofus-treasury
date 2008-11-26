#!/usr/bin/ruby

require 'ramaze'
require "#{__DIR__}/models"

class MainController < Ramaze::Controller
  helper :markaby
  engine :Markaby

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
  page 'recipes'
  page 'inventory'

  def item(name)
    @item = Item.named(name)
  end

  def recipe

  end

  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end

  before {@pages = PAGES}
end

Ramaze.start
