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

# Конфигурация сервера приложения
configure do
  get_db

  # Создание таблицы Posts в базе данных
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "created_date" DATE,
      "post_title" TEXT,
      "post_body" TEXT
    )'

  # Создание таблицы Comments в базе данных
  @db.execute 'CREATE TABLE IF NOT EXISTS "Comments"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "created_date" DATE,
      "post_id" INTEGER,
      "comment_body" TEXT
    )'

  # Создание таблицы Users в базе данных
  @db.execute 'CREATE TABLE IF NOT EXISTS "Users"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "created_date" DATE,
      "username" TEXT,
      "post_id" INTEGER,
      "comment_id" INTEGER
    )'

  @db.close
end

# Главная страница
get "/" do
  @title = "Наш блог"

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
  @title = "Новый пост"
  erb :new
end

# Создание и сохранение нового поста
post "/new" do

  # Параметры поста
  @title = "Создание нового поста"
  @post_title = params[:post_title]
  @post_body = params[:post_body]

  @username = params[:username]

  # Проверка на пустоту
  if @post_title.length <= 0 || @post_body.length <= 0
    @error = "Вы должны заполнить все поля"
    return erb :new
  end

  # Сохранение поста
  get_db
  @db.execute "INSERT INTO Posts 
              (post_title, post_body, created_date) 
              VALUES (?, ?, datetime())",
              [@post_title, @post_body]

  post_id = @db.last_insert_row_id

  @db.execute "INSERT INTO Users 
              (username, post_id, created_date) 
              VALUES (?, ?, datetime())",
              [@username, post_id]
  @db.close

  # erb :posted
  redirect to "/posts"
end

# Страница админ панели
get "/admin" do
  @title = "Панель администратора"

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

  # Выбираем один пост и пользователя
  row_posts = @db.execute "select * from Posts where id = ?", [post_id]
  @row_users = @db.execute "select * from Users"

  @row_post = row_posts[0]

  # Выбираем комментарии для поста
  @comments = @db.execute "select * from Comments where post_id = ? order by created_date desc", [post_id]
  @users = @db.execute "select * from Users"
  erb :details
end

post "/details/:post_id" do

  # Получаем переменную из URL
  post_id = params[:post_id]
  username = params[:username]

  # Получаем переменную из формы
  comment = params[:comment_body]

  # Валидация введения комментария
  if comment.empty? || username.empty?
    @error = "Вы должны ввести комментарий"
    redirect to ("/details/" + post_id)
  end

  # Сохранение комментария и Имя пользователя
  get_db

  # Добавления комментария
  @db.execute "INSERT INTO Comments 
              (comment_body, post_id, created_date) 
              VALUES (?, ?, datetime())",
              [comment, post_id]

  comment_id = @db.last_insert_row_id

  # Добавление имени пользователя
  @db.execute "INSERT INTO Users 
              (username, comment_id, created_date) 
              VALUES (?, ?, datetime())",
              [username, comment_id]

  @db.close

  # Перенаправление на страницу поста с комментариями
  redirect to ("/details/" + post_id)
end
