import React, { useState } from 'react';
import { Product } from '../api/products';
import { format } from 'date-fns';

interface ProductRowProps {
  product: Product;
}

const ProductRow: React.FC<ProductRowProps> = ({ product }) => {
  const [expanded, setExpanded] = useState(false);

  const toggleExpand = () => setExpanded(prev => !prev);

  const formatPrice = (price: string, currency: string) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
    }).format(parseFloat(price));
  };

  return (
    <>
      <tr>
        <td className="border p-2">{product.name}</td>
        <td className="border p-2">{formatPrice(product.price, product.currency)}</td>
        <td className="border p-2">{format(new Date(product.expiration), 'MM/dd/yyyy')}</td>
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
                    <strong>{key}:</strong> {formattedConverted}
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
