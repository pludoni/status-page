require 'ostruct'

class MonitorCheck < OpenStruct
  def image
    friendly_name.downcase.sub('.de', '').tr(' ', '-') + '.png'
  end

  def sort_group
    friendly_name[/^(IT|OFFICE|MINT|SANO)/] ? 1 : 0
  end

  def days_monitoring
    entry = logs.find { |i| i['type'] == '98' }
    if entry
      (Date.today - Time.at(entry['datetime']).to_date).ceil
    else
      400
    end
  end

  def uptimes
    max = days_monitoring
    ratios = custom_uptime_ratio.split('-').zip(
      Config['customRatios'].map do |ratio|
        "letzte #{[ratio, max].min} Tage"
      end
    ).map(&:reverse)
    filtered = ratios.drop_while { |item| item[1] == '100' }
    if !filtered.empty?
      filtered
    else
      [ratios.last]
    end
  end

  def avg_response_time
    average_response_time && (average_response_time.to_i / 1000.0).round(3)
  end

  def status_name
    case status.to_i
    when 2 then 'erreichbar'
    when 8 then 'wahrscheinlich nicht erreichbar'
    when 9 then 'nicht erreichbar'
    else 'unbekannt'
    end
  end
end
