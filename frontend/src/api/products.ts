import axios from 'axios';

export interface Product {
  id: number;
  name: string;
  price: string;
  expiration: string;
  exchangeRates: {[key: string]: string};
}

export interface PaginatedProducts {
  current_page: number;
  per_page: number;
  total_results: number;
  products: Product[];
}

// TODO I need to transform this in env variable
const API_BASE_URL = '/api/products';

export const uploadProducts = async (file: File, onProgress: (progress: number) => void) => {
  const formData = new FormData();
  formData.append('file', file);

  const response = await axios.post(`${API_BASE_URL}/upload`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    onUploadProgress: (progressEvent) => {
      const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
      onProgress(progress);
    },
  });
  return response.data;
};

export const fetchProducts = async (params: {
  page?: number;
  per_page?: number;
  name?: string;
  sort?: string;
  order?: 'asc' | 'desc';
} = {}): Promise<PaginatedProducts> => {
  const response = await axios.get(API_BASE_URL, {params});
  return response.data;
};

