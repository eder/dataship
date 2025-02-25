import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import ProductRow from '../components/ProductRow';
import { Product } from '../api/products';

describe('ProductRow Component', () => {
  const product: Product = {
    id: 1,
    name: 'Test Product',
    price: 10,
    currency: 'USD',
    expiration: '2025-12-31',
    comparisons: {
      BRL: { exchangeRate: 5.73, price: 57.73 },
      CNY: { exchangeRate: 7.25, price: 72.50 },
      INR: { exchangeRate: 86.62, price: 866.20 },
      RUB: { exchangeRate: 88.73, price: 887.30 },
      USD: { exchangeRate: 1, price: 10 },
      ZAR: { exchangeRate: 18.33, price: 183.30 },
    },
  };

  test('renders product details correctly', () => {
    render(
      <table>
        <tbody>
          <ProductRow product={product} />
        </tbody>
      </table>
    );
    // Verify product details are rendered.
    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('$10.00')).toBeInTheDocument();
    expect(screen.getByText('12/31/2025')).toBeInTheDocument();
  });

  test('toggles comparisons display when button is clicked', () => {
    render(
      <table>
        <tbody>
          <ProductRow product={product} />
        </tbody>
      </table>
    );
    // Initially, the button should display "Show Comparisons"
    const toggleButton = screen.getByText('Show Comparisons');
    fireEvent.click(toggleButton);
    // After clicking, it should change to "Hide Comparisons"
    expect(screen.getByText('Hide Comparisons')).toBeInTheDocument();
    // Verify that at least one comparison card is rendered by checking that multiple "Rate:" labels exist.
    expect(screen.getAllByText(/Rate:/i).length).toBeGreaterThan(0);

    // Toggle back to hide comparisons.
    fireEvent.click(screen.getByText('Hide Comparisons'));
    expect(screen.getByText('Show Comparisons')).toBeInTheDocument();
  });
});

