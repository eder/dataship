import axios from 'axios';

export interface Meta {
  current_page: number;
  per_page: number;
  total_results: number;
}

export interface Comparison {
  exchangeRate: number;
  price: number;
}

export interface Product {
  id: number;
  name: string;
  price: number;
  currency: string;
  expiration: string;
  comparisons: Record<string, Comparison>;
}

export interface ApiResponse {
  meta: Meta;
  products: Product[];
}

const API_BASE_URL = '/api/products';

export const uploadProducts = async (file: File, onProgress: (progress: number) => void): Promise<any> => {
  const formData = new FormData();
  formData.append('file', file);

  const response = await axios.post(`${API_BASE_URL}/upload`, formData, {
    headers: {'Content-Type': 'multipart/form-data'},
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
} = {}): Promise<ApiResponse> => {
  const response = await axios.get(API_BASE_URL, {params});
  return response.data;
};

