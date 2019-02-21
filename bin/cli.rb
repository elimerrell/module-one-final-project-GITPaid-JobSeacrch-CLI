class CLI

  def blue(string)
    return string.colorize(:color => :blue, :background => :white)
  end

  def green(string)
    return string.colorize(:green)
  end

  def red(string)
    return string.colorize(:red)
  end

  def welcome
    puts '

     $$$$$$\  $$$$$$\ $$$$$$$$\       $$$$$$$\           $$\       $$\
    $$  __$$\ \_$$  _|\__$$  __|      $$  __$$\          \__|      $$ |
    $$ /  \__|  $$ |     $$ |         $$ |  $$ |$$$$$$\  $$\  $$$$$$$ |
    $$ |$$$$\   $$ |     $$ |         $$$$$$$  |\____$$\ $$ |$$  __$$ |
    $$ |\_$$ |  $$ |     $$ |         $$  ____/ $$$$$$$ |$$ |$$ /  $$ |
    $$ |  $$ |  $$ |     $$ |         $$ |     $$  __$$ |$$ |$$ |  $$ |
    \$$$$$$  |$$$$$$\    $$ |         $$ |     \$$$$$$$ |$$ |\$$$$$$$ |
     \______/ \______|   \__|         \__|      \_______|\__| \_______|

    '
    puts blue("Welcome to GIT Paid, the Dev job search tool you've been waiting for.")

    puts
    puts green("Have you already signed up (y/n)?")
    sign_up_response = gets.chomp.downcase
    if sign_up_response == 'y'
      @@user_id = enter_user_id
      if JobHunter.find_by(:id => @@user_id)
        puts blue("Sign in successful")
        main_menu
      else
        incorrect_id
        welcome
      end
    elsif sign_up_response == 'n'
      sign_up
    else
      invalid_response
      welcome
    end
  end

  def sign_up
    puts green("Welcome to the Dev Job Hunter sign up!")
    puts
    puts green("Please enter your name")
    hunter_name = gets.chomp.downcase
    puts
    puts blue("Welcome, #{hunter_name.capitalize}!")
    puts
    print green("Please enter the tecnhologies you are fluent in ")
    puts green("i.e. ruby,java,javascript")
    hunter_tecnhologies = gets.chomp.downcase
    puts
    puts green("Please enter your current location")
    hunter_location = gets.chomp.downcase
    current_job_hunter = create_job_hunter(
      hunter_name,
      hunter_tecnhologies,
      hunter_location
    )
    puts "----------------------------------------------"
    print blue("Thanks for signing up, #{hunter_name.capitalize}. ")
    puts blue("Your User ID is: #{current_job_hunter['id']}.")
    puts
    puts blue("Returning to Home")
    sleep(1)
    welcome
  end

  #** create sign in method (asks for your user id, makes sure that id exists in
  #   the jobhunters table, and returns that number)

  def main_menu
    puts <<~MAIN_MENU

      #{green("What would you like to do? Please enter a number:")}
      ---------------------
      #{blue("1. Search Developer Jobs")}
      ---------------------
      #{blue("2. See Saved Jobs")}
      ---------------------
      #{blue("3. Apply From Saved Jobs")}
      ---------------------
      #{blue("4. Have You Moved? Update Location Here")}
      ---------------------
      #{blue("5. Sign Out")}
      ---------------------
      #{blue("6. Exit Program")}
      ---------------------
    MAIN_MENU

    main_menu_response = gets.chomp.downcase
    if main_menu_response == "1"
      search_jobs
    elsif main_menu_response == "2"
      saved_jobs
    elsif main_menu_response == "3"
      apply_job
    elsif main_menu_response == "4"
      update_location
    elsif main_menu_response == "5"
      @@user_id = nil
      puts blue("Signing out")
      sleep(1)
      welcome
    elsif main_menu_response == "6"
      exit
    else
      invalid_response
      main_menu
    end
  end

  def search_jobs
    puts <<~SEARCH_JOBS

      #{green("How would you like to search?")}

      #{blue("1. See local jobs")}
      ---------------------
      #{blue("2. Search by location")}
      ---------------------
      #{blue("3. Search by title")}
      ---------------------
      #{blue("4. Search by technologies")}
      ---------------------
      #{blue("5. Return to main menu")}
      ---------------------
    SEARCH_JOBS
    search_jobs_response = gets.chomp.downcase

    if search_jobs_response == "1"
      see_local_jobs
    elsif search_jobs_response == "2"
      search_by_location
    elsif search_jobs_response == "3"
      search_by_title
    elsif search_jobs_response == "4"
      search_by_technologies
    elsif search_jobs_response == "5"
      main_menu
    else
      invalid_response
      search_jobs
    end
  end

  def select_job_to_save(job_list)
    job_list.each_with_index.map do |job,index|
      puts "#{index + 1}. #{job[:title]}"
    end
    puts
    want_to_save = would_you_like_to_save?
    if want_to_save == 'y'
      if JobHunter.find_by(:id => @@user_id)
        puts green("Please enter the number for the job you would like to save: ")
        user_saved_response = gets.chomp.to_i
        #check to see if user response is valid
        if user_saved_response.between?(1, job_list.count)
          job = job_list[user_saved_response - 1]
          hunter = @@user_id
          posting = JobPosting.find(job["id"])['id']
          if JobPosting.find_by(:id => posting)
            save_job(hunter,posting)
            job_has_been_saved
            main_menu
          end
        end
      else
        incorrect_id
      end
    elsif want_to_save == 'n'
      main_menu
    end
  end

  def search_by_location
    puts
    puts green("Please enter the location where you want to work")
    user_location_response = gets.chomp.downcase
    jobs_by_location = JobPosting.joins(:branch).where('LOWER(branches.location) LIKE ?', "%#{user_location_response}%")
    if jobs_by_location.count > 0
      puts green("Here are the jobs in your area:")
      puts
      select_job_to_save(jobs_by_location)
      invalid_response
    else
      no_results
    end
    search_by_location
  end

  def search_by_title
    puts
    puts green("Please enter the job title you would like to search")
    user_job_title_response = gets.chomp.downcase
    jobs_by_title = JobPosting.where("job_postings.title LIKE ?", "%#{user_job_title_response}%")
    if jobs_by_title.count > 0
      puts green("Here are the current openings with similar titles:")
      puts
      select_job_to_save(jobs_by_title)
      invalid_response
    else
      no_results
    end
    search_by_title
  end

  def search_by_technologies
    puts "Please enter the technologies you would like to find (separated by commas): "
    user_technology_response = gets.chomp

    # make the technologies into a list like ["html", "css"]
    technologies = user_technology_response.split(",").map {|t| t.strip}

    # dynamically build the SQL query.  ActiveRecord is smart and will build
    # this "lazily", meaning that the SQL will not actually execute until it has
    # filtered by all of the relevant technologies
    job_subset = JobPosting.all
    technologies.each do |technology|
      job_subset = job_subset.where("job_postings.description LIKE ?", "%#{technology}%")
    end
    
    # reassign the variable name when we're done with the query, for clarity
    jobs_by_technology = job_subset
    if jobs_by_technology.count > 0
      puts "Here are the jobs that match your search: "
      select_job_to_save(jobs_by_technology)
      invalid_response
    else
      no_results
    end
    search_by_technologies
  end

  def saved_jobs
    current_job_hunter = JobHunter.find_by(:id => @@user_id)
    if current_job_hunter
      if list_saved_jobs.count <= 0
        puts red("You have no saved jobs. Returning to main menu")
        main_menu
      end
    else
      incorrect_id
      saved_jobs
    end
    puts <<~SAVED_JOBS
    #{green("What would you like to do? Please enter a number:")}

    #{blue("1. See job description")}
    ---------------------
    #{blue("2. Delete job")}
    ---------------------
    #{blue("3. Return to main menu")}
    ---------------------
    SAVED_JOBS
    saved_jobs_response = gets.chomp.downcase
    if saved_jobs_response == "1"
      job_description
    elsif saved_jobs_response == "2"
      delete_job
    elsif saved_jobs_response == "3"
      main_menu

    end
  end

  def job_description
    current_job_hunter = JobHunter.find_by(:id => @@user_id)
    if current_job_hunter
      if list_saved_jobs.count <=0
        puts red("You have no saved jobs. Returning to main menu")
        main_menu
      else
      end
    else
      incorrect_id
      apply_job
    end
    puts green("Please enter the number for the job you want to know about: ")
    user_description_response = gets.chomp.to_i
    if user_description_response.between?(1, @@jobs.count)
      job_to_describe = @@jobs[user_description_response - 1]
      description = job_to_describe.job_posting['description']
      initial_string = Sanitize.clean(description)
      new_string = initial_string.delete!("\n")
      puts blue("Here is the job description:")
      puts
      puts new_string
      puts
      puts green("Press 1 to return to main menu")
      done_reading = gets.chomp

      if done_reading == "1"
        main_menu
      else
        invalid_response
        job_description
      end
    else
      invalid_response
      saved_jobs
    end
  end

  def delete_job
    if list_saved_jobs.count <= 0
      puts red("You have no saved jobs. Returning to main menu")
      main_menu
    else
      puts
      puts green('Please enter the number of the job you would like to delete: ')
      user_delete_input = gets.chomp.to_i
      if user_delete_input.between?(1, @@jobs.count)
        job_to_delete = @@jobs[user_delete_input - 1]
        job_to_delete.destroy
        puts blue("Job successfully deleted.")
        main_menu
      else
        invalid_response
        saved_jobs
      end
      puts
      updated_saved_postings = SavedPosting.where(:job_hunter_id => current_job_hunter.id)
      puts blue("Here is your updated list of jobs:")
      puts
      updated_job_titles = updated_saved_postings.each_with_index.map do |posting, index|
        puts "#{index + 1}. #{posting.job_posting.title}"
      end
    end
  end


  def apply_job
    current_job_hunter = JobHunter.find_by(:id => @@user_id)
    if current_job_hunter
      if list_saved_jobs.count <=0
        puts red("You have no saved jobs. Returning to main menu")
        main_menu
      else
      end
    else
      incorrect_id
      apply_job
    end
    puts green("Please enter the number for the job you would like to apply for: ")
    user_saved_response = gets.chomp.to_i
    if user_saved_response.between?(1, @@jobs.count)
      job = @@jobs[user_saved_response - 1]
      application_link = job.job_posting['application_link']
      match = /href\s*=\s*"([^"]*)"/.match(application_link)
      if match
        url = match[1]
      else
        puts "No url provided."
      end
      puts blue("Opening link to application")
      sleep(1)
      system('open', url)
      system('clear')
      main_menu
    else
      invalid_response
      apply_job
    end
  end

  def update_location
    current_job_hunter = JobHunter.find_by(:id => @@user_id)
    current_location = current_job_hunter.location
    puts blue("Your current location is #{current_location.capitalize}")
    puts
    puts green("Please enter your new location")
    new_location = gets.chomp.downcase
    if current_job_hunter
      current_job_hunter.update_column(:location, new_location)
      puts blue("Thanks for updating your location! Returning to Main Menu")
      sleep(1)
      main_menu
    else
      incorrect_id
      update_location
    end
  end


  def exit
    abort(blue("Thanks for using GIT Paid. Goodbye!"))
  end

  def would_you_like_to_save?
    puts green("Would you like to save any of these jobs? (y/n)")
    user_save_input = gets.chomp.downcase
  end

  def enter_user_id
    puts green("Please enter your User ID: ")
    user_id_response = gets.chomp.to_i
  end

  def save_job(hunter,posting)
    SavedPosting.find_or_create_by(
      job_hunter_id: hunter,
      job_posting_id: posting
    )
  end

  def incorrect_id
    puts red("User ID is incorrect. Please try again.")
  end

  def job_has_been_saved
    puts blue("This job has been saved to your favorites.")
  end

  def create_job_hunter(hunter_name,hunter_tecnhologies,hunter_location)
    current_job_hunter = JobHunter.find_or_create_by(
      name: hunter_name,
      skills: hunter_tecnhologies,
      location: hunter_location
      )
  end

  def invalid_response
    puts red("Please enter a valid command!")
  end

  def no_results
    puts red("Whoops! This search didn't return any results. Please try again!")
  end

  def see_local_jobs
    current_job_hunter = JobHunter.find_by(:id => @@user_id)
    current_location = current_job_hunter.location
    puts blue("Your current location is #{current_location}")
    local_jobs = JobPosting.joins(:branch).where('LOWER(branches.location) LIKE ?', "%#{current_location}%")
    local_jobs_count = local_jobs.each_with_index.map do
      |job,index|"#{index + 1}. #{job[:title]}"
    end
    if local_jobs_count.count > 0
      puts "Here are the jobs in your area:"
      select_job_to_save(local_jobs)
      invalid_response
      see_local_jobs
    else
      puts red("There are no jobs in your area. Returning to main menu")
      sleep(1)
      main_menu
    end
  end

  def list_saved_jobs
    current_job_hunter = JobHunter.find_by(:id => @@user_id)
    saved_postings = SavedPosting.where(:job_hunter_id => current_job_hunter.id)
    puts blue("Here are your saved jobs:")
    puts
    @@job_titles = saved_postings.each_with_index.map do |posting, index|
      puts "#{index + 1}. #{posting.job_posting.title}"
    end
    puts
    @@jobs = saved_postings.each_with_index.map {|posting| posting}
  end
end #end of cli class
