class CategoryController
    def self.create
        render = ERB.new(File.read('views/category_create.erb'))
        render.result(binding)
    end

    def self.save(params)
        name = params["name"]

        category = Category.new(name)
        category.save
    end

    def self.all
        categories = Category.get_all

        render = ERB.new(File.read('views/all_category.erb'))
        render.result(binding)
    end

    def self.detail(params)
        id = params["id"]

        category = Category.get_with_items_by_category_id(id)
        items = category.items

        render = ERB.new(File.read("views/category_detail.erb"))
        render.result(binding)
    end

    def self.edit(params)
        id = params['id'];
        category = Category.get_by_id(id)

        render = ERB.new(File.read("views/category_edit.erb"))
        render.result(binding) 
    end

    def self.update(params)
        id = params['id'];
        name = params['name'];

        category = Category.get_by_id(id)

        category.update(name, id)
    end

    def self.delete(params)
        id = params['id'];

        category = Category.get_by_id(id)

        category.delete
    end
end
