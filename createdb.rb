# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :classes do
  primary_key :id
  String :title
  String :description, text: true
  String :teacher
  String :date
  String :location
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :class_id
  foreign_key :user_id
  Boolean :going
  String :comments, text: true
end

DB.create_table! :users do
    primary_key :id
    String :name
    String :email
    String :password
end 

# Insert initial (seed) data
classes_table = DB.from(:classes)

classes_table.insert(title: "Pilates Fusion", 
                    description: "Combine classic mat pilates with cardio bursts!",
                    teacher: "Allison",
                    date: "June 1",
                    location: "Studio A")

classes_table.insert(title: "Barre Basics", 
                    description: "Calling all dancers. The isometric movements in this classic barre class will leave your legs burning!",
                    teacher: "Allison",
                    date: "July 1",
                    location: "Studio B")
