require_relative '../db/mysql_connector'
require_relative 'category'

class Item
    attr_accessor :name, :price, :id, :categories

    def initialize(name, price, id=nil, categories=[])
        @name = name
        @price = price
        @id = id
        @categories = categories
    end

    def save
        client = create_db_client

        client.query("insert into items (name, price) values ('#{@name}', #{@price})")
    end
    
    def update(id, name, price)
        client = create_db_client
         
        client.query("
            update items 
            set name = '#{name}',
            price = #{price}
            where id = #{id}
        ")
    end

    def update_categories(categories_id)
        client = create_db_client

        new_categories_id = get_new_categories(categories_id)
        delete_categories_id = get_delete_categories(categories_id)

        new_categories_id.each do | category_id |
            client.query("
                insert into item_categories(item_id, category_id)
                values (#{id}, #{category_id})
            ")
        end

        delete_categories_id.each do | category_id |
            client.query("
                delete from item_categories
                where category_id = '#{category_id}'
            ")
        end
    end

    def get_new_categories(categories_id)
        new_categories_id = Array.new

        self_categories_id_array = self.categories.map(&:id)

        categories_id.each do |category_id|
            new_categories_id << category_id unless self_categories_id_array.include?(category_id)
        end

        new_categories_id
    end

    def get_delete_categories(categories_id)
        delete_categories_id = Array.new

        self_categories_id_array = self.categories.map(&:id)
        
        self_categories_id_array.each do |self_category_id|
            delete_categories_id << self_category_id unless categories_id.include?(self_category_id)
        end

        delete_categories_id
    end
    
    def delete
        client = create_db_client

        client.query("
            delete from item_categories
            where item_id = #{@id}
        ")
    
        client.query("
            delete from items 
            where id = #{@id}
        ")
    end
    
    def self.get_all
        client = create_db_client
        items = Array.new
    
        rawData = client.query("select * from items")
    
        rawData.each do |data|
            item  = Item.new(data["name"], data["price"], data["id"]);
            items.push(item)
        end
    
        items
    end
    
    def self.get_by_id(id)
        client = create_db_client
        items = Array.new
        categories = Array.new

        rawData = client.query("
            select items.id, items.name, items.price
            from items 
            where items.id = #{id}
            ")
    
        rawData.each do |data|
            item  = Item.new(data["name"], data["price"], data["id"]);
            items.push(item)
        end

        items[0]
    end

    def self.get_by_category_id(category_id)
        client = create_db_client
        items = Array.new

        rawData = client.query("
            select * 
            from items 
            join item_categories on items.id = item_categories.item_id
            where item_categories.category_id = #{category_id}")
    
        rawData.each do |data|
            item = Item.new(data["name"], data["price"], data["id"]);
            items.push(item)
        end
    
        items
    end

    def self.get_with_categories_by_item_id(item_id)
        item = Item.get_by_id(item_id)
        item.categories = Category.get_by_item_id(item_id)

        item
    end

    def self.get_all_with_price_lower_than(price)
        client = create_db_client
        items = Array.new
    
        rawData = client.query("select * from items where price < #{price}")
    
        rawData.each do |data|
            item  = Item.new(data["name"], data["price"], data["id"]);
            items.push(item)
        end
    
        items
    end
end
