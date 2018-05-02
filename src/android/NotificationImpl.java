package com.gae.scaffolder.plugin;


import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import de.appplant.cordova.plugin.badge.BadgeImpl;
import ro.atlas.app.R;

public class NotificationImpl {

    private static final BadgeImpl badgeImpl = new BadgeImpl();

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     */
    public static void sendNotification(Map<String, String> data, Context context) throws JSONException {
        JSONObject dataFields = new JSONObject(data.get("data"));
        String title = dataFields.getString("title");
        String messageBody = dataFields.getString("body");
        Intent intent = new Intent(context, FCMPluginActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        for (String key : data.keySet()) {
            intent.putExtra(key, data.get(key).toString());
        }
        PendingIntent pendingIntent = PendingIntent.getActivity(context,
                dataFields.getInt("notificationID") /* Request code */,
                intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        int color = Color.parseColor("#ff9415");
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.ic_stat_onesignal_default)
                .setColor(color)
                .setContentTitle(title)
                .setContentText(messageBody)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(dataFields.getString("tag"), dataFields.getInt("notificationID") /* ID of notification */, notificationBuilder.build());
        if (dataFields.has("unreadMessagesCount")) {
            badgeImpl.setBadge(dataFields.getInt("unreadMessagesCount"), context);
        }
    }

    public static void updateNotificationsAndBadgeNumber(Map<String, String> data, Context context) throws JSONException {
        JSONObject dataFields = new JSONObject(data.get("data"));
        Long partnerID = dataFields.getLong("partnerID");
        String partnerEmail = dataFields.getString("partnerEmail");
        int readMessagesCount = dataFields.getInt("readMessagesCount");

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(partnerEmail, partnerID.intValue());

        if (readMessagesCount > 0) {
            badgeImpl.setBadge(badgeImpl.getBadge(context) - readMessagesCount, context);
        }
    }
}
