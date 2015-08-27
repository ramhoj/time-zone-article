raise "Run with rails runner!" unless defined? Rails

iso_string = Time.current.utc.iso8601

[
  [
    ['2.hours.ago'],
    ['1.day.from_now'],
    [%Q{Time.zone.parse("#{iso_string}")}],
    ['Time.current'],
    ['Time.current.utc.iso8601', "When supliyng an API (you can actually skip .zone here, but I find it better to always use it, than miss it when it's needed"],
    [%Q{Time.strptime("#{iso_string}", "%Y-%m-%dT%H:%M:%S%z").in_time_zone}, "If you can't use time.zone.parse"],
    ['Date.current', "Tue, 18 Aug 2015 If you really can't have a Time or DateTime for some reason"],
    ['Date.current.in_time_zone', "If you have a date and want to make the best out of it"]
  ],
  [
    ['Time.now', "Returns system time and ignores your configured time zone."],
    [%Q{Time.parse("#{iso_string}")}, "Will assume time string given is in the system's time zone."],
    [%Q{Time.strptime("#{iso_string}", "%Y-%m-%dT%H:%M:%S%z")}, "Same problem as with Time#parse."],
    ['Date.today', "This could be yesterday or tomorrow depending on the machine's time zone, see https://github.com/ramhoj/time-zone-article/issues/1 for more info."]
  ]
].each_with_index do |list, index|
  if index == 0
    puts "\n### DOs\n\n"
  else
    puts "\n### DON'Ts\n\n"
  end

  list.each do |item|
    if item[1]
      puts "\s"*4 + item[0] + " # " + item[1].to_s + %Q{ (#{eval(item[0]).inspect})}
    else
      puts "\s"*4 + item[0] + " # => " + %Q{#{eval(item[0]).inspect}}
    end
  end
end
