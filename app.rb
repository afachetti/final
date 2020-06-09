# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

classes_table = DB.from(:classes)
rsvps_table = DB.from(:rsvps)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(:id=>session[:user_id]).to_a[0]
    puts @current_user.inspect
    results = Geocoder.search("800 Elgin Rd, Evanston, IL 60201")
    @lat_long = results.first.coordinates.join(",") 
end

get "/" do 
    @classes = classes_table.all
    puts @classes.inspect
    view "classes"
end 

get "/classes/:id" do 
    @users_table = users_table 
    @class = classes_table.where(:id => params["id"]).to_a[0]
    @rsvps = rsvps_table.where(:class_id => params["id"]).to_a
    @count = rsvps_table.where(:class_id => params["id"], :going => 1).count
    puts @class.inspect
    view "class"
end     

get "/classes/:id/rsvps/new" do 
    @class = classes_table.where(:id => params["id"]).to_a[0]
    view "new_rsvp"
end 

post "/classes/:id/rsvps/create" do
    rsvps_table.insert(:class_id => params["id"],
                       :going => params["going"],
                       :user_id => @current_user[:id],
                       :comments => params["comments"])
    @class = classes_table.where(:id => params["id"]).to_a[0]
    view "create_rsvp"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do 
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => BCrypt::Password.create(params["password"]))
    view "create_user"
end 

get "/logins/new" do 
    view "new_login"
end 

post "/logins/create" do 
    emailentered = params["email"]
    passwordentered = params["password"]
    user = users_table.where(:email => emailentered).to_a[0]
    if user
        puts user.inspect
        if BCrypt::Password.new(user[:password])==passwordentered
            session[:user_id] = user[:id]
            view "create_login"
        else 
            view "create_login_failed"
        end 
    else
    view "create_login_failed"
    end 
end 

get "/logout" do 
    session[:user_id] = nil 
    view "logout"
end 