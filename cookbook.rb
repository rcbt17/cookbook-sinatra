require 'csv'

class Cookbook

  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @recipes = []
    read_from_csv
  end

  def read_from_csv
    # Access our stored recipes
    # and push them to recipes array
    CSV.foreach(@csv_file_path) do |recipe_data|
      @recipes << Recipe.new(name: recipe_data[0], description: recipe_data[1], rating: recipe_data[2], prep_time: recipe_data[3], done: recipe_data[4])
    end
  end

  def store_recipes
    CSV.open(@csv_file_path, "wb") do |csv|
      @recipes.each do |recipe|
        csv << [recipe.name, recipe.description, recipe.prep_time, recipe.rating, recipe.done]
      end
    end
  end

  def all
    @recipes
  end

  def mark_as_done(id)
    recipes = []
    all.each_with_index do |recipe, index|
      recipe.done = "true" if id == index
      recipes << recipe
    end
    store_recipes
  end

  def create(recipe)
    @recipes << recipe
    store_recipes
  end

  def destroy(recipe_index)
    @recipes.delete_at(recipe_index)
    store_recipes
  end
end
