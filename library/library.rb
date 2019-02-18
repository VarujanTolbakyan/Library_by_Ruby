require_relative "user"
require_relative "book"

def dashboard_menu(user)
  print "\n<Hello #{user.full_name}>\n\n"
  specified_num_for_dasboard = ""
  until specified_num_for_dasboard == "3"
      
    puts "Dashboard"

    specified_num_for_dasboard = build_menu('My account', 'My books', 'Log out')
      
    case specified_num_for_dasboard
    when "1"
      specified_num_for_my_accont = ""

      until specified_num_for_my_accont == "3"

        puts "\nMy account"

        specified_num_for_my_accont = build_menu('Edit person info', 'Change password', 'Back')

        case specified_num_for_my_accont
        when "1"
          print "New full name: "
          new_full_name = gets.chomp
          new_full_name = user.full_name if new_full_name.empty?
          print "New email: "
          new_email = gets.chomp
          new_email = user.email if new_email.empty?
          user.update(full_name: new_full_name, email: new_email)
        when "2"
          user_change_password = nil

          while user_change_password.nil?
            print "Current password: "
            current_password = gets.chomp    
            print "New password: "
            new_password = gets.chomp
            print "Confirm new password: "
            confirm_new_password = gets.chomp

            user_change_password = user.change_password(current_password, new_password, confirm_new_password)
            print "\nPlease enter correct options!\n\n" if user_change_password.nil?
          end
          puts "\n" + user_change_password
        end
      end
    when "2"
      specified_num_for_my_books = ""
      until specified_num_for_my_books == "4"
        puts "\nMy books"
        
        build_menu('Add new book', 'Show books', 'Choose a book', 'Back') do |specified_num_for_my_books|
          puts
          case specified_num_for_my_books
          when "1"
            new_book = Book.new
            print "Enter book title: "
            book_title = gets.chomp
            print "Enter author of the book: "
            book_author = gets.chomp
            Book.create(title: book_title, author: book_author, user_id: user.id)
          when "2"
            user.show_books
          when "3"
            puts "Choose a book\n\n"
            user.show_books
            unless user.books.empty?
              print "\nSelect a book by number(1, 2, 3 ...): "
              book_num = gets.to_i

              until book_num > 0 && book_num <= user.books.count
                print "Please enter correct number: "
                book_num = gets.to_i
              end

              selected_book = user.books[book_num - 1]
              specified_num_for_my_book = build_menu('Edit', 'Delete', 'Back')

              case specified_num_for_my_book
              when "1"
                print "Enter new title: "
                new_title = gets.chomp
                selected_book.title = new_title unless new_title.empty?

                print "Enter new author: "
                new_author = gets.chomp
                selected_book.author = new_author unless new_author.empty?

                print "\nDo you want to confirm (y/n): "
                selected_book.save if gets.chomp == "y"
                puts

              when "2"
                print "\nDo you want to confirm (y/n): "
                yes_or_no = gets.chomp
                puts
                if yes_or_no == "y"
                  user.books[book_num - 1].delete
                end
              end
            end
          end
        end
      end
    end
  end
end

def build_menu(*option)
  puts
  check_num = ""
  option.each.with_index do |el, index|
    puts "#{index + 1}.#{el}"
    check_num += "#{index + 1}, "
  end

  print "\nWhat action do you want to specify?(#{check_num}): "
  specified = gets.chomp
  puts

  while specified.to_i > option.count || specified.to_i < 1
      print "Please enter (#{check_num}): "
      specified = gets.chomp
  end
  if block_given?
    yield specified
  else
    specified
  end
end


puts "Library"

specified = build_menu('Sign Up', 'Log in')

case specified
when "1"
    print "full_name: "
    full_name = gets.chomp
    print "email: "
    email = gets.chomp
    print "password: "
    password = gets.chomp
    print "repeat password: "
    repeat_password = gets.chomp

    
    user = User.create(full_name: full_name, email: email, password: password)
    dashboard_menu(user)
when "2"
  users = []

  while users.empty?
    print "email: "
    email = gets.chomp
    print "password: "
    password = gets.chomp
    users = User.where(email: email, password: password)
    puts "\nplease enter correct email or password:" if users.empty?
  end
    dashboard_menu(users.first)
end

