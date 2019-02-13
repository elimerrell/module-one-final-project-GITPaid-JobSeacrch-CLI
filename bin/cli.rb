class CLI

def welcome
   puts "Welcome to Dev Job Hunter! Have you already signed up (y/n)?"
   sign_up_response = gets.chomp.downcase
   if sign_up_response == 'y'
     main_menu
   elsif sign_up_response == 'n'
     sign_up
   else
     puts "That's not a valid command"
     return self.welcome
   end
end

def sign_up
  puts "Welcome to Dev Job Hunter!"
  puts
  puts "Please enter your name"
  hunter_name = gets.chomp.downcase
  puts "Welcome, #{hunter_name}!"
  puts
  puts "Please enter the tecnhologies you are fluent in i.e. 'ruby,java,javascript' "
  hunter_tecnhologies = gets.chomp.downcase
  puts "Please enter your current location"
  hunter_location = gets.chomp.downcase

  #put this here for now to delete previous users
  JobHunter.destroy_all

  JobHunter.find_or_create_by(
    name: hunter_name,
    skills: hunter_tecnhologies,
    location: hunter_location
    )

  puts "Thanks for signing up, #{hunter_name}, you can now search developer jobs!"
  main_menu
end

def main_menu
  puts "What would you like to do?"
  puts
  puts "1. Search Developer Jobs"
  puts
  puts "2. See Saved Jobs"
  puts
  puts "3. Apply for job"
  main_menu_response = gets.chomp.downcase

  if main_menu_response[0] == "1"
    search_jobs
  elsif main_menu_response[0] == "2"
    saved_jobs
  elsif main_menu_response[0] == "3"
    apply_job
  end

end

def search_jobs
   puts "How would you like to search?"
   puts
   puts "1. Search by location"
   puts
   puts "2. Search by title"
   puts
   puts "3. Search by tecnhologies"
   search_jobs_response = gets.chomp.downcase

   if search_jobs_response[0] == "1"
     search_by_location
   elsif search_jobs_response[0] == "2"
     search_by_title
   elsif search_jobs_response[0] == "3"
     search_by_technologies
   end
end

def search_by_location
  puts "Please enter the location where you want to work"
  user_location_response = gets.chomp.downcase
  location = JobPosting.find_by(:location.downcase == user_location_response)
    if location
      puts "Here are the listings in that area"
      puts "#{location[:title]}"
    elsif !location
      puts "Sorry, there are no openings in that city"
    end
end

def search_by_title
puts "searching by title"

end

def search_by_technologies
  puts "searching by tecnhologies"
end


def saved_jobs

puts "here are your saved jobs"
end


def apply_job

puts "what would you like to apply for"
end





end #end of cli class