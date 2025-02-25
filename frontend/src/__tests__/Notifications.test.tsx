import React from 'react';
import { render, screen, act, waitFor } from '@testing-library/react';
import Notifications from '../components/Notifications';
import ActionCable from 'actioncable';

jest.mock('actioncable');

process.env.VITE_WS_URL = 'ws://localhost/cable';
process.env.VITE_CABLE_CHANNEL = 'NotificationsChannel';

describe('Notifications Component', () => {
  const onNotification = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  test('displays notification message when received and calls onNotification', async () => {
    // Cria um fake consumer que, quando subscriptions.create for chamado, retorna o objeto de callbacks
    const fakeConsumer = {
      subscriptions: {
        create: jest.fn((channel, callbacks) => callbacks),
        remove: jest.fn(),
      },
    };
    (ActionCable.createConsumer as jest.Mock).mockReturnValue(fakeConsumer);

    render(<Notifications onNotification={onNotification} />);

    expect(fakeConsumer.subscriptions.create).toHaveBeenCalledWith(
      'NotificationsChannel',
      expect.any(Object)
    );

    const callbacks = fakeConsumer.subscriptions.create.mock.calls[0][1];

    act(() => {
      callbacks.received({ message: 'Processing complete' });
    });

    act(() => {
      jest.advanceTimersByTime(500);
    });

    await waitFor(() => {
      expect(screen.getByText(/Processing complete/i)).toBeInTheDocument();
    });

    expect(onNotification).toHaveBeenCalled();
  });
});

