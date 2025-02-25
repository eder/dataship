// src/components/ProductRow.tsx
import React, { useState } from 'react';
import DOMPurify from 'dompurify';
import { Product } from '../api/products';
import { formatInTimeZone } from 'date-fns-tz';

const sanitize = (text: string): string => {
  return DOMPurify.sanitize(text, { ALLOWED_TAGS: [], ALLOWED_ATTR: [] });
};

interface ProductRowProps {
  product: Product;
}

const ProductRow: React.FC<ProductRowProps> = ({ product }) => {
  const [expanded, setExpanded] = useState(false);

  const toggleExpand = () => setExpanded((prev) => !prev);

  // Format the product's price using its currency.
  const formattedPrice = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: product.currency,
  }).format(product.price);

  // Format expiration date in UTC.
  const formattedDate = formatInTimeZone(
    new Date(product.expiration + 'T00:00:00Z'),
    'UTC',
    'MM/dd/yyyy'
  );

  return (
    <>
      <tr>
        <td className="border p-2">{sanitize(product.name)}</td>
        <td className="border p-2">{formattedPrice}</td>
        <td className="border p-2">{formattedDate}</td>
        <td className="border p-2">
          <button onClick={toggleExpand} className="text-blue-500 underline">
            {expanded ? 'Hide Comparisons' : 'Show Comparisons'}
          </button>
        </td>
      </tr>
      {expanded && (
        <tr>
          <td className="border p-2" colSpan={4}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {Object.entries(product.comparisons).map(([currency, comp]) => {
                const formattedComparisonPrice = new Intl.NumberFormat('en-US', {
                  style: 'currency',
                  currency,
                }).format(comp.price);
                return (
                  <div key={currency} className="p-4 border rounded shadow-sm">
                    <h4 className="font-bold">{sanitize(currency)}</h4>
                    <p>
                      <span className="font-medium">Rate:</span> {comp.exchangeRate.toFixed(4)}
                    </p>
                    <p>
                      <span className="font-medium">Converted Price:</span> {formattedComparisonPrice}
                    </p>
                  </div>
                );
              })}
            </div>
          </td>
        </tr>
      )}
    </>
  );
};

export default ProductRow;

