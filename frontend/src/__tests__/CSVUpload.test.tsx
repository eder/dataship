import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import CSVUpload from '../components/CSVUpload';
import * as productsAPI from '../api/products';

jest.mock('../api/products');

describe('CSVUpload Component', () => {
  const onUploadSuccess = jest.fn();
  const setUploadMessage = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('displays success message and calls onUploadSuccess after file upload', async () => {
    // Mock the uploadProducts function to simulate upload progress and resolve
    (productsAPI.uploadProducts as jest.Mock).mockImplementation((file, onProgress) => {
      onProgress(100);
      return Promise.resolve({ message: 'Upload done' });
    });

    render(<CSVUpload onUploadSuccess={onUploadSuccess} setUploadMessage={setUploadMessage} />);

    // Simulate file selection
    const file = new File(["name,price,expiration"], "test.csv", { type: 'text/csv' });
    const inputElement = screen.getByTestId('file-input');
    fireEvent.change(inputElement, { target: { files: [file] } });

    // Wait for the success message to be set via setUploadMessage
    await waitFor(() => {
      expect(setUploadMessage).toHaveBeenCalledWith(
        'Upload successful! Your file is being processed. You will be notified when processing is complete.'
      );
    });

    expect(onUploadSuccess).toHaveBeenCalled();
  });
});

