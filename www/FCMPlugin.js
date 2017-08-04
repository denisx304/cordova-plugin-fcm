var exec = require('cordova/exec');

function FCMPlugin() { 
	console.log("FCMPlugin.js: is created");
}

// SUBSCRIBE TO TOPIC //
FCMPlugin.prototype.subscribeToTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'subscribeToTopic', [topic]);
}
// UNSUBSCRIBE FROM TOPIC //
FCMPlugin.prototype.unsubscribeFromTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'unsubscribeFromTopic', [topic]);
}
// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotification = function( callback, success, error ){
	FCMPlugin.prototype.onNotificationReceived = callback;
	exec(success, error, "FCMPlugin", 'registerNotification',[]);
}
// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefresh = function( callback ){
	FCMPlugin.prototype.onTokenRefreshReceived = callback;
}
// GET TOKEN //
FCMPlugin.prototype.getToken = function( success, error ){
	exec(success, error, "FCMPlugin", 'getToken', []);
}
// CANCEL //
FCMPlugin.prototype.cancel = function( tag, id, success, error ){
	exec(success, error, "FCMPlugin", 'cancel', [tag, id]);
}
// CANCEL ALL //
FCMPlugin.prototype.cancelAll = function( tag, id, success, error ){
	exec(success, error, "FCMPlugin", 'cancelAll', [tag, id]);
}
// SET BADGE NUMBER //
FCMPlugin.prototype.setBadgeNumber = function( number, success, error ){
	exec(success, error, "FCMPlugin", 'setBadgeNumber', [number]);
}
// DECREMENT BADGE NUMBER //
FCMPlugin.prototype.decrementBadgeNumber = function( number, success, error ){
	exec(success, error, "FCMPlugin", 'decrementBadgeNumber', [number]);
}
// CLEAR BADGE NUMBER //
FCMPlugin.prototype.clearBadgeNumber = function( success, error ){
	exec(success, error, "FCMPlugin", 'clearBadgeNumber');
}
// ADD LOCAL NOTIFICATION //
FCMPlugin.prototype.addNotification = function( notification, success, error ){
	exec(success, error, "FCMPlugin", 'addNotification', [notification]);
}

// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}
// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefreshReceived = function(token){
	console.log("Received token refresh")
	console.log(token)
}
// FIRE READY //
exec(function(result){ console.log("FCMPlugin Ready OK") }, function(result){ console.log("FCMPlugin Ready ERROR") }, "FCMPlugin",'ready',[]);





var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
