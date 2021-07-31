require_relative '../../db/mysql_connector'
require_relative '../../models/item'

describe Item do
    let (:main_dish) { Category.new("main dish", 1) }
    let (:beverage) { Category.new("beverage", 2) }
    let (:rujak) { Item.new("rujak", "75000", 1, [main_dish]) }
    let (:fried_rice) { Item.new("fried_rice", "15000", 1, [main_dish]) }
    let (:ice_cream) { Item.new("ice cream", "5000", 2, [beverage]) }

    describe "#save" do
        context "when item valid?" do
            it "should call mock sql client and call insert_query" do
                mock_client = double
                insert_query = "insert into items (name, price) values ('#{rujak.name}', #{rujak.price})"
                
                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(insert_query)

                rujak.save
            end
        end
    end

    describe "#valid?" do
      context "when initialize with valid item" do
        it "initialize with valid item" do
            expect(rujak.valid?).to be_truthy
        end
      end
    end
    
    describe "#update" do
        context "when update successful" do
            it "should call mock sql client and call update_query" do
                mock_client = double
                update_query = "update items set name = '#{fried_rice.name}', price = #{fried_rice.price} where id = #{rujak.id}"

                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(update_query)

                rujak.update(rujak.id, fried_rice.name, fried_rice.price)
            end
        end
    end

    describe "#update_categories" do
        context "when categories_id is [1, 2, 3]" do
            it "should call update_categories_query_with_new_categories with first index of mock_new_categories_id and 
            update_categories_query_with_delete_categories with first index of mock_delete_categories_id" do
                categories_id = [2, 3]
                mock_client = double
                mock_new_categories_id = [2]
                mock_delete_categories_id = [1]
                update_categories_query = "insert into item_categories(item_id, category_id) values (#{rujak.id}, #{mock_new_categories_id.first})"
                delete_categories_query = "delete from item_categories where category_id = '#{mock_delete_categories_id.first}'"
                
                expect(rujak).to receive(:get_new_categories).with(categories_id).and_return(mock_new_categories_id)
                expect(rujak).to receive(:get_delete_categories).with(categories_id).and_return(mock_delete_categories_id)
                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(update_categories_query)
                expect(mock_client).to receive(:query).with(delete_categories_query)

                rujak.update_categories(categories_id)
            end
        end
    end
    
    describe "#get_new_categories" do
        context "item have new 1 category" do
            it "should add return 1 category" do
                categories_id = [1, 2]
                expected = [2]

                result = rujak.get_new_categories(categories_id)

                expect(result).to  eq(expected)
            end
        end
    end

    describe "#get_delete_categories" do
        context "when item had 1 deleted category" do
            it "should return 1 deleted category" do
                categories_id = [2]
                expected = [1]

                result = rujak.get_delete_categories(categories_id)

                expect(result).to  eq(expected)
            end
        end
    end

    describe "#delete" do
        it "should call mock sql client and call delete_query" do
            mock_client = double
            item_categories_query = "delete from item_categories where item_id = #{rujak.id}"
            items_query = "delete from items where id = #{rujak.id}"

            allow(Mysql2::Client).to receive(:new).and_return(mock_client)
            expect(mock_client).to receive(:query).with(item_categories_query)
            expect(mock_client).to receive(:query).with(items_query)

            rujak.delete
        end
    end

    describe ".get_all" do
        it "should call select_query" do
            mock_client = double
            select_query = "select * from items"
            mock_raw_data = [
                {
                    "name" => rujak.name,
                    "price" => rujak.price,
                    "id" => rujak.id
                }
            ]
            
            allow(Mysql2::Client).to receive(:new).and_return(mock_client)
            expect(mock_client).to receive(:query).with(select_query).and_return(mock_raw_data)

            Item.get_all
        end
    end

    describe ".get_by_id" do
        context "when id is 1" do
            it "should call select_query_with_id 1" do
                mock_client = double
                id = 1
                select_query_with_id = "select items.id, items.name, items.price from items where items.id = #{id}"
                mock_raw_data = [
                    {
                        "name" => rujak.name,
                        "price" => rujak.price,
                        "id" => rujak.id
                    }
                ]

                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(select_query_with_id).and_return(mock_raw_data)

                Item.get_by_id(id)
            end
        end
    end

    describe ".get_by_category_id" do
        context "when items are rujak and category_id is 1" do
            it "should call select_query_get_by_category_id 1 and return 1 item" do
                mock_client = double
                category_id = 1
                select_query_get_by_category_id = "select * from items join item_categories on items.id = item_categories.item_id where item_categories.category_id = #{category_id}"
                mock_raw_data = [
                    {
                        "name" => rujak.name,
                        "price" => rujak.price,
                        "id" => rujak.id
                    }
                ]
                expected = rujak

                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(select_query_get_by_category_id).and_return(mock_raw_data)

                item = Item.get_by_category_id(category_id)
                expect(item[0].name).to eq(expected.name)
                expect(item[0].price).to eq(expected.price)
                expect(item[0].id).to eq(expected.id)
            end
        end
    end
    
    describe ".get_with_categories_by_item_id" do
        it "should call item.get_by_id with item_id argument and category.get_by_id with item_id argument and return item with categories" do
            rujak_without_category = Item.new("rujak", "75000", 1)
            item_id = 1
            expected = rujak

            expect(Item).to receive(:get_by_id).with(item_id).and_return(rujak_without_category)
            expect(Category).to receive(:get_by_item_id).with(item_id).and_return(rujak)
   
            item_with_categories = Item.get_with_categories_by_item_id(item_id)
            expect(item_with_categories.name).to eq(expected.name)
            expect(item_with_categories.price).to eq(expected.price)
            expect(item_with_categories.id).to eq(expected.id)
        end
    end

    describe ".get_all_with_price_lower_than" do
        context "when price is 50000" do
            it "should call select_query_get_all_with_price_lower_than with 50000" do
                price = 50000
                select_query_get_all_with_price_lower_than = "select * from items where price < #{price}"
                mock_client = double
                mock_raw_data = [
                    {
                        "name" => ice_cream.name,
                        "price" => ice_cream.price,
                        "id" => ice_cream.id
                    }
                ]

                allow(Mysql2::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with(select_query_get_all_with_price_lower_than).and_return(mock_raw_data)

                Item.get_all_with_price_lower_than(price)
            end
        end
    end

end

