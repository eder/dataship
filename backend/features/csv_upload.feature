Feature: CSV File Upload

  As an API consumer
  I want to upload a CSV file and have the system process it according to its size
  So that for large files, only the maximum allowed number of rows is processed

  Scenario: Successful CSV upload with standard file
    Given a CSV file "spec/fixtures/standard_file.csv" with 5000 rows of valid product data
    When I upload the CSV file to "/api/products/upload"
    Then I should receive a JSON response with message "File is being processed"
    And after processing, when I request "/api/products?page=1&per_page=10"
    Then the response meta information should indicate "total_results" as 5000

  Scenario: CSV file upload exceeding the maximum allowed rows
    Given a CSV file "spec/fixtures/large_file.csv" with 250000 rows of valid product data
    When I upload the CSV file to "/api/products/upload"
    Then I should receive a JSON response with message "File is being processed"
    And after processing, when I request "/api/products?page=1&per_page=10"
    Then the response meta information should indicate "total_results" as 200000

