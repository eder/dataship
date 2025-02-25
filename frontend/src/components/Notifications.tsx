import React, { useEffect, useState } from 'react';
import ActionCable from 'actioncable';

const WS_URL = import.meta.env.VITE_WS_URL;
const CABLE_CHANNEL = import.meta.env.VITE_CABLE_CHANNEL;

interface NotificationsProps {
  onNotification: () => void;
}

const Notifications: React.FC<NotificationsProps> = ({ onNotification }) => {
  const [notification, setNotification] = useState('');

  useEffect(() => {
    const cable = ActionCable.createConsumer(WS_URL);
    const subscription = cable.subscriptions.create(CABLE_CHANNEL || 'NotificationsChannel', {
      received: (data: any) => {
        setNotification(data.message);
        onNotification();
        setTimeout(() => setNotification(''), 5000);
      },
    });

    return () => {
      cable.subscriptions.remove(subscription);
    };
  }, [onNotification]);

  return (
    <>
      {notification && (
        <div className="fixed top-4 right-4 bg-blue-500 text-white p-4 rounded shadow">
          {notification}
        </div>
      )}
    </>
  );
};

export default Notifications;
