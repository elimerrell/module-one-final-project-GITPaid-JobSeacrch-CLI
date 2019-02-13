class CLI

def welcome
   puts "Welcome to Dev Job Hunter! Have you already signed up (y/n)?".colorize(:green)
   sign_up_response = gets.chomp.downcase
   if sign_up_response == 'y'
     main_menu
   elsif sign_up_response == 'n'
     sign_up
   else
     puts "That's not a valid command".colorize(:red)
     return self.welcome
   end
end

def sign_up
    puts "Welcome to the Dev Job Hunter sign up!".colorize(:green)
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

    puts "Thanks for signing up, #{hunter_name}, you can now search developer jobs!".colorize(:green)
    main_menu
end

def main_menu
    puts
    puts "What would you like to do?".colorize(:green)
    puts "---------------------"
    puts "1. Search Developer Jobs".colorize(:color => :light_blue, :background => :white)
    puts "---------------------"
    puts "2. See Saved Jobs".colorize(:color => :light_blue, :background => :white)
    puts "---------------------"
    puts "3. Apply for job".colorize(:color => :light_blue, :background => :white)
    puts "---------------------"
    main_menu_response = gets.chomp.downcase

    if main_menu_response[0] == "1"
      search_jobs
    elsif main_menu_response[0] == "2"
      saved_jobs
    elsif main_menu_response[0] == "3"
      apply_job
    else
      puts "That is not a valid command".colorize(:red)
      main_menu
    end
end

def search_jobs
   puts
   puts "How would you like to search?".colorize(:green)
   puts
   puts "1. Search by location".colorize(:color => :light_blue, :background => :white)
   puts "---------------------"
   puts "2. Search by title".colorize(:color => :light_blue, :background => :white)
   puts "---------------------"
   puts "3. Search by tecnhologies".colorize(:color => :light_blue, :background => :white)
   puts "---------------------"
   search_jobs_response = gets.chomp.downcase

   if search_jobs_response[0] == "1"
     search_by_location
   elsif search_jobs_response[0] == "2"
     search_by_title
   elsif search_jobs_response[0] == "3"
     search_by_technologies
   else
     puts "That is not a valid command".colorize(:red)
     search_jobs
   end
end

def search_by_location
  puts
  puts "Please enter the location where you want to work".colorize(:green)
  user_location_response = gets.chomp.downcase
   jobs_by_location = JobPosting.joins(:branch).where('LOWER(branches.location) LIKE ?', "%#{user_location_response}%")
   if jobs_by_location.count > 0
      puts "Here are the jobs in your area:".colorize(:green)
      puts
      puts jobs_by_location.each_with_index.map {|job,index| puts "#{index + 1}. #{job[:title]}"}
      puts
      puts "Please enter the number for the job you would like to save: "
      user_saved_response = gets.chomp.to_i
      if user_saved_response >= 0 && user_saved_response <= jobs_by_location.count
        job = jobs_by_location[user_saved_response - 1]
        hunter = JobHunter.last['id']
        posting = JobPosting.find(job["id"])['id']
        
        # SavedPosting.destroy_all

        SavedPosting.find_or_create_by(
          job_hunter_id: hunter,
          job_posting_id: posting
        )
        # binding.pry
        puts "This job has been saved to your favorites."
      else
        puts "Please enter a valid response"
        search_by_location
      end
    else
      puts "Sorry, there are no jobs in your area".colorize(:red)
      search_by_location
    end
    main_menu
end

def search_by_title
  puts
  puts "Please enter the job title you would like to search".colorize(:green)
  user_job_title_response = gets.chomp.downcase
  jobs_by_title = JobPosting.where("job_postings.title LIKE ?", "%#{user_job_title_response}%")
  if jobs_by_title.count > 0
    puts "Here are the current openings with similar titles:".colorize(:green)
    puts
    puts jobs_by_title.each_with_index.map {|job,index| puts "#{index + 1}. #{job[:title]}"}
    puts
    puts "Please enter the number for the job you would like to save: "
      user_saved_response = gets.chomp.to_i
      binding.pry
      if user_saved_response >= 0 && user_saved_response <= jobs_by_title.count
        job = jobs_by_title[user_saved_response - 1]
        hunter = JobHunter.last['id']
        posting = JobPosting.where(id: job["id"])
        SavedPosting.find_or_create_by(
          job_hunter: hunter,
          job_posting: posting
        )
        puts "This job has been saved to your favorites."
      else
        puts "Please enter a valid response"
        search_by_title
      end
  else
    puts "Sorry, there are no jobs that match this title".colorize(:red)
    search_by_title
  end
end

def search_by_technologies
  puts "Please enter the technology you would like to find: "
  user_technology_response = gets.chomp

  jobs_by_technology = JobPosting.all.select do |job|
    (job.description =~ /(?i)#{user_technology_response}/)
  end

  if jobs_by_technology.count > 0
    puts "Awesome search, broh! Here are the jobs that match your search: "
    puts
    puts jobs_by_technology.each_with_index.map {|job,index| puts "#{index + 1}. #{job[:title]}"}
  else
    puts "Dang, broh... Your search didn't turn up any results."
    puts
    search_jobs
  end
  main_menu
end

def saved_jobs

puts "here are your saved jobs"
end


def apply_job

puts "what would you like to apply for"
end

def save_job_to_favorites
end



end #end of cli class
