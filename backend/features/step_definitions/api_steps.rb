require 'csv'
require 'json'


Given("a CSV file {string} with {int} rows of valid product data") do |file_path, row_count|
  full_path = Rails.root.join(file_path)
  headers = ["name", "price", "expiration"]
  dirname = File.dirname(full_path)
  FileUtils.mkdir_p(dirname) unless Dir.exist?(dirname)

  CSV.open(full_path, "w", col_sep: ";") do |csv|
    csv << headers
    row_count.times do |i|
      csv << ["Test Product #{i}", "$10.00", "12/31/2025"]
    end
  end
end

When("I upload the CSV file to {string}") do |path|
  header 'Content-Type', 'multipart/form-data'
  post path, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures", File.basename(path) == "large_file_300k.csv" ? "large_file.csv" : "standard_file.csv"), 'text/csv')
end

Then("I should receive a JSON response with message {string}") do |expected_message|
  json = JSON.parse(last_response.body)
  expect(json["message"]).to eq(expected_message)
end

Then("after processing, when I request {string}") do |path|
  sleep 10
  get path
  @json_response = JSON.parse(last_response.body)
end

#Then("the response meta information should indicate {string} as {int}") do |meta_key, expected_total|
  #p "#{Rails.env}"
  #expect(@json_response).to have_key("meta")
  #expect(@json_response["meta"][meta_key]).to eq(expected_total)
#end

