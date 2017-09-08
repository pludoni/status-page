class ViewObject < OpenStruct
  def config
    Config
  end

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
    Time.at(df).strftime('%d.%m.%Y %H:%M Uhr')
  end
end
