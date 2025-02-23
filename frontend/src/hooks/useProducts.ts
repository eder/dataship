import {useEffect, useState} from 'react';
import {fetchProducts, PaginatedProducts} from '../api/products';

interface UseProductsParams {
  page: number;
  per_page?: number;
  name?: string;
  sort?: string;
  order?: 'asc' | 'desc';
}

export const useProducts = (params: UseProductsParams) => {
  const [data, setData] = useState<PaginatedProducts | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetchProducts(params)
      .then(setData)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [params]);

  return {data, loading};
};

