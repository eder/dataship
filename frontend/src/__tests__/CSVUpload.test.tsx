import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import CSVUpload from '../components/CSVUpload';
import * as productsAPI from '../api/products';

jest.mock('../api/products');

describe('CSVUpload Component', () => {
  const onUploadSuccess = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('displays success message and calls onUploadSuccess after file upload', async () => {
    (productsAPI.uploadProducts as jest.Mock).mockImplementation((file, onProgress) => {
      onProgress(100);
      return Promise.resolve({ message: 'Upload done' });
    });

    render(<CSVUpload onUploadSuccess={onUploadSuccess} />);

    const file = new File(["name,price,expiration"], "test.csv", { type: 'text/csv' });
    const inputElement = screen.getByTestId('file-input');
    fireEvent.change(inputElement, { target: { files: [file] } });

    await waitFor(() => expect(screen.getByText(/Upload successful!/i)).toBeInTheDocument());
    expect(onUploadSuccess).toHaveBeenCalled();
  });
});

