require_relative '../models/item'
require_relative '../models/category'

class ItemController
    def self.all
        items = Item.get_all

        render = ERB.new(File.read("views/all_item.erb"))
        render.result(binding)
    end

    def self.create
        render = ERB.new(File.read("views/item_create.erb"))
        render.result(binding)
    end

    def self.detail(params)
        id = params["id"]

        item = Item.get_with_categories_by_item_id(id)
    
        render = ERB.new(File.read("views/item_detail.erb"))
        render.result(binding)
    end

    def self.edit(params)
        id = params["id"]
        
        item = Item.get_with_categories_by_item_id(id)
        categories = Category.get_all

        render = ERB.new(File.read("views/item_edit.erb"))
        render.result(binding)
    end

    def self.save(params)
        name = params['name']
        price = params['price']

        item = Item.new(name, price)
        item.save
    end

    def self.update(params)
        id = params['id'];
        name = params['name']
        price = params['price']
        categories_id = params['categories_id']

        item = Item.get_with_categories_by_item_id(id)

        item.update(id, name, price)
        item.update_categories(categories_id.map(&:to_i))
    end

    def self.delete(params)
        id = params['id'];

        item = Item.get_with_categories_by_item_id(id)

        item.delete
    end
end
