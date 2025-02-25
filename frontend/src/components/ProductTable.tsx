import React, { useEffect, useState } from 'react';
import { fetchProducts, Product, ApiResponse } from '../api/products';
import ProductRow from './ProductRow';
import Pagination from './Pagination';

interface ProductTableProps {
  refreshKey: number;
}

const ProductTable: React.FC<ProductTableProps> = ({ refreshKey }) => {
  const [data, setData] = useState<ApiResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [filterText, setFilterText] = useState('');
  const [sortField, setSortField] = useState('name');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');

  const perPage = 10;

  const loadProducts = async (page: number) => {
    setLoading(true);
    try {
      const params = {
        page,
        per_page: perPage,
        name: filterText || undefined,
        sort: sortField,
        order: sortOrder,
      };
      const result = await fetchProducts(params);
      setData(result);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProducts(currentPage);
  }, [refreshKey, currentPage, filterText, sortField, sortOrder]);

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
      <h2 className="text-xl font-semibold mb-4">Filter by product name</h2>
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
        <div className="flex items-center justify-center h-64">
          <div className="w-16 h-16 border-4 border-blue-500 border-dashed rounded-full animate-spin"></div>
        </div>
      ) : data && data.products.length > 0 ? (
        <>
          <table className="min-w-full border-collapse">
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

