# Full-Stack Developer Coding Test
## Backend API - CSV Product Upload & Listing

## Context

Implement a full-stack web or mobile application that can upload, process, and store into a database the following CSV file which contains a list of products. An example CSV file is located in data.csv in this repo.

## Technology Choice
1. Backend: Ruby on Rails, NestJS, .NET, or Python (choose the one you are being hired for)
2. Frontend: React (for web candidates) or React Native (for mobile candidates)

## Requirements - Backend

1. The products should be stored along with multiple exchange rates at the time of the upload utilizing this [API](https://github.com/fawazahmed0/exchange-api) (include at least 5 currencies). All product fields are required and must be present.
2. Implement an endpoint that returns all the processed rows of product data along with the available currency conversions stored at the time of the upload. This endpoint should support filtering and sorting based on the name, price, and expiration fields
4. The application should support CSV files with up to 200k rows, but easily scale to support more.

## Requirements - Frontend
1. The front-end should display a file upload input that allows the user to select a CSV file from their device.
2. While the file is uploading and being processed, there should be a loading indicator displaying progress of the upload.
3. Once the file uploads, a success message should display and you should be able to browse a table of the uploaded products. 

-----

## Below my 


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

## Frontend - CSV Product Upload & Listing

## Description

**Frontend** is a responsive web application that allows you to upload CSV files containing product data and then displays these products in an interactive table with support for paging, filtering and sorting. The application also integrates real-time notifications to inform the user when the file processing is complete. This solution was developed following the principles of Clean Architecture and TDD, ensuring a modular, scalable structure.

## Table of Contents

- [Description](#description)
- [Index](#index)
- [Installation and Configuration](#installation-and-configuration)
- [Usage and Examples](#usage-and-examples)
- [Tests](#tests)

## Installation and Configuration

### Prerequisites

- [Node.js](https://nodejs.org/) (recommended version: 18+)
- [Docker](https://www.docker.com/) (optional, for build and deploy in production)
- [Go Task](https://github.com/go-task/task) (optional, for automating tasks)

### Step by Step

1. **Install the dependencies**

If running locally:

```$ cd frontend && npm install```

2. **Running on Development:**

Start the development server with Vite:

```npm run dev```

Access the application at http://localhost:5001.

## Usage and Examples
### Main Features
- CSV Upload:

The user can select a CSV file containing product data. During the upload, a progress indicator is displayed. After the upload, a message informs that the file is being processed.

- Real-Time Notifications:

Using ActionCable, the user receives a notification when the file processing is complete. Upon receiving the notification, the upload message disappears and the product table is automatically updated.

- Product Table:

Displays the products uploaded, with information such as name, price (formatted according to the currency), expiration date and price comparisons in different currencies. The table supports pagination, filtering and sorting.

- State Persistence via URL:
-
Filters and pagination are synchronized with the URL, but only parameters that differ from the default values ​​are displayed, keeping the URL clean and shareable.

### Visual Examples
CSV Upload and Progress:
![tela-1](https://github.com/user-attachments/assets/49839c65-f390-471e-a5c6-88f4cfa04632)
Product Table with Pagination:
![tela-2](https://github.com/user-attachments/assets/68e86126-0b00-4b7d-ac9a-c4c705735b4e)
## Tests
The application has a complete test suite using Jest and React Testing Library to ensure the robustness of the features.

To run the tests:

```npm run test```

### Main Tested Areas
- CSVUpload Component:
- File upload and display of success/processing message.
- ProductTable and Pagination:
- Synchronization of filters and pagination with the URL.
- Updating the table with the data returned from the API.
- Notifications Component:
- Receiving notifications via ActionCable and updating the interface.

### Technical Analysis and Improvement Suggestions for the Project

To enhance quality, performance, and user experience, several technical
improvements can be implemented.

**1. Automated Testing and Code Standardization**

Adopting modern testing tools and ensuring code quality is essential. On the
testing front, utilizing **Cypress** for end-to-end tests allows simulation of
real user scenarios in a fast and intuitive manner, helping to quickly identify
bugs and integrating seamlessly with the CI/CD pipeline. Additionally,
implementing **Cucumber** enables writing test scenarios in Gherkin,
which facilitates clear communication between developers, QA, and stakeholders,
ensuring that tests align with business requirements.

For maintaining code consistency and readability, it is recommended to use
**RuboCop** in the backend. RuboCop acts as a linter based on Ruby community
conventions, ensuring maintainability. On the frontend, integrating **Prettier**
standardizes the formatting of JavaScript, TypeScript, HTML, and CSS files,
reducing merge conflicts and speeding up code reviews.

**2. Chunked File Upload**

To improve robustness and user experience during file uploads, implementing a
**chunked upload** system is essential. On the client side, libraries such as
**Resumable.js**, **Fine Uploader**, or **Dropzone** can be adopted to split
files into smaller chunks, allowing uploads to resume in case of connection
failures. This approach not only improves the experience on unstable connections
but also efficiently distributes the load.

On the backend, particularly in a Rails application, the server must be adapted
to receive these chunks and assemble the complete file. This involves creating
endpoints to handle each part, implementing logic to merge the chunks in the
correct order, and adding validations (such as hash or size verification)
after the file is reassembled. It may also be beneficial to perform this
processing asynchronously to avoid blocking API responses.

**3. Real-Time and Email Notifications**

Enhancing communication with users during lengthy processes, such as file uploads
and processing, can be achieved through real-time and email notifications.
Currently, the system notifies the user when the processing is complete; however,
a further improvement would be to send intermediate updates via **WebSocket**,
allowing users to track every stage of the process in real time. This transparency
boosts user confidence and improves overall experience.

Additionally, implementing email notifications ensures that users receive updates
even when they are not connected to the application. This could include sending
an email at the start of the process, periodic updates (when applicable), and a
final notification confirming that the processing has completed. Integrating
with services such as SendGrid or Amazon SES can ensure the scalability and
reliability of email delivery.

**4. Server-Side Caching for API Filters**

Finally, system performance can be significantly enhanced by implementing
server-side caching for the main API filters. By using in-memory caching
solutions like **Redis** or **Memcached**, frequently executed queries
can be stored and the load on the database reduced. This strategy should
include clear expiration and invalidation policies to ensure that the served
data remains up-to-date without compromising performance. Implementing
application-level caching directly in API endpoints can speed up responses and provide a smoother experience for users, particularly in high-demand scenarios.

# Datadog Configuration for Monitoring

This document describes how to configure monitoring with Datadog for Rails + Node.js application.

## Prerequisites

1. Datadog account (https://www.datadoghq.com/)
2. Datadog API Key
3. Application ID for RUM (Real User Monitoring)


### Configure environment variables

Create a `.env` file in the `backend/` directory:

```env
# Datadog Configuration
DD_API_KEY=your_datadog_api_key
DD_ENV=development
DD_SERVICE=rails-backend
DD_VERSION=1.0.0
DD_AGENT_HOST=datadog-agent
DD_TRACE_AGENT_PORT=8126
DD_STATSD_PORT=8125
```

###  Initialize the application

```bash
docker-compose up -d
```

## Frontend Configuration (React/Node.js)  Configure environment variables

Create a `.env` file in the `frontend/` directory:

```env
# Datadog Configuration
VITE_DD_APPLICATION_ID=your_application_id
VITE_DD_CLIENT_TOKEN=your_client_token
VITE_DD_SITE=datadoghq.com
VITE_DD_ENV=development
VITE_DD_VERSION=1.0.0

# API Configuration
VITE_API_BASE_URL=http://localhost:3000
```

### 3. Initialize the application

```bash
npm run dev
```

## Available Metrics

### Backend (Rails)
- **HTTP Requests**: Request count and duration
- **Database Queries**: PostgreSQL query performance
- **Redis Operations**: Redis operations performance
- **Sidekiq Jobs**: Background job metrics
- **Health Checks**: Service status
- **Custom Metrics**: Custom Application Metrics

### Frontend (React)
- **Page Views**: Page views
- **User Interactions**: User interactions
- **API Calls**: Requests to the backend
- **Performance**: Browser performance metrics
- **Errors**: JavaScript errors captured
- **Session Replay**: Session recording (configurable)

## Recommended Dashboards

1. **Application Overview**: Application overview
2. **Backend Performance**: Rails performance
3. **Frontend Performance**: React performance
4. **Database Performance**: PostgreSQL performance
5. **Background Jobs**: Sidekiq metrics
6. **Error Tracking**: Error tracking

## Recommended Alerts

1. **High Error Rate**: Error rate > 5%
2. **High Response Time**: Response time > 2s
3. **Database Connection Issues**: Problems connecting to DB
4. **Sidekiq Queue Backlog**: Job queue > 1000
5. **Memory Usage**: Memory usage > 80%
6. **Health Check Failures**: Health check failures

## Troubleshooting

### Common Issues

1. **Datadog Agent not connecting**: Check API key and network configuration
2. **Metrics not showing**: Check if the agent is running
3. **RUM not working**: Check Application ID and Client Token
4. **Tracing not working**: Check tracer configuration

### Useful Logs

```bash
# Check Datadog Agent logs
docker-compose logs datadog-agent

# Check backend logs
docker-compose logs backend

# Check frontend logs
npm run dev
```

## Next Steps

1. Configure custom dashboards
2. Implement specific alerts
3. Configure log aggregation
4. Implement APM (Application Performance Monitoring)
5. Configure Synthetic Monitoring

## Additional Resources and Documentation
- [Ruby on Rails Documentation](https://guides.rubyonrails.org/)
- [Sidekiq Documentation](https://sidekiq.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Cucumber Documentation](https://cucumber.io/docs/)
- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://reactjs.org/)
- [ActionCable Documentation](https://guides.rubyonrails.org/action_cable_overview.html)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
