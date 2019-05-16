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

    show = db.execute("SELECT title, content FROM posts")
    #show.gsub!(/[""(){}>]/,'')
    slim(:posts, locals:{show:show})
end

get('/profile') do
    slim(:profile)
end

get('/ped') do
    slim(:ped)
end

get('/logout') do
    slim(:logout)
end

post('/logout') do
    session[:username] = nil
redirect('/')
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
        session[:id] = db.execute("SELECT userid FROM users WHERE user_name = ?", session[:username])
        idak = session[:id].first["userid"].to_i
        redirect("/")
    else
        redirect("/login")
    end
    
end


post('/ped') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    newname = params["cunam"]
    newpas = BCrypt::Password.create(params["cpass"])
    ah = session[:username]

    result = db.execute("UPDATE users SET user_name = ?, hash_pass = ? WHERE user_name = ?", [newname, newpas, ah])
    redirect('/profile')
end

post('/delete') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    nam = session[:username]

    result = db.execute("DELETE FROM users WHERE user_name = ?", nam)

    session[:username] = nil

    redirect('/')
end

get('/cpost') do
    slim(:cpost)
end

post('/cpost') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    titl = params["title"]
    msg = params["content"]
    ida = session[:id].first["userid"].to_i
    db.execute("INSERT INTO posts(userid, title, content) VALUES(?, ?, ?)", ida, titl, msg)
redirect('/')
end

