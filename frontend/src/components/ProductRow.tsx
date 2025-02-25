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

  const toggleExpand = () => setExpanded(prev => !prev);

  const formatPrice = (price: string, currency: string): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
    }).format(parseFloat(price));
  };

  const formattedDate = formatInTimeZone(
    new Date(product.expiration + 'T00:00:00Z'),
    'UTC',
    'MM/dd/yyyy'
  );

  return (
    <>
      <tr>
        <td className="border p-2">{sanitize(product.name)}</td>
        <td className="border p-2">{formatPrice(product.price, product.currency)}</td>
        <td className="border p-2">{formattedDate}</td>
        <td className="border p-2">
          <button onClick={toggleExpand} className="text-blue-500 underline">
            {expanded ? 'Hide Rates' : 'Show Rates'}
          </button>
        </td>
      </tr>
      {expanded && (
        <tr>
          <td className="border p-2" colSpan={4}>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {Object.entries(product.exchange_rates).map(([key, value]) => {
                const converted = parseFloat(product.price) * value;
                const formattedConverted = new Intl.NumberFormat('en-US', {
                  style: 'currency',
                  currency: key,
                }).format(converted);
                return (
                  <div key={key} className="p-2 border rounded">
                    <strong>{sanitize(key)}:</strong> {formattedConverted}
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

