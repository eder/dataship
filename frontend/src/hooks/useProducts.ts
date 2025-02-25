import {useState, useEffect} from 'react';
import {fetchProducts, ApiResponse} from '../api/products';

interface UseProductsParams {
  page: number;
  per_page?: number;
  name?: string;
  sort?: string;
  order?: 'asc' | 'desc';
  refreshKey?: number;
}

export const useProducts = ({page, per_page = 10, name, sort, order, refreshKey}: UseProductsParams) => {
  const [data, setData] = useState<ApiResponse | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetchProducts({page, per_page, name, sort, order})
      .then(setData)
      .catch((error) => {
        console.error('Error fetching products:', error);
      })
      .finally(() => setLoading(false));
  }, [page, per_page, name, sort, order, refreshKey]);

  return {data, loading};
};

