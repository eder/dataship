## Backend API - CSV Product Upload & Listing

- [Installation and Configuration](#installation-and-configuration)
- [Usage and Examples](#usage-and-examples)
  - [CSV Upload and Processing](#csv-upload-and-processing)
  - [Product Listing with Filtering and Sorting](#product-listing-with-filtering-and-sorting)
- [Testing](#testing)
---

## Installation and Configuration

### Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- (Optional) [Go Task](https://github.com/go-task/task) for orchestration


1. *****Overview system design**
![csv_upload drawio](https://github.com/user-attachments/assets/cc739c64-c10b-408c-bf14-eeb4764e61ee)
## Explanation
 - Client / Browser:
    - Users interact with the system via HTTP/.

- Nginx Reverse Proxy:
    - Routes:
    - ```/api/``` and ```/cable``` requests to the backend.
    - All other requests to the frontend (or other defined routes).
- Backend (Rails API):
    -Handles CSV uploads and processing in the background (using Sidekiq).
    - Provides endpoints for product listing with filtering and sorting.
    - Uses Action Cable for real-time notifications.
- PostgreSQL:
    Stores product data.

- Redis:
    - Serves as the queue backend for Sidekiq and supports Action Cable.

- External Currency API:
    - Provides real-time exchange rates used during CSV processing.


2. **Configure Environment Variables:**
 * Create a .env file in the project root with the necessary variables . For example:
```yml
# Database configuration
DATABASE_HOST=db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=12345
DATABASE_NAME=api_development
DATABASE_NAME_PROD=api_production
DATABASE_QUEUE_PROD=api_queue_production

# Redis configuration
REDIS_URL=redis://redis:6379

# Exchange API configuration
EXCHANGE_API_DATE=latest
EXCHANGE_API_VERSION=v1
EXCHANGE_CURRENCIES=usd,rub,inr,cny,zar,brl
BASE_CURRENCY=usd

# CSV processing
CSV_MAX_LINES=200000
RAILS_MAX_THREADS=5

# Rails Environment (set appropriately)
RAILS_ENV=development

```
* just copy like that
```
 $ cp env.sample .env
```

3. **Install Dependencies:**
 * No local installations are required; the application runs inside Docker containers.


### Usage and Examples
**CSV Upload and Processing**
* The API exposes an endpoint for CSV uploads. All products are validated and processed asynchronously, with each product enriched by exchange rates for multiple currencies (USD, RUB, INR, CNY, ZAR, BRL).

* Endpoint:
    - URL: ```/api/products/upload```
    - Method: ```POST```
    - Parameters:
        - ```file``` (form-data): The CSV file to be uploaded.

**Example Request using cURL:**

```curl -X POST -F "file=@data.csv" http://localhost/api/products/upload```

**Response**
```json
{
  "message": "File is being processed"
}
```
The processing job will:

- Validate that all required fields (```name```, ```price```, ```expiration```) are present.
- Limit the processing to the maximum number of rows specified by the ```CSV_MAX_LINES``` environment variable.
- Fetch current exchange rates from an external API and store the product data with currency comparisons in the following format:

```json
{
  "id": 958,
  "name": "Cheese - Brie, Cups 125g #(4017956126189774)",
  "price": 0.41,
  "currency": "USD",
  "expiration": "2022-12-19",
  "comparisons": {
    "BRL": {
      "exchangeRate": 5.73,
      "price": 2.3413
    },
    "CNY": {
      "exchangeRate": 7.25,
      "price": 2.9725
    },
    "INR": {
      "exchangeRate": 86.58,
      "price": 35.5118
    },
    "RUB": {
      "exchangeRate": 88.50,
      "price": 36.3385
    },
    "USD": {
      "exchangeRate": 1,
      "price": 0.41
    },
    "ZAR": {
      "exchangeRate": 18.36,
      "price": 7.5285
    }
  }
}
```
### Product Listing with Filtering and Sorting
The API endpoint ``/api/products`` supports dynamic filtering and ordering. For example:

- **Filter by Name:**
```GET /api/products?name=Cheese```

- **Filter by Price Range:**
```GET /api/products?min_price=10&max_price=100```

- **Filter by Expiration Date:**
```GET /api/products?expiration_from=2022-01-01&expiration_to=2023-01-01```

- **Sort by Name in Descending Order:**
```GET /api/products?sort=name&order=desc```



4. **Background Processing & Real-Time Notifications**
- Background Processing:
    - The CSV processing is handled asynchronously using ActiveJob with Sidekiq. This allows the API to respond quickly to upload requests while the heavy processing is done in the background.

- Real-Time Notifications:
    -Upon completion of the CSV processing job, a notification is broadcast via Action Cable.
    - **Action Cable Endpoint:** ```/cable```
    - **Notification Channel:** ```NotificationsChannel``
    - **Example Payload Sent:**
     ```json
        {
            "message": "File processing finished successfully",
            "file": "/app/tmp/uploads/1740511588_data.csv",
            "status": "success"
        }
    ```

## Testing
- **RSpec (Unit and Integration Tests): Run the tests with:**
```RAILS_ENV=test bundle exec rspec```
- **Cucumber (Behavioral Tests): Run the behavioral tests with:**
```RAILS_ENV=test bundle exec cucumber```

- **Execution via Docker:**

Use the tasks defined in the ```Taskfile.yml``` to run the tests inside the containers, ensuring execution in the test environment:

```
task test-backend-rspec
task test-backend-cucumber
task test-all
````
## Benefits of Automated Testing
- **Testability:**

Implementing automated tests ensures that all functionalities, from CSV validation to the listing endpoint, work as expected.

- **Quick Feedback:**

TDD (RSpec) and BDD (Cucumber) tests allow you to quickly identify and fix regressions, while maintaining code quality and reliability.

## Deployment
**Development Environment**
- Use the ```backend/docker-compose.yml``` file to bring up the development services.
- Run:
```docker-compose up --build```

- The necessary environment variables must be defined in a .env file in the project root.

**Production Environment (Simulation)**
- The production compose files are organized as follows:
* ```backend/docker-compose.prod.yml``` for the backend (including Sidekiq, PostgreSQL and Redis).
* ```docker-compose.prod.nginx.yml``` for the Nginx container, which acts as a reverse proxy.
- The external network ``app_net`` is used to allow communication between containers.
- Use the ``Taskfile.yml`` to orchestrate the production environment:
```
task prod-up
```
To tear down the environment:
```
task prod-down
```
