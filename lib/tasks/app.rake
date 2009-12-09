namespace :app do
  task :check_in => ["git:check_for_unstaged_files", 
               "git:assign_card_number", 
               "git:assign_comment", 
               "git:assign_user_name", 
               "git:status",
               "git:pull",
               "db:migrate",
               :test,
               "git:commit",
               "git:pull_and_rerun_tests",
               "git:push"]
end