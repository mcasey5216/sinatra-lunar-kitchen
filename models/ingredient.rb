class Ingredient

    attr_reader :name
    def initialize(name)
      @name = name
    end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.ingredients(id)
    ingredients_array =[]
    db_connection do |conn|
      ingredients_array << conn.exec("SELECT name FROM ingredients WHERE recipe_id = #{id}").to_a
    end
    ing_formatted = []
    ingredients_array[0].each do |ingredient|
      ing_formatted << Ingredient.new(ingredient["name"])
    end
    ing_formatted
    

  end
end
