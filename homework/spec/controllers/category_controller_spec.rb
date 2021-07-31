require_relative '../../test_helper'
require_relative '../../controllers/category_controller'
require_relative '../../models/category'

describe CategoryController do
    let (:steak_without_categories) { Item.new("steak", "75000", 1) }
    let (:main_dish) { Category.new("main dish", 1, [steak_without_categories]) }
    let (:main_course) { Category.new("main_course", 1, [steak_without_categories]) }
    let (:steak) { Item.new("steak", "75000", 1, [main_dish]) }

    describe ".create" do
        it "should render items" do
            actual_render = CategoryController.create
            expected_render = ERB.new(File.read("views/category_create.erb")).result(binding)

            expect(actual_render).to  eq(expected_render)
        end
    end

    describe "#save" do
        context "when given valid parameter" do
            it "should call params with name key" do
                category_mock = double
                params = {
                    "name" => "main_dish",
                }
                
                expect(Category).to receive(:new).with(params["name"]).and_return(category_mock)
                allow(category_mock).to receive(:save) 

                CategoryController.save(params)
            end
        end
    end

    describe ".all" do
        context "when categories is (main dish)" do
            it "should render as expected_render" do
                categories = [main_dish]
    
                expect(Category).to receive(:get_all).and_return(categories)
                expected_render = ERB.new(File.read('views/all_category.erb')).result(binding)
                actual_render = CategoryController.all

                expect(actual_render).to  eq(expected_render)
            end
        end
    end
    
    describe ".detail" do
        context "when params is hash with key is id and value is main dish id" do
            it "should render main dish detail" do
                id = main_dish.id
                params = {
                    "id" => id
                }
                category = main_dish
                items = [steak]

                expect(Category).to receive(:get_with_items_by_category_id).with(id).and_return(main_dish)
                allow(main_dish).to receive(:items).and_return(items)
                expected_render = ERB.new(File.read('views/category_detail.erb')).result(binding)
                actual_render = CategoryController.detail(params)
                
                expect(actual_render).to eq(expected_render)
            end
        end
    end

    describe ".edit" do
        context "when params is hash with key is id and value is main dish id" do
            it "should render edit page with main dish data" do
                id =  main_dish.id
                params = {
                    "id" => id
                }
                category = main_dish

                expect(Category).to receive(:get_by_id).with(id).and_return(category)
                expected_render = ERB.new(File.read("views/category_edit.erb")).result(binding)
                actual_render = CategoryController.edit(params)
                
                expect(actual_render).to eq(expected_render)
            end
        end
    end

    describe ".update" do
        context "when params is hash with main dish id and main course name" do
            it "should call main dish id, main course name and main dish id" do
                params = {
                    "id" => main_dish.id,
                    "name" => main_course.name
                }
                category = main_dish

                expect(Category).to receive(:get_by_id).with(main_dish.id).and_return(category)
                expect(category).to receive(:update).with(main_course.name, main_dish.id)
    
                CategoryController.update(params)
            end
        end
    end

    describe ".delete" do
        context "when params is hash with key is id and value is main_dish id" do
            it "should call main_dish.id" do
                params = {
                    "id" => main_dish.id
                }
                category = double
    
                expect(Category).to receive(:get_by_id).with(main_dish.id).and_return(category)
                allow(category).to receive(:delete)

                CategoryController.delete(params)
            end
        end
    end
end
