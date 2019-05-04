require 'bcrypt'
require 'slim'
require 'sqlite3'
require 'sinatra'
enable :sessions

get('/') do
    slim(:index)
end

get('/posts') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    @show = db.execute("SELECT title, content FROM posts").to_s
    @show.gsub!(/[""(){}>]/,'')
    slim :posts
end

get('/profile') do
    slim(:profile)
end

get('/reg') do
    slim(:reg)
end

post('/reg') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    unam = params["username"]
    pas = BCrypt::Password.create(params["password"])
    session[:username] = unam

    result = db.execute("INSERT INTO users (user_name, hash_pass) VALUES (?, ?)", [unam, pas])
    redirect('/')
end

get('/login') do
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    result = db.execute("SELECT user_name, hash_pass FROM users WHERE users.user_name=?", params["username"])
    if result.length > 0 && BCrypt::Password.new(result.first["hash_pass"]) == params["password"]

        username = db.execute("SELECT user_name FROM users")
        username.each do |row|
            username = row['user_name']
        end

        session[:createlogin] = "login"
        session[:username] = username
        redirect("/")
    else
        redirect("/login")
    end
end

get('/cpost') do
    slim(:cpost)
end

post('/cpost') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    titl = params["title"]
    msg = params["content"]

    db.execute("INSERT INTO posts (title, content) VALUES(?, ?)", [titl, msg])
    db.execute("SELECT posts.userid, users.user_name FROM posts INNER JOIN users ON posts.userid = users.userid")
redirect('/')
end

