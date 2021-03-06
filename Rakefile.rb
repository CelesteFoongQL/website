#!/usr/bin/env ruby
require 'date'
require 'colored'

task default: ["helloworld"]

desc "this is a demo test"
task :helloworld do
  puts 'hello word'
end


namespace :deploy do
  # Usage:
  # bundle exec rake deploy:ghpages
  # bundle exec rake deploy:web3

  desc 'deploy to OSC servers'
  task :web3 do
    # Check for rsync before building
    system('which rsync')
    if ($? != 0)
      print "The deploy requires rsync, please install it and try again."
      exit(255)
    end

    puts 'Make sure you are up-to-date with origin/master!'
    sleep(3)

    system 'grunt build --env=production'
    if $? == 0
      system 'rsync -rlptv --delete _site/ build@opensource.osu.edu:/var/www/new-site -e "ssh -p 922"'
    else
      echo "Something went wrong while building. Check the grunt output and try again"
    end
  end

  desc 'deploy to Github Pages'
  task :ghpages do
    `grunt build --env=staging`
    origin = `git config --get remote.origin.url`

    Dir.mktmpdir do |tmp|
      cp_r '_site/.', tmp
      Dir.chdir tmp
      system 'rm -rf downloads'
      system 'git init'
      system "git add . && git commit -m 'Site updated at #{Time.now.utc}'"
      system "git remote add origin #{origin}"
      system 'git push origin master:refs/heads/gh-pages --force'
    end
  end
end



namespace :new do

  desc 'generate new post'
  task :post do

    d = DateTime.now
    d.strftime("%Y-%m-%d")


    category = ARGV[1]
    categories = ['events', 'history', 'tutorials', 'announcements', 'volunteering','schedules']

    firstRun = true


    until categories.include? category do
      if firstRun && category.nil?
        puts
        puts 'Protip: weekly meetings are categorized under announcements'.blue
        puts 'What is the post\'s category? (i.e. schedules, events, volunteering, announcements, tutorials, histroy)'.green
      else
        puts 'Invalid category, try again.'.yellow
      end

      category = STDIN.gets.chop
      firstRun = false
    end


    if (category == 'announcements')
      puts
      puts 'Who\'s the author?'.green
      author = STDIN.gets.chop
    end


    puts
    puts 'What\'s the post title?'.green
    title = STDIN.gets.chomp
    title_slugified = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')


    if (category == 'announcements')
      puts
      puts 'When is the meeting? (YYYY-MM-DD)'.green
        meeting_date = STDIN.gets.chomp

      until meeting_date =~ /\d{4}\-\d{2}\-\d{2}/ do
        puts 'Invalid format, try again.'.yellow
        meeting_date = STDIN.gets.chomp
      end

      puts
      puts 'Protip: if you leave this blank it will default to "Caldwell Labs, Rm 120"'.blue
      puts 'Where is the meeting location'.green
      meeting_location = STDIN.gets.chop
      meeting_location = 'Caldwell Labs, Rm 120' if meeting_location.length == 0
    end


    if (category == 'events' || category == 'volunteering')
      puts
      puts 'When would you like the post to expire? (YYYY-MM-DD)'.green
      expiration_date = STDIN.gets.chomp

      until expiration_date =~ /\d{4}\-\d{2}\-\d{2}/ && expiration_date > d.strftime("%Y-%m-%d") do
        puts 'Invalid format, try again.'.yellow
        expiration_date = STDIN.gets.chomp
      end
    end


    path = "_posts/#{d.strftime("%Y-%m-%d")}-#{title_slugified}.md"


    File.open(path, "w") do |f|
      f.puts '---'
      f.puts 'layout: default'
      f.puts "title: #{title}"
      f.puts "categories: #{category}"
      f.puts "tags: #{category}"
      f.puts "meeting_date: #{meeting_date}" if category == 'announcements'
      f.puts "expire_date: #{expiration_date}" if expiration_date
      f.puts "meeting_location: #{meeting_location}" if meeting_location
      f.puts '---'
      f.puts
      f.puts '<!-- INSERT TEXT HERE -->'
      f.puts
      f.puts "-- #{author}" if category == 'announcements'
      f.puts
      f.puts '<!-- generated by _helpers/newPost.rb -->'
    end

    puts
    puts 'Post ' + path.blue + ' successfully created'
  end

end
