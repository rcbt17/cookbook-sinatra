class Recipe
  attr_accessor :name, :description, :url, :prep_time, :rating, :done

  def initialize(attributes = {})
    @name = attributes[:name]
    @description = attributes[:description]
    @url = attributes[:url]
    @prep_time = attributes[:prep_time]
    @rating = attributes[:rating]
    @done = attributes[:done]
  end
end
