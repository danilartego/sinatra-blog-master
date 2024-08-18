Урок 28

> Мой вариант Sinatra Blog: [GitHub - krdprog/sinatra-blog: Sinatra blog repository.](https://github.com/krdprog/sinatra-blog)

#### Перенаправление:

```ruby
post '/new'
  # some code

  redirect to '/'
end
```

```ruby
  redirect to ('/post/' + @post_id)
```

#### id поста:

app.rb

```ruby
get '/post/:post_id' do
  @post_id = params[:post_id]
  erb :post
end
```

views/post.erb

```ruby
This is post: <%= @post_id %>
```

#### Домашнее задание:

1. Авторизация для автора
2. Валидация поля комментария

#### Ссылка на документацию Sinatra:

- [sinatra/README.ru.md at master · sinatra/sinatra · GitHub
