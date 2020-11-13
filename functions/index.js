const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { DataSnapshot } = require('firebase-functions/lib/providers/database');
//const nodemailer = require('nodemailer');


admin.initializeApp(functions.config().firebase);

var msgData;

exports.msgTrigger = functions.firestore.document(
    'chats/{messagesId}/messages/{messages}'
).onCreate((snapshot, context) => {
    msgData = snapshot.data();
    var recipient = msgData['resiver'];
    var content = msgData['message'];
    var from = msgData['sender'];
    var nameAdmin = msgData['senderName'];


    return admin.firestore().doc('userCollection/' + recipient).get().then(userDoc => {
        const registrationTokens = userDoc.get('token')

        var payload = {
            notification: {
                title: nameAdmin,
                body:  content.length > 4 ? content.substr(0, 4) === 'http' ? 'Фото' : content : content,
                sound: "default",
                msg: 'msg',

            },
             data: {
               title: nameAdmin,
               content: content.length > 4 ? content.substr(0, 4) === 'http' ? 'Фото' : content : content,
               clickAction: 'FLUTTER_NOTIFICATION_CLICK',
               type: 'msg',
          }
        }
        return admin.messaging().sendToDevice(registrationTokens, payload).then((response) => {
            console.log('OK is OK message')
            console.log(content.length)
        }).catch((err) => { console.log(err + 'ERROR FROM ADMIN') });
    })
})