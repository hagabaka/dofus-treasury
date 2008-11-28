#!/usr/bin/ruby

require 'ramaze'
require 'instance-exec'
acquire 'models/*'


class String
  def title_case
    gsub(/\b([[:lower:]])/) {$1.upcase}   
  end
end

class MainController < Ramaze::Controller
  engine :Haml

  helper :aspect
  helper :identity
  helper :flash
  helper :cache

  layout '/page'

  PAGES = []

  def self.action(name, &block)
    define_method(name) do |*args|
      @action = name
      instance_exec(*args, &block) if block_given?
    end
  end

  def self.page(name,
                location="/#{name}",
                title=name.title_case,
               &block)
    action(name) do |*args|
      @current_page = name
      @title = title
      @cyclic_referal = location == URI.parse(request.referer).path
      instance_exec(*args, &block) if block_given?
    end
    PAGES << {:name => name, :location => location}
  end

  page('index', '/')
  page('items') {@items = Item.all}
  page('recipes') {@recipes = Recipe.all}
  cache :items, :recipes
  page('inventory') do
    identity = Identity.first_or_create(:url => @identity)
    session[:inventory] =
      Inventory.first_or_create('identity.url' => @identity)
    
    item, quantity = request[:item], request[:quantity]
    if item && quantity
      # jeditable seems to send new value + spaces + old value
      quantity.sub!(/^(\d+)(\s+\d+)?$/, $1)
      no_item_named(item) unless Item.get(item)
      if session[:inventory].containments \
        .first_or_create(:item_name => item,
                         :inventory_id => session[:inventory].id) \
                         .update_attributes(:quantity => quantity)
        flash[:success] = 'Inventory updated'
      else
        flash[:error] = 'Inventory update failed'
      end
      respond(quantity) if request[:ajax]
      redirect 'inventory'
    end
  end

  action :complete_item_name do
    respond Item.all(:name.like => "#{request[:q]}%").map(&:name).join("\n")
  end

  action :item do |name|
    @item = Item.get(name) or no_item_named(name)
    p @item
  end

  action :logout do
    session.clear
    flash[:success] = 'Logged out'
    redirect_referer
  end

  action :notemplate do
    "there is no 'notemplate.xhtml' associated with this action"
  end

  before {@pages = PAGES}
  before(:inventory, :edit_inventory) {require_login('use inventory')}

  private
  %w[render_item render_recipes load_script load_stylesheet].each do |name|
    define_method(name) do |argument|
      render_template "#{name}.haml", :argument => argument
    end
  end

  def tree_traverse_item(item, children_method, &block)
    yield(item)
    children = item.send(children_method)
    unless children.empty?
      yield(:begin_children)
      children.each do |child|
        tree_traverse_item(child, children_method, &block)
      end
      yield(:end_children)
    end
  end

  def no_item_named(name)
    flash[:error] = "No item named #{name}"
    abort
  end

  def require_login(action)
    unless @identity = session[:openid_identity]
      flash[:error] = 'You need to login to access inventory'
      abort
    end
  end

  def abort
    if @cyclic_referal
      redirect '/'
    else
      redirect_referer
    end
  end
end

Ramaze.start(:port => 60384)
