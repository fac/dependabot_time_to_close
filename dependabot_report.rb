require 'json'
require 'date'
require 'active_support/core_ext/numeric/time'


def extract_prs(filter)
  JSON.parse(`./dependabot_report "#{query(filter)}"`)
end

def query(filter)
  start_date = "2023-01-01"
  end_date = "2023-02-01"

  labels = "label:javascript label:dependencies"

  "is:pr #{filter} #{labels} created:#{start_date}..#{end_date}"
end

open = extract_prs("is:open")
unmerged = extract_prs("is:closed is:unmerged")
merged = extract_prs("is:closed is:merged")

merged_in_time = merged.select do |pr|
  DateTime.parse(pr["closedAt"]) - DateTime.parse(pr["createdAt"]) <= 7.days
end

total_prs = open.count + unmerged.count + merged.count

puts "                   Total PRS: #{total_prs}"
puts "        Merged within 7 days: #{merged_in_time.count}"
puts "                  Not merged: #{unmerged.count}"
puts "                  Still Open: #{open.count}"
puts "\n"
puts "Percent merged within 7 days: %#{100.0 * merged_in_time.count.to_f / total_prs}"
