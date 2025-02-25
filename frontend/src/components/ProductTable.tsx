// src/components/ProductTable.tsx
import React, { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { fetchProducts, Product, ApiResponse } from '../api/products';
import ProductRow from './ProductRow';
import Pagination from './Pagination';
import Spinner from './Spinner';
import { useProducts } from '../hooks/useProducts';

interface ProductTableProps {
  refreshKey: number;
}

const ProductTable: React.FC<ProductTableProps> = ({ refreshKey }) => {
  // Get search params from URL
  const [searchParams, setSearchParams] = useSearchParams();

  // Initialize state from URL query parameters (with defaults)
  const initialPage = Number(searchParams.get('page')) || 1;
  const initialFilter = searchParams.get('name') || '';
  const initialSort = searchParams.get('sort') || 'name';
  const initialOrder = searchParams.get('order') as 'asc' | 'desc' || 'asc';

  const [currentPage, setCurrentPage] = useState(initialPage);
  const [filterText, setFilterText] = useState(initialFilter);
  const [sortField, setSortField] = useState(initialSort);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>(initialOrder);

  // Update URL query parameters whenever the state changes
  useEffect(() => {
    const params: Record<string, string> = {
      page: currentPage.toString(),
      sort: sortField,
      order: sortOrder,
    };
    if (filterText) {
      params.name = filterText;
    }
    setSearchParams(params);
  }, [currentPage, filterText, sortField, sortOrder, setSearchParams]);

  const { data, loading } = useProducts({
    page: currentPage,
    per_page: 10,
    name: filterText,
    sort: sortField,
    order: sortOrder,
    refreshKey,
  });

  const handleSort = (field: string) => {
    if (sortField === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortOrder('asc');
    }
  };

  const totalPages = data ? Math.ceil(data.meta.total_results / data.meta.per_page) : 1;

  return (
    <div>
      <h2 className="text-xl font-semibold mb-4">Uploaded Products</h2>
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-4">
        <input
          type="text"
          placeholder="Filter by product name"
          value={filterText}
          onChange={(e) => {
            setCurrentPage(1);
            setFilterText(e.target.value);
          }}
          className="mb-2 md:mb-0 p-2 border border-gray-300 rounded"
        />
      </div>
      {loading ? (
        <Spinner />
      ) : data && data.products.length > 0 ? (
        <>
          <table id="productsTable" className="min-w-full border-collapse">
            <thead>
              <tr>
                <th className="border p-2 cursor-pointer" onClick={() => handleSort('name')}>
                  Product Name
                </th>
                <th className="border p-2 cursor-pointer" onClick={() => handleSort('price')}>
                  Price
                </th>
                <th className="border p-2 cursor-pointer" onClick={() => handleSort('expiration')}>
                  Expiration Date
                </th>
                <th className="border p-2">Exchange Rates</th>
              </tr>
            </thead>
            <tbody>
              {data.products.map((product: Product) => (
                <ProductRow key={product.id} product={product} />
              ))}
            </tbody>
          </table>
          <Pagination currentPage={currentPage} totalPages={totalPages} setCurrentPage={setCurrentPage} />
          <div className="mt-2 text-sm text-gray-600 text-center">
            Page {data.meta.current_page} of {totalPages} | Total Results: {data.meta.total_results}
          </div>
        </>
      ) : (
        <p>No products found.</p>
      )}
    </div>
  );
};

export default ProductTable;

