require 'bundler/setup'
Bundler.require(:default)
require 'yaml'
require 'pry'

Config = YAML.load_file('config.yml')

require_relative './lib/monitor_check.rb'
require_relative './lib/view_object.rb'

client = UptimeRobot::Client.new(api_key: Config['uptimerobot_api_key'])
opts = {
  custom_uptime_ratios: Config['customRatios'].join('-'),
  logs: '1',
  response_times_average: '1',
  response_times: '1',
  logs_limit: Config['logLimit']
}
list = client.getMonitors(opts)['monitors'].map { |i| MonitorCheck.new(i) }

scope = ViewObject.new
scope.checks = list.sort_by { |i| [i.sort_group, i.friendly_name.downcase] }

tpl = Slim::Template.new('template.slim', {}).render(scope)
if ARGV[0]
  File.open(ARGV[0], 'w+') do |f|
    f.write tpl
  end
else
  puts tpl
end
