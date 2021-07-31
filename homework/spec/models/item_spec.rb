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

end

