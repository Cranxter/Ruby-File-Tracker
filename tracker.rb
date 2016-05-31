require 'pg'
require 'yomu'


class File_upload

	attr_accessor :File_name
	attr_accessor :Extension
	attr_accessor :f_name

	def initialize(data_base,user_name,pass)

		@username=user_name
		@password=pass
		@database=data_base
		@Author="NA"
		@Creation_Date="NA"
		@Content_Type="NA"
		@Last_Modified="NA"

		@File_name="NULL"
		@Extension="NULL"
	end	

	def connect()

		@conn=PGconn.connect("localhost",5432,'','',@database,@username,@password)

	end

	def create_table()

		#@conn.exec("CREATE EXTENSION hstore ;")	

		begin

			@conn.exec("SELECT id from File_table;")
		rescue
		else
			puts "Similar table already exists"
			puts "DELETING TABLE.... AND CREATING NEW ONE... "
			puts "\n"
			res=@conn.exec("DROP TABLE File_table")	
			
		end	

		puts "CREATING TABLE \"File_table\""
		@conn.exec("CREATE TABLE File_table(id serial,Name varchar(100),Extension varchar(20),Content_Type varchar(100),Author varchar(100),Creation_Date varchar(100),Last_Modified varchar(100),Title varchar(100) , Image_Width varchar(100),Image_Height varchar(100));" )
	end	

	def add_fields()
		
		@conn.exec("INSERT INTO File_table(Name,Extension,Content_Type,Author,Creation_Date,Last_Modified,Title,Image_Width,Image_Height) VALUES ('#{@File_name}','#{@Extension}','#{@Content_Type}','#{@Author}','#{@Creation_Date}','#{@Last_Modified}','#{@Title}','#{@Image_Width}','#{@Image_Height}');")
		
		rescue Postgres::PGError => e
			puts "Error ."
			p "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
	end	

	def delete_fields(row_id)

		@conn.exec("DELETE FROM File_table WHERE id=#{row_id}")

	end	

	def display_table()
		p "display"
		res=@conn.exec("SELECT * FROM File_table") 
		res.each {|row| print row}
	end			


	def metadata()

		attr_hash=Hash.new

		
		data= File.read(f_name)
		text= Yomu.read :text, data
		metadata=Yomu.read :metadata, data
		mime= Yomu.read :mimetype, data
		#p mime
		#p metadata

		if (metadata.key?('producer')==true)
			@Author=metadata['producer']
		else	
			@Author=metadata['Author']
		end	

		 @Content_Type=metadata['Content-Type']
		if(metadata.key?("File Modified Date")==true)
			@Last_Modified=metadata['File Modified Date'] 
		else	
			@Last_Modified=metadata['Last-Modified'] 
		end	
		@Image_Width=metadata['tiff:ImageLength']
		@Image_Height=metadata['tiff:ImageWidth']
		@Creation_Date=metadata['Creation-Date']	
		@Title=metadata['title']     #pdf

		["Author","Content-Type","Creation-Date","title"].each {|k| metadata.delete(k)}
		
		attr_hash=metadata

	end	

	def close_conn()
		
		@conn.close()
	end	

	
end

#main

puts "\n"
puts "ENTER THE DETAILS FOR ESTABLISHING DATABASE CONNECTION "
puts "\n"

begin
puts "DataBase:"
datab=gets.chomp()
puts "Username:"
user=gets.chomp()
puts "Password:"
pass=gets.chomp()

obj=File_upload.new(datab,user,pass)

# CREATE USER DATABASE TABLE
obj.connect()
rescue
	puts "INCOREECT DETAILS....RETRY"
retry
end

puts "\n"
puts "CONNECTED TO DATABASE"	
obj.create_table()

while(true)

	puts "\n"
	puts "\t ENTER YOUR CHOICE \n\n\t1)Add an entry\n\t2)Remove an entry\n\t3)Display data in Table\n\t4)EXIT "


	ch=gets.chomp.to_i
	case ch
		when 1

			begin

			puts "\n"	
			puts "ENTER THE PATH OF THE FILE"
			obj.f_name=gets.chomp

			File.read(obj.f_name)
			rescue
				puts "ENTER VALID FILE PATH....RETRY"
			retry
			end	
			values=obj.f_name.split('.')
		 	obj.File_name=values[0]
		 	file_path=obj.File_name.split('/')
		 	obj.File_name=file_path[-1]
			obj.Extension=values[1]

#OBTAINING METADATA
			puts "Evaluating ..."

			obj.metadata()    
			obj.add_fields()

		when 2
		
			puts "ENTER THE ID OF THE ROW YOU WANT TO DELETE"
			row_id=gets.chomp
			obj.delete_fields(row_id)

		when 3

			puts " DISPLAYING TABLE ENTRIES"
			obj.display_table()

		when 4

			obj.close_conn()

			break
		else
			puts "Wrong option TRY AGAIN ..."	

	end		

end



