require 'open-uri'
require 'nokogiri'

class ScraperService
  def initialize(keyword)
    @keyword = keyword
    @scrape_url = "https://www.allrecipes.com/search?q=#{keyword}"
  end

  def get_nokogiri_obj(url)
    Nokogiri::HTML.parse(URI.open(url).read)
  end

  def find_recipes
    html_doc = get_nokogiri_obj(@scrape_url)
    found = 0
    recipes = []
    html_doc.search(".card--no-image").each do |result|
      if found < 5 && result.search(".recipe-card-meta__rating-count").count.positive?
        recipe_title = result.search(".card__title-text").text
        recipe_url = result.attribute("href").value
        found += 1
        recipes << Recipe.new(name: recipe_title, url: recipe_url)
      else
        next
      end
    end
    recipes
  end

  def find_recipe_details(url)
    html_doc = get_nokogiri_obj(url)
    rating = html_doc.search(".mntl-recipe-review-bar__rating").text.strip.to_f
    prep_time = "empty"
    html_doc.search(".mntl-recipe-details__item").each do |element|
      if element.search(".mntl-recipe-details__label").text =~ /Prep/
        prep_time = element.search(".mntl-recipe-details__value").text
      end
    end
    description = ""
    html_doc.search(".mntl-sc-block .mntl-sc-block-startgroup").each do |step|
      description += step.search(".mntl-sc-block-html").text
    end
    {rating: rating, prep_time: prep_time, description: description}
  end
end
