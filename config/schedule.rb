# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "./log/cron_log.log"

job_type :kick, 'cd :path && ruby -EUTF-8 ./:task :output'

every 3.minutes do
  kick "script/collect.rb"
end

every 10.minutes do
  kick "script/count.rb"
end

# 1:00 AM - 6:00 AM in JST
every '* 16-21 * * *' do
  kick "script/collect_old.rb"
end

every '1,11,21,31,41,51 * * * *' do
  kick "script/refine_analyze.rb"
end
