import React, { useState } from 'react';
import CSVUpload from './components/CSVUpload';
import ProductTable from './components/ProductTable';
import Notifications from './components/Notifications';

const App: React.FC = () => {
  const [refreshKey, setRefreshKey] = useState(0);

  // Function to update the table (e.g. when finishing an upload or when receiving notification)
  const refreshTable = () => {
    setRefreshKey(prev => prev + 1);
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Product Upload & Listing</h1>
      <CSVUpload onUploadSuccess={refreshTable} />
      <ProductTable refreshKey={refreshKey} />
      <Notifications onNotification={refreshTable} />
    </div>
  );
};

export default App;
