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

## Additional Resources and Documentation
- [Ruby on Rails Documentation](https://guides.rubyonrails.org/)
- [Sidekiq Documentation](https://sidekiq.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Cucumber Documentation](https://cucumber.io/docs/)
- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://reactjs.org/)
- [ActionCable Documentation](https://guides.rubyonrails.org/action_cable_overview.html)
- [Jest Documentation](https://jestjs.io/docs/getting-started)


