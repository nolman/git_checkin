namespace :git do
  
  task :check_for_unstaged_files do
    git_status = `git status`
    if there_are_changes?(git_status)
      puts "You have unstaged files -- are you sure you want to continue?"
      be_a_bad_developer = ""
      while be_a_bad_developer.blank?
        $stdout.write "Continue: [N] "
        be_a_bad_developer = $stdin.gets
        be_a_bad_developer = "N" if be_a_bad_developer.blank?
      end
      if be_a_bad_developer.downcase == "n"
        raise "Clean up your act!"
      end
    end
  end

  task :assign_card_number do
    system %Q{git config #{config_key_for("Card number")} '#{collect("Card number")}'}
  end

  task :assign_comment do
    system %[git config #{config_key_for("Comment")} "#{collect("Comment")}"]
  end

  task :assign_user_name do
    user_name = `git config user.name`.chomp
    user_name = "" if user_name =~ %r|Dev1/Dev2|
    pair_name = ""
    while pair_name.blank?
      $stdout.write "Pair name: [#{user_name}] "
      pair_name = $stdin.gets
      pair_name = user_name if pair_name.blank?
    end
    
    system "git config user.name #{pair_name}"
  end

  task :commit do
    system %[git commit -m "\##{retrieve("Card number")}: #{retrieve("Comment")}"]
  end
  
  task :pull do
    system "git pull"
  end
  
  task :pull_and_rerun_tests do
    result = `git pull`
    puts result
    if merged?(result)
      raise "Merge conflict" if merge_failed?(result)
      puts "Re-running the tests due to merge."
      system "rake db:migrate db:test:prepare"
      task = Rake::Task[:test]
      task.reenable
      task.execute :force_retest => true
    end
  end

  task :push do
    system "git push"
  end
  
  task :status do
    system "git status"
  end

  def retrieve(prompt)
    `git config #{config_key_for(prompt)}`.chomp.gsub(/"/, '\\\\"')
  end

  def collect(prompt)
    git_config_key = config_key_for prompt
    git_config_value = `git config #{git_config_key}`.chomp
    input = ""
    while input.blank?
      $stdout.write "#{prompt} [#{git_config_value}]: "
      input = $stdin.gets.chomp
      input = git_config_value if input.blank?
    end
    input.gsub(/"/, '\\\\"')
  end
  
  def config_key_for(prompt)
    "git_checkin.#{prompt.gsub(/[^0-9a-zA-Z]+/, '').downcase}"
  end
  
  def merged?(result)
    result =~ /merge|merging/i
  end
  
  def merge_failed?(result)
     merged?(result) && result =~ /CONFLICT/
  end
  
  def there_are_changes?(git_status_output)
    git_status_output =~ /Changed but not updated/ || git_status_output =~ /Untracked files/
  end
end

