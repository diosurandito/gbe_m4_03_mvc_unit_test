require './exercise/controllers/item_controller'
require './exercise/models/item'
require './exercise/db/mysql_connector'

describe ItemController do
    describe '#save' do
        context 'with valid object' do
            it 'should save to database' do
                item = Item.new('Krupuk', 500)

                mock_client = double
                allow(Mysql::Client).to receive(:new).and_return(mock_client)
                expect(mock_client).to receive(:query).with("insert into items (name, price) values ('#{item.name}', #{item.price})")
                
                expect(order.save).to eq(true)
                
            end
        end
        
    end
end