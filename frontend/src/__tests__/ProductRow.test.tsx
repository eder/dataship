import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import ProductRow from '../components/ProductRow';
import { Product } from '../api/products';

describe('ProductRow Component', () => {
  const product: Product = {
    id: 1,
    name: 'Test Product',
    price: '10.0',
    currency: 'USD',
    expiration: '2025-12-31',
    exchange_rates: {
      BRL: 5.73,
      CNY: 7.25,
      INR: 86.62,
      RUB: 88.73,
      USD: 1,
      ZAR: 18.33,
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
    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('$10.00')).toBeInTheDocument();
    expect(screen.getByText('12/31/2025')).toBeInTheDocument();
  });

  test('toggles exchange rates display when button is clicked', () => {
    render(
      <table>
        <tbody>
          <ProductRow product={product} />
        </tbody>
      </table>
    );
    const showButton = screen.getByText('Show Rates');
    fireEvent.click(showButton);
    expect(screen.getByText('Hide Rates')).toBeInTheDocument();
    expect(screen.getByText(/BRL:/i)).toBeInTheDocument();
    fireEvent.click(screen.getByText('Hide Rates'));
    expect(screen.getByText('Show Rates')).toBeInTheDocument();
  });
});

