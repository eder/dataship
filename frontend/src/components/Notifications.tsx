import React, { useEffect, useState } from 'react';
import ActionCable from 'actioncable';

interface NotificationsProps {
  onNotification: () => void;
}

const Notifications: React.FC<NotificationsProps> = ({ onNotification }) => {
  const [notification, setNotification] = useState('');

  const wsUrl = 'ws://localhost/cable';
  const channel = 'NotificationsChannel';

  useEffect(() => {
    const cable = ActionCable.createConsumer(wsUrl);
    const subscription = cable.subscriptions.create(channel, {
      received: (data: any) => {
        setNotification(data.message);
        onNotification();
        setTimeout(() => setNotification(''), 5000);
      },
    });

    return () => {
      cable.subscriptions.remove(subscription);
    };
  }, [onNotification, wsUrl, channel]);

  return (
    <>
      {notification && (
        <div className="fixed top-4 left-1/2 transform -translate-x-1/2 bg-blue-500 text-white p-4 rounded shadow">
          {notification}
        </div>
      )}
    </>
  );
};

export default Notifications;

