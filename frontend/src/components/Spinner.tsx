import React from 'react';

const Spinner: React.FC = () => {
  return (
    <div className="flex items-center justify-center h-64">
      <div className="w-16 h-16 border-4 border-blue-500 border-dashed rounded-full animate-spin"></div>
    </div>
  );
};

export default Spinner;
