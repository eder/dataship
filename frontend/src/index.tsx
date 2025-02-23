import React from 'react';
import ReactDOM from 'react-dom/client';

const App = () => {
  return <h1>Hello World</h1>;
};

const rootElement = document.getElementById('root') as HTMLElement;
const root = ReactDOM.createRoot(rootElement);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
