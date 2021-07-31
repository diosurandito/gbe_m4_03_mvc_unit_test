require 'sinatra'
require_relative 'controllers/item_controller'
require_relative 'controllers/category_controller'

get '/' do
    ItemController.all
end

get '/items' do
    ItemController.all
end

get '/items/create' do
    ItemController.create
end

get '/items/:id' do
    ItemController.detail(params)
end

get '/items/:id/edit' do
    ItemController.edit(params)
end

get '/items/:id/categories' do
    ItemController.categories(params)
end

post '/items/save' do
    item = ItemController.save(params)
    redirect '/'
end

post '/items/:id/update' do
    ItemController.update(params)
    redirect '/'
end

post '/items/:id/delete' do
    ItemController.delete(params)
    redirect '/'
end

get '/categories/create' do
    CategoryController.create
end

get '/categories' do
    CategoryController.all
end

get '/categories/:id' do
    CategoryController.detail(params)
end

get '/categories/:id/items' do
    CategoryController.items(params)
end

get '/categories/:id/edit' do
    CategoryController.edit(params)
end

post '/categories/save' do
    CategoryController.save(params)
end

post '/categories/:id/delete' do
    CategoryController.delete(params)
    redirect '/categories'
end

post '/categories/:id/update' do
    CategoryController.update(params)
    redirect '/categories'
end
