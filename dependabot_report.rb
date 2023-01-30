require 'json'
require 'date'
require 'active_support/core_ext/numeric/time'

class DependabotReport

  STANDARD_LABELS = [
    "dependencies",
    "javascript",
    "Production Dependency",
    "Test Dependency",
    "Build dependency",
  ]

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date

    @open = extract_prs("is:open")
    @unmerged = extract_prs("is:closed is:unmerged")
    @merged = extract_prs("is:closed is:merged")
    @labels = (open + unmerged + merged)
                .flat_map { |pr| pr["labels"] }.uniq
                .map { |label| label["name"] } - STANDARD_LABELS
  end

  def generate_report
    labels.each do |label|
      puts "PRs for #{label}:"
      print_report(
        filter_prs_by_label(merged, label),
        filter_prs_by_label(unmerged, label),
        filter_prs_by_label(open, label),
        )

      puts "\n\n"
    end
    puts "TOTALS:"
    print_report(merged, unmerged, open)
  end

  private

  attr_reader :start_date, :end_date, :merged, :open, :unmerged, :labels

  def print_report(merged, unmerged, open)
    merged_in_time = merged.select do |pr|
      DateTime.parse(pr["closedAt"]) - DateTime.parse(pr["createdAt"]) <= 7.days
    end

    total_prs = open.count + merged.count

    puts "                   Total PRS: #{total_prs}"
    puts "        Merged within 7 days: #{merged_in_time.count}"
    puts "       Closed and not merged: #{unmerged.count}"
    puts "                  Still Open: #{open.count}"
    puts "\n"
    puts "Percent merged within 7 days: %#{100.0 * merged_in_time.count.to_f / total_prs}"
  end

  def filter_prs_by_label(prs, label)
    prs.select { |pr| pr["labels"].map { |l| l["name"] }.include?(label) }
  end

  def extract_prs(filter)
    JSON.parse(`./dependabot_report "#{query(filter)}"`)
  end

  def query(filter)
    labels = "label:javascript label:dependencies"

    "is:pr #{filter} #{labels} created:#{start_date}..#{end_date}"
  end
end

DependabotReport.new("2023-01-01", "2023-02-01").generate_report
