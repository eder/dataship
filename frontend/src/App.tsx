// src/App.tsx
import React, { useState } from 'react';
import CSVUpload from './components/CSVUpload';
import ProductTable from './components/ProductTable';
import Notifications from './components/Notifications';

const App: React.FC = () => {
  const [refreshKey, setRefreshKey] = useState(0);
  const [uploadMessage, setUploadMessage] = useState('');

  const handleUploadSuccess = () => {
    setRefreshKey(prev => prev + 1);
  };

  // When a notification arrives, clear the upload message and trigger a refresh.
  const handleNotification = () => {
    setUploadMessage('');
    setRefreshKey(prev => prev + 1);
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Product Upload & Listing</h1>
      <CSVUpload onUploadSuccess={handleUploadSuccess} setUploadMessage={setUploadMessage} />
      {uploadMessage && <p className="mt-4 text-green-600">{uploadMessage}</p>}
      <ProductTable refreshKey={refreshKey} />
      <Notifications onNotification={handleNotification} />
    </div>
  );
};

export default App;

