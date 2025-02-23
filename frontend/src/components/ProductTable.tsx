import React, { useEffect, useState } from 'react';
import { fetchProducts, Product, PaginatedProducts } from '../api/products';
import { format } from 'date-fns';

interface ProductTableProps {
  refreshKey: number;
}

const ProductTable: React.FC<ProductTableProps> = ({ refreshKey }) => {
  const [data, setData] = useState<PaginatedProducts | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const perPage = 10;
  const [filterText, setFilterText] = useState('');
  const [sortField, setSortField] = useState('name');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');

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

  const totalPages = data ? Math.ceil(data.total_results / data.per_page) : 1;

  const handlePrev = () => {
    if (currentPage > 1) setCurrentPage(currentPage - 1);
  };

  const handleNext = () => {
    if (data && currentPage < totalPages) setCurrentPage(currentPage + 1);
  };

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
        <div className="flex space-x-2">
          <button onClick={handlePrev} disabled={currentPage === 1} className="px-4 py-2 bg-gray-200 rounded disabled:opacity-50">
            Prev
          </button>
          <button onClick={handleNext} disabled={data && currentPage >= totalPages} className="px-4 py-2 bg-gray-200 rounded disabled:opacity-50">
            Next
          </button>
        </div>
      </div>
      {loading ? (
        <p>Loading products...</p>
      ) : data && data.products.length > 0 ? (
        <>
          <table className="min-w-full border-collapse">
            <thead>
              <tr>
                <th className="border p-2 cursor-pointer" onClick={() => handleSort('name')}>Product Name</th>
                <th className="border p-2 cursor-pointer" onClick={() => handleSort('price')}>Price</th>
                <th className="border p-2 cursor-pointer" onClick={() => handleSort('expiration')}>Expiration Date</th>
              </tr>
            </thead>
            <tbody>
              {data.products.map((product, index) => (
                <tr key={index}>
                  <td className="border p-2">{product.name}</td>
                  <td className="border p-2">{product.price}</td>
                  <td className="border p-2">{format(new Date(product.expiration), 'MM/dd/yyyy')}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="mt-4 text-sm text-gray-600">
            Page {data.current_page} of {totalPages} | Total Results: {data.total_results}
          </div>
        </>
      ) : (
        <p>No products found.</p>
      )}
    </div>
  );
};

export default ProductTable;
