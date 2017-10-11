#!/usr/bin/ruby
require 'date'

Event = Struct.new(:task, :count)  # Serves as a tuple of type event : (task, count)
$date_hash = Hash.new  # global hash to represent events by date
$month_hash = Hash.new   # global hash to represent events by month in date range
# prints keys and values of date_hash
def display(date_hash)
  puts $bounds
  puts
  puts $start_bound
  puts
  puts $end_bound
  puts
  puts date_hash.keys
  puts
  date_hash.each do |k, v|
    puts v.task.to_s
    puts v.count.to_s
    puts
  end
end

def display2(month_hash)
  month_hash.each do |k, v|
    puts k.to_s + ", " + v.to_s
  end
end

# reads input and adds items to a hash of dates/events
def read
  $bounds = gets  # start and end date bounds
  $bounds.match(/(\d{4}-\d{2}),/)
  $start_bound = $1
  $end_bound = $bounds.match(/\d{4}-\d{2}$/)
  gets  # ignore blank line

  while line = gets # read each line and gather necessary data
    date = line.match(/\d{4}-\d{2}-\d{2}/)
    task = line.match(/[a-zA-Z_]+/)
    count = line.match(/[0-9]+$/)

    # create values for date_hash (tuple)
    e = Event.new
    e.task = task
    e.count = count

    $date_hash[date] = e  # assign values to each date key
  end
end

def populate_value_list(month, year, value_list, month_year)
  $date_hash.each do |key, value|
    $month_hash.each do |key2, value2|
      if key.to_s.include? key2.to_s then $month_hash[key] = value2 << value end
      $month_hash[key2] = value2
    end
    $month_hash.each do |key2, value2|
      print key
      value2.each do |e|
        puts e.task.to_s + ", " + e.count.to_s
      end
  end
end
end

def all_valid_months(start_year, start_month, end_year, end_month)
  start_month = '%02d' % start_month.to_s
  start_date = start_year.to_s + "-" + start_month.to_s + "-01"
  # puts start_date
  end_month = '%02d' % end_month.to_s + "-01"

  end_date = end_year.to_s + "-" + end_month.to_s
#   puts end_date
  # puts

  date_from = Date.parse(start_date.to_s)
  date_to = Date.parse(end_date.to_s)
  date_range = date_from..date_to

  date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
  date_months = date_months.map {|d| d.strftime "%Y-%m" }
  return date_months
end


def is_valid(year, month, start_year, end_year, start_month, end_month)
  if (year >= start_year && year <= end_year && month >= start_month &&
      month <= end_month) then return true
  end

  return false
end

def aggregate_by_month
  $start_bound.to_s.match(/^(\d{4})-(\d{2})/)
  # puts "-----------------"
   start_year = $1.to_i
   start_month = $2.to_i
  $end_bound.to_s.match(/^(\d{4})-(\d{2})/)
   end_year = $1.to_i
   end_month = $2.to_i
  #puts puts

  date_months = all_valid_months(start_year, start_month, end_year, end_month)

  #puts date_months
  #puts

  $date_hash.each do |k, v|
    k.to_s.match(/^(\d{4})-(\d{2})/)
    year = $1.to_i
    month = $2.to_i
    month_year = $1 + "-" + $2

    if date_months.include? month_year then $month_hash[month_year] = [] end
  end

    value_list = []

  # need to fill array with all events in a month, total count if duplicate task #

  #   hash_copy = $month_hash
  #   $date_hash.each do |key, value|
  #     $month_hash.each do |key2, value2|
  #       if key.to_s.include? key2.to_s then value_list << value end
  #     end
  #     value_list.each do |e| print e.task.to_s + ", " + e.count.to_s + "\n" end
  #     $month_hash[month_year] = value_list
  #   end
  #
  #     # $month_hash.each do |key2, value2|
  #     #   print key2
  #     #   value2.each do |e|
  #     #     #print e.task.to_s + ", " + e.count.to_s + "\n"
  #     #   end
  #     # end
  #   end
  #
  #   # populate_value_list(month, year, value_list, month_year)
  #
  # # $month_hash.each do |key, value|
  # #   print key + ", "
  # #   value.each do |event|
  # #   #  puts event.task.to_s + ", " + event.count.to_s
  # #   end
  # # end

end

read()

#display($date_hash)
aggregate_by_month()
