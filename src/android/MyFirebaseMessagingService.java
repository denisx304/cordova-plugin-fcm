package com.gae.scaffolder.plugin;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import java.util.Map;
import java.util.HashMap;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import de.appplant.cordova.plugin.badge.BadgeImpl;
import ro.atlas.app.R;

/**
 * Created by Felipe Echanique on 08/06/2016.
 */
public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "FCMPlugin";
    private final BadgeImpl badgeImpl = new BadgeImpl();

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // TODO(developer): Handle FCM messages here.
        // If the application is in the foreground handle both data and notification messages here.
        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
        Log.d(TAG, "==> MyFirebaseMessagingService onMessageReceived");
		
		Map<String, Object> data = new HashMap<String, Object>();
		data.put("wasTapped", false);
		for (String key : remoteMessage.getData().keySet()) {
                Object value = remoteMessage.getData().get(key);
                Log.d(TAG, "\tKey: " + key + " Value: " + value);
				data.put(key, value);
        }
		
		Log.d(TAG, "\tNotification Data: " + data.toString());
        //FCMPlugin.sendPushPayload( data );
        try {
            String typeOfNotification = remoteMessage.getData().get("type");
            if (typeOfNotification.equals("readMessagesUpdate")) {
                updateNotificationsAndBadgeNumber(remoteMessage.getData());
            } else if (typeOfNotification.equals("sendMessage") || typeOfNotification.equals("proactiveSearchNotification")) {
                sendNotification(remoteMessage.getData());
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    // [END receive_message]

    private void updateNotificationsAndBadgeNumber(Map<String, String> data) throws JSONException {
        JSONObject dataFields = new JSONObject(data.get("data"));
        Long partnerID = dataFields.getLong("partnerID");
        String partnerEmail = dataFields.getString("partnerEmail");
        int readMessagesCount = dataFields.getInt("readMessagesCount");

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(partnerEmail, partnerID.intValue());

        if (readMessagesCount > 0) {
            badgeImpl.setBadge(badgeImpl.getBadge(getApplicationContext()) - readMessagesCount, getApplicationContext());
        }
    }

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     */
    private void sendNotification(Map<String, String> data) throws JSONException {
        JSONObject dataFields = new JSONObject(data.get("data"));
		String title = dataFields.getString("title");
		String messageBody = dataFields.getString("body");
        Intent intent = new Intent(this, FCMPluginActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		for (String key : data.keySet()) {
			intent.putExtra(key, data.get(key).toString());
		}
        PendingIntent pendingIntent = PendingIntent.getActivity(this, dataFields.getInt("notificationID") /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        int color = Color.parseColor("#ff9415");
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_stat_onesignal_default)
                .setColor(color)
                //.setLargeIcon(BitmapFactory.decodeResource(getApplicationContext().getResources(), R.mipmap.icon))
                .setContentTitle(title)
                .setContentText(messageBody)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(dataFields.getString("tag"), dataFields.getInt("notificationID") /* ID of notification */, notificationBuilder.build());
        if (null != data.get("unreadMessagesCount")) {
            badgeImpl.setBadge(dataFields.getInt("unreadMessagesCount"), getApplicationContext());
        }
    }
}
