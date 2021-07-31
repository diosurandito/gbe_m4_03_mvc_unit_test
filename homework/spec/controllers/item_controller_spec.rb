require_relative '../../test_helper'
require_relative '../../controllers/item_controller'
require_relative '../../models/item'

describe ItemController do
    let (:dessert) { Category.new("dessert", 3) }
    let (:main_dish) { Category.new("main dish", 1) }
    let (:ice_cream) { Item.new("ice cream", "5000", 2, [dessert]) }
    let (:steak) { Item.new("steak", "75000", 1, [main_dish]) }

    describe ".all" do
        context "when items is (ice_cream)" do
            it "should render items" do
                mock_items = [ice_cream]
                items = mock_items
    
                expect(Item).to receive(:get_all).and_return(mock_items)
                expected_render = ERB.new(File.read("views/all_item.erb")).result(binding)
                actual_render = ItemController.all

                expect(actual_render).to  eq(expected_render)
            end
        end
    end

    describe ".create" do
        it "should render items" do
            actual_render = ItemController.create
            expected_render = ERB.new(File.read("views/item_create.erb")).result(binding)

            expect(actual_render).to  eq(expected_render)
        end
    end
    
    describe ".detail" do
        context "when params is hash with key is id and value is ice_cream id" do
            it "should render ice cream detail" do
                params = {
                    "id" => ice_cream.id
                }
                mock_item = ice_cream
                item = mock_item

                expect(Item).to receive(:get_with_categories_by_item_id).and_return(mock_item)
                expected_render = ERB.new(File.read("views/item_detail.erb")).result(binding)
                actual_render = ItemController.detail(params)
                
                expect(actual_render).to eq(expected_render)
            end
        end
    end

    describe ".edit" do
        context "when params is hash with key is id and value is ice_cream id" do
            it "should render edit page with ice cream data and categories" do
                params = {
                    "id" => ice_cream.id
                }
                mock_item = ice_cream
                mock_categories = [dessert]
                item = ice_cream
                categories = [dessert]

                expect(Item).to receive(:get_with_categories_by_item_id).with(ice_cream.id).and_return(mock_item)
                expect(Category).to receive(:get_all).and_return(mock_categories)
                expected_render = ERB.new(File.read("views/item_edit.erb")).result(binding)
                actual_render = ItemController.edit(params)
                
                expect(actual_render).to eq(expected_render)
            end
        end
    end
    
    describe "#save" do
        context "when given valid parameter" do
            it "should create new instance with Item.new and the result call save" do
                item_mock = double
                params = {
                    "name" => "book",
                    "price" => "75000"
                }
                
                expect(Item).to receive(:new)
                    .with(params["name"], params["price"])
                    .and_return(item_mock)
                expect(item_mock).to receive(:save) 

                ItemController.save(params)
            end
        end
    end

    describe ".update" do
      context "when params is hash with ice_cream id, steak name, steak price and main dish id" do
        it "should call update with ice cream, steak name, steak price argument and call update_categories with categories_id" do
            mock_item = ice_cream
            categories_id = [main_dish.id]
            params = {
                "id" => ice_cream.id,
                "name" => steak.name,
                "price" => steak.price,
                "categories_id" => categories_id
            }

            expect(Item).to receive(:get_with_categories_by_item_id).with(ice_cream.id).and_return(mock_item)
            expect(ice_cream).to receive(:update).with(ice_cream.id, steak.name, steak.price)
            expect(ice_cream).to receive(:update_categories).with(categories_id)

            ItemController.update(params)
        end
      end
    end
    
    describe ".delete" do
        context "when params is hash with key is id and value is ice_cream id" do
            it "should call Item.get_with_categories_by_item_id with ice cream id and call ice_cream#delete" do
                params = {
                    "id" => ice_cream.id
                }
                mock_item = ice_cream
    
                expect(Item).to receive(:get_with_categories_by_item_id).with(ice_cream.id).and_return(mock_item)
                expect(ice_cream).to receive(:delete)

                ItemController.delete(params)
            end
        end
    end
end

