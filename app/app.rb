require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

# TODO:
# update post
# destroy post

# Method connect with database
def get_db
  @db = SQLite3::Database.new 'base.db'
  @db.results_as_hash = true
  return @db
end

def get_posts
  get_db
  @posts = @db.execute 'SELECT * FROM Posts'
  @db.close
end

# Configure application
configure do
  get_db
  # create table Messages in database
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "post_title" TEXT,
      "post_body" TEXT
    )'
  @db.close
end

get '/' do
  @title = 'Our blog'

  get_posts

  erb :index
end

get '/new' do
  @title = 'New post'
  erb :new
end

post '/new' do
  @title = 'New post is posted'
  @post_title = params[:post_title]
  @post_body = params[:post_body]

  get_db
  @db.execute 'INSERT INTO Posts (post_title, post_body) VALUES (?, ?)', [@post_title, @post_body]
  @db.close

  erb :posted
end

get '/admin' do
  @title = "Admin Panel"

  get_posts

  erb :admin
end