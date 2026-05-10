importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyCnoaVMoFku5N_cDcgFIumu3AvMWBebyys',
  authDomain: 'hemelvaartbingo.firebaseapp.com',
  projectId: "hemelvaartbingo",
  messagingSenderId: "811255419240",
  appId: "1:811255419240:web:11063266902d5acd93c6dd",
});

const messaging = firebase.messaging();

// Important: This is what allows the "Update" button to work
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

messaging.onBackgroundMessage((message) => {
  console.log("Background Message received: ", message);
  // Customize notification display here if needed
});