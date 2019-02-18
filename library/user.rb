load 'base.rb'

class User < Base
  attribute :full_name, String 
  attribute :password, String
  attribute :email, String

  has_many :books

  def show_books
    puts "There are no books right now!!!" if books.empty?

    books.each.with_index do |book, index| 
      puts "#{index + 1}: <#{book.title}>  #{book.author}" 
    end
  end

  def change_password(current_password, new_password, confirm_new_password)
    return nil if current_password != password || new_password != confirm_new_password || new_password == current_password
      
    update(password: new_password)
    "Your new password (#{new_password})."
  end

end
