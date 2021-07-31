require_relative '../../test_helper'
require_relative '../../models/category'

describe Category do
    let (:steak_without_categories) { Item.new("steak", "75000", 1) }
    let (:main_dish) { Category.new("main dish", 1, [steak_without_categories]) }
    let (:main_course) { Category.new("main_course", 1, [steak_without_categories]) }
    let (:steak) { Item.new("steak", "75000", 1, [main_dish]) }

    describe "#save" do
        context "when item valid?" do
            it "should call mock sql client and call insert_query" do
                mock_client = double
                insert_query = "insert into categories(name) values ('#{main_dish.name}')"
                
                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(insert_query)

                main_dish.save
            end
        end
    end

    describe "#valid?" do
        context "when initialize with valid item" do
            it "should true" do
                expect(main_dish.valid?).to be_truthy
            end
        end
    end

    describe "#update" do
        context "when update successful" do
            it "should call mock sql client and call update_query" do
                mock_client = double
                update_query = "update categories set name = '#{main_course.name}' where id = #{main_dish.id}"

                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(update_query)

                main_dish.update(main_course.name, main_dish.id)
            end
        end
    end

    describe "#delete" do
        it "should call mock sql client and call delete_item_categories_query and delete_categories_query" do
            mock_client = double
            delete_item_categories_query = "delete from item_categories where category_id = #{main_dish.id}"
            delete_categories_query = "delete from categories where id = #{main_dish.id}"

            allow(Mysql2::Client).to receive(:new).and_return(mock_client)
            expect(mock_client).to receive(:query).with(delete_item_categories_query)
            expect(mock_client).to receive(:query).with(delete_categories_query)

            main_dish.delete
        end
    end

    describe ".get_all" do
        it "should call select_query" do
            mock_client = double
            select_query = "select * from categories"
            mock_raw_data = [
                {
                    "name" => main_dish.name,
                    "id" => main_dish.id
                }
            ]
            expected = main_dish
            
            allow(Mysql2::Client).to receive(:new).and_return(mock_client)
            expect(mock_client).to receive(:query).with(select_query).and_return(mock_raw_data)

            actual_result = Category.get_all
            expect(actual_result[0].name).to eq(expected.name)
            expect(actual_result[0].id).to eq(expected.id)
        end
    end
    
    describe ".get_by_id" do
        it "should call get_by_id_query and return expected_category" do
            mock_client = double
            id = main_dish.id
            get_by_id_query = "select * from categories where categories.id = #{id}"
            mock_raw_data = [
                {
                    "name" => main_dish.name,
                    "id" => main_dish.id
                }
            ]
            expected_category = main_dish
            
            allow(Mysql2::Client).to receive(:new).and_return(mock_client)
            expect(mock_client).to receive(:query).with(get_by_id_query).and_return(mock_raw_data)
   
            actual_result = Category.get_by_id(id)
            expect(actual_result.name).to eq(expected_category.name)
            expect(actual_result.id).to eq(expected_category.id)
        end
    end

    describe ".get_by_item_id" do
        it "should call get_by_item_id_query and return expected_category" do
            mock_client = double
            item_id = steak.categories[0].id
            get_by_item_id_query = "select * from categories join item_categories on categories.id = item_categories.category_id where item_categories.item_id = #{item_id}"
            mock_raw_data = [
                {
                    "name" => main_dish.name,
                    "id" => main_dish.id
                }
            ]
            expected_category = main_dish

            allow(Mysql2::Client).to receive(:new).and_return(mock_client)
            expect(mock_client).to receive(:query).with(get_by_item_id_query).and_return(mock_raw_data)
   
            actual_result = Category.get_by_item_id(item_id)
            expect(actual_result[0].name).to eq(expected_category.name)
            expect(actual_result[0].id).to eq(expected_category.id)
        end
    end

    describe ".get_with_items_by_category_id" do
        it "should call category_id return category with items" do
            mock_client = double
            category_id = main_dish.id
            mock_category = main_dish
            mock_items = [steak_without_categories]
            expected_category = main_dish

            expect(Category).to receive(:get_by_id).with(category_id).and_return(mock_category)
            expect(Item).to receive(:get_by_category_id).with(category_id).and_return(mock_items)

            actual_result = Category.get_with_items_by_category_id(category_id)
            expect(actual_result.name).to eq(expected_category.name)
            expect(actual_result.id).to eq(expected_category.id)
        end
    end
end
