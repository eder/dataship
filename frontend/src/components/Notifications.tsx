import React, { useEffect, useState } from 'react';
import ActionCable from 'actioncable';

interface NotificationsProps {
  onNotification: () => void;
}

const Notifications: React.FC<NotificationsProps> = ({ onNotification }) => {
  const [notification, setNotification] = useState('');

  useEffect(() => {
    const cable = ActionCable.createConsumer('ws://localhost/cable');
    const subscription = cable.subscriptions.create('NotificationsChannel', {
      received: (data: any) => {
        setNotification(data.message);
        onNotification(); // Atualiza a tabela quando a notificação chega
        setTimeout(() => setNotification(''), 3000);
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
