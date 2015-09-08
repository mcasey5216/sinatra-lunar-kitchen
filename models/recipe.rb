# database table structure
# ingredients(id, name, recipe id)
# recipe(id, name, instruction, description)

#
# "SELECT recipes.name, recipes.instructions, recipes.description, ingredients.name AS ingredients
# FROM recipes JOIN ingredients ON recipes.id = ingredients.recipe_id"
class Recipe
  attr_accessor :id, :name, :instructions, :description, :ingredients

  def initialize(id, name, instructions, description, ingredients = [])
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    recipe_array = []
    db_connection do |conn|
      recipe_array = conn.exec("SELECT id, name FROM recipes").to_a
    end
    recipe_formatted = []
    recipe_array.each do |recipe|
      recipe_formatted << Recipe.new(recipe["id"], recipe["name"], nil, nil, nil)

    end
    recipe_formatted
  end

  def self.find(id)
    recipe_array = []
    db_connection do |conn|
      recipe_array = conn.exec("SELECT recipes.id, recipes.name, recipes.instructions, recipes.description FROM recipes WHERE id = #{id}").to_a
    end
    result = nil
    if recipe_array.count == 0
      result = Recipe.new(id, "Does not have a name", "This recipe doesn't have any instructions.", "This recipe doesn't have a description." , [])
    else
      recipe_formatted = []
      recipe_array.each do |recipe|
        recipe_formatted << Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"], Ingredient.ingredients(id))
      end
      result = recipe_formatted[0]
    end
    result
  end
end
