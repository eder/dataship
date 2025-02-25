import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import Pagination from '../components/Pagination';

describe('Pagination Component', () => {
  const setCurrentPage = jest.fn();

  test('renders Prev, Next and page number buttons', () => {
    render(<Pagination currentPage={3} totalPages={5} setCurrentPage={setCurrentPage} />);
    expect(screen.getByText('Prev')).toBeInTheDocument();
    expect(screen.getByText('Next')).toBeInTheDocument();
    // Verifica se o botão "4" aparece e dispara a mudança de página ao ser clicado
    const pageButton = screen.getByText('4');
    fireEvent.click(pageButton);
    expect(setCurrentPage).toHaveBeenCalledWith(4);
  });
});

