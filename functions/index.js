const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {initializeApp} = require('firebase-admin/app');
const {getMessaging} = require('firebase-admin/messaging');

initializeApp();

exports.sendNotification = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const title = String(data.title || 'Study Armenia LK');
    const body = String(data.message || 'You have a new update.');
    await getMessaging().send({
      topic: 'all_users',
      notification: {title, body},
      data: {
        notificationId: event.params.notificationId,
        route: 'notifications',
      },
      android: {priority: 'high'},
    });
  },
);
