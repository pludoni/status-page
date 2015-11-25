require 'bundler/setup'
Bundler.require(:default)
require 'yaml'
require 'ostruct'

Config = YAML.load_file('config.yml')

class MonitorCheck < OpenStruct
  def image
    friendlyname.downcase.sub('.de','').gsub(' ','-') + ".png"
  end

  def sort_group
    friendlyname[/^(IT|OFFICE|MINT|SANO)/] ? 1 : 0
  end

  def days_monitoring
    entry = log.find{|i| i['type'] == '98' }
    if entry
      (Date.today - Chronic.parse(entry['datetime']).to_date).ceil
    else
      400
    end
  end

  def uptimes
    max = days_monitoring
    ratios = customuptimeratio.split('-').zip(
      Config['customRatios'].map{|ratio|
        "letzte #{[ratio, max].min} Tage"
      }
    ).map(&:reverse)
    filtered = ratios.drop_while {|item| item[1] == '100' }
    if filtered.length > 0
      filterered
    else
      [ ratios.last ]
    end
  end

  def status_name
    case status.to_i
    when 2 then "erreichbar"
    when 8 then "wahrscheinlich nicht erreichbar"
    when 9 then "nicht erreichbar"
    else "unbekannt"
    end
  end
end

client = UptimeRobot::Client.new(apiKey: Config['uptimerobot_api_key'])
opts = {
  customUptimeRatio: Config['customRatios'].join('-'),
  logs: '1',
  logsLimit: Config['logLimit']
}
list = client.getMonitors(opts)['monitors']['monitor'].map{|i| MonitorCheck.new(i) }



class ViewObject < OpenStruct
  def config; Config; end
  def label_class_for_uptime(uptime)
    case uptime.to_f
    when 100 then 'green lighten-2'
    when 98..100 then 'orange'
    else 'red'
    end
  end
  def type_name(type)
    case type.to_i
    when 1 then 'Host ist down'
    when 2 then 'Host ist up'
    when 99 then 'Monitoring pausiert'
    when 98 then 'Monitoring gestartet'
    end
  end

  def date_format(df)
    Chronic.parse(df).strftime('%d.%m.%Y %H:%M Uhr')
  end
end
scope = ViewObject.new
scope.checks = list.sort_by{|i| [i.sort_group, i.friendlyname.downcase ] }

tpl = Slim::Template.new("template.slim", {}).render(scope)
if ARGV[0]
  File.open(ARGV[0], "w+") {|f|
    f.write tpl
  }
else
  puts tpl
end
