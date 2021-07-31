require_relative '../db/mysql_connector'
require_relative '../models/item'

class Category
    attr_accessor :name, :id, :items

    def initialize(name, id=nil, items=[])
        @name = name
        @id = id
        @items = items
    end

    def save
        client = create_db_client

        client.query("insert into categories(name) values ('#{@name}')")
    end

    def update(name, id)
        client = create_db_client
         
        client.query("
            update categories 
            set name = '#{name}'
            where id = #{id}
        ")
    end

    def delete
        client = create_db_client

        client.query("
            delete from item_categories
            where category_id = #{@id}
        ")
    
        client.query("
            delete from categories 
            where id = #{@id}
        ")
    end

    def self.get_all
        client = create_db_client
        categories = Array.new
    
        rawData = client.query("select * from categories")
    
        rawData.each do |data|
            category = Category.new(data["name"], data["id"]);
            categories.push(category)
        end
    
        categories
    end

    def self.get_by_id(id)
        client = create_db_client
        categories = Array.new

        rawData = client.query("select * from categories where categories.id = #{id}")
    
        rawData.each do |data|
            category = Category.new(data["name"], data["id"]);
            categories.push(category)
        end
    
        categories[0]
    end

    def self.get_by_item_id(item_id)
        client = create_db_client
        categories = Array.new

        rawData = client.query("
            select * 
            from categories 
            join item_categories on categories.id = item_categories.category_id
            where item_categories.item_id = #{item_id}")
    
        rawData.each do |data|
            category = Category.new(data["name"], data["id"]);
            categories.push(category)
        end
    
        categories
    end

    def self.get_with_items_by_category_id(category_id)
        category = Category.get_by_id(category_id)
        category.items = Item.get_by_category_id(category_id)

        category
    end
end
