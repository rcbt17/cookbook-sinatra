require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require_relative 'recipe'
require_relative 'cookbook'
require_relative 'scraper_service'
require "base64"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path(__dir__)
end

COOKBOOK = Cookbook.new('recipes.csv')

get "/" do
  @recipes = COOKBOOK.all
  erb :index
end

get "/new" do
  erb :new
end

post "/new" do
  @name = params['name']
  @description = params['description']
  @rating = params['rating']
  @prep_time = params['prep_time']
  params['done'] == "on" ? @done = "true" : @done = "false"
  COOKBOOK.create(Recipe.new(name: @name, description: @description, rating: @rating, prep_time: @prep_time, done: @done))
  COOKBOOK.store_recipes
  redirect '/'
end

get "/delete/:id" do
  @id = params['id'].to_i
  COOKBOOK.all.each_with_index do |_recipe, index|
    if index == @id
      COOKBOOK.destroy(index)
    end
  end
  COOKBOOK.store_recipes
  redirect '/'
end

get "/done/:id" do
  @id = params['id'].to_i
  COOKBOOK.mark_as_done(@id)
  COOKBOOK.store_recipes
  redirect '/'
end

get "/import" do
  erb :search
end

post "/import" do
  scraper = ScraperService.new(params['keyword'])
  @recipes = scraper.find_recipes
  erb :search_results
end

get "/add/:name/:url" do
  scraper = ScraperService.new('')
  data_hash = scraper.find_recipe_details(Base64.decode64(params['url']))
  imported_recipe = Recipe.new(name: params['name'], description: data_hash[:description], rating: data_hash[:rating], prep_time: data_hash[:prep_time], done: "false")
  COOKBOOK.create(imported_recipe)
  redirect '/'
end
