require "sinatra"
require "sinatra/reloader"
require "sqlite3"

# TODO:
# update post
# destroy post

# Получение базы данных
def get_db
  @db = SQLite3::Database.new "base.db"
  @db.results_as_hash = true
  return @db
end

# # Получение данных из базы
# def get_posts
#   get_db
#   @posts = @db.execute "SELECT * FROM Posts"
#   @db.close
# end

# Конфигурация сервера приложения
configure do
  get_db
  # create table Messages in database
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "created_date" DATE,
      "post_title" TEXT,
      "post_body" TEXT
    )'
  @db.close
end

# Главная страница
get "/" do
  @title = "Our blog"

  erb :index
end

# Страница с постами
get "/posts" do
  @title = "Our blog"

  get_db
  @posts = @db.execute "SELECT * FROM Posts order by id desc"

  erb :posts
end

# Страница с новым постом
get "/new" do
  @title = "New post"
  erb :new
end

# Создание и сохранение нового поста
post "/new" do

  # Параметры поста
  @title = "Создание нового поста"
  @post_title = params[:post_title]
  @post_body = params[:post_body]

  # Проверка на пустоту
  if @post_title.length <= 0 || @post_body.length <= 0
    @error = "Вы должны заполнить все поля"
    return erb :new
  end

  # Сохранение поста
  get_db
  @db.execute "INSERT INTO 
              Posts (post_title, post_body, created_date) 
              VALUES (?, ?, datetime())",
              [@post_title, @post_body]
  @db.close

  erb :posted
end

# Страница админ панели
get "/admin" do
  @title = "Admin Panel"

  get_db
  @posts = @db.execute "SELECT * FROM Posts"
  @db.close

  erb :admin
end

# Пост с коментариями
get "/details/:post_id" do
  @title = "Детали поста с комментариями"

  # Получаем переменную из URL
  post_id = params[:post_id]

  # Открываем базу
  get_db

  # Выбираем один пост
  results = @db.execute "select * from Posts where id = ?", [post_id]
  @row = results[0]

  erb :details
end

post "/details/:post_id" do
  # Получаем переменную из URL
  post_id = params[:post_id]

  # Получаем переменную из формы
  @comment = params[:comment_body]

  erb "Comment added to post #{post_id}: #{@comment}"
end
