import { renderHook, waitFor } from '@testing-library/react';
import { useProducts } from '../hooks/useProducts';
import * as api from '../api/products';

jest.mock('../api/products');

describe('useProducts Hook', () => {
  test('fetches products and updates state correctly', async () => {
    const mockResponse = {
      meta: { current_page: 1, per_page: 10, total_results: 20 },
      products: [],
    };
    (api.fetchProducts as jest.Mock).mockResolvedValueOnce(mockResponse);

    const { result } = renderHook(() => useProducts({ page: 1, per_page: 10 }));

    // Inicialmente deve estar carregando
    expect(result.current.loading).toBe(true);

    // Aguarda até que loading seja false
    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.data).toEqual(mockResponse);
  });
});

