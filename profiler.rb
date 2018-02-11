require 'net/http'
require 'progress_bar'
require 'benchmark'
require 'bundler/setup'
Bundler.require(:default)

rows = []
main_samples = []
samples_different = %w[dme lon mos pari novos vosto kras shan ber amster]
samples_two_lwtters = %w[dm mo sa ne no sh am]
main_samples << samples_different
main_samples << samples_two_lwtters
bar = ProgressBar.new(main_samples.flatten.count)

def format(time)
  time.to_a.last.ceil(3)
end

main_samples.each do |sample_collection|
  sample_collection.each do |sample|
    time_party_suggest = Benchmark.measure do
      HTTParty.get("https://suggest.kupibilet.ru/suggest.json?term=#{sample}")
    end
    time_net_suggest = Benchmark.measure do
      Net::HTTP.get_response(URI("https://suggest.kupibilet.ru/suggest.json?term=#{sample}"))
    end
    time_party_hinter_old = Benchmark.measure do
      HTTParty.get("https://hinter.kupibilet.ru/suggest.json?term=#{sample}")
    end
    time_net_hinter_old = Benchmark.measure do
      Net::HTTP.get_response(URI("https://hinter.kupibilet.ru/suggest.json?term=#{sample}"))
    end
    time_party_hinter_new = Benchmark.measure do
      HTTParty.get("https://hinter.kupibilet.ru/hinter.json?str=#{sample}")
    end
    time_net_hinter_new = Benchmark.measure do
      Net::HTTP.get_response(URI("https://hinter.kupibilet.ru/hinter.json?str=#{sample}"))
    end
    rows << [
              sample,
              "#{format(time_party_suggest)}\n#{format(time_net_suggest)}",
              "#{format(time_party_hinter_old)}\n#{format(time_net_hinter_old)}",
              "#{format(time_party_hinter_new)}\n#{format(time_net_hinter_new)}"
            ]
    rows << :separator
    bar.increment!
  end
  table = Terminal::Table.new :headings => %w[
                                              string
                                              suggest_prod
                                              hinter_old_format_staging
                                              hinter_new_format_staging
                                            ],
                                            :rows => rows
  puts table
  rows = []
end
