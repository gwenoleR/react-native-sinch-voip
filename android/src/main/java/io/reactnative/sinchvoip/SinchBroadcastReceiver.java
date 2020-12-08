package io.reactnative.sinchvoip;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.NotificationManagerCompat;

import static io.reactnative.sinchvoip.SinchVoipModule.getSinchServiceInterface;

public class SinchBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = "SinchBroadcastReceiver";

    public SinchBroadcastReceiver() {
        super();
        Log.d(TAG, "create broadcast receiver instance");
    }

    Class getMainActivityClass(Context c) {
        String packageName = c.getPackageName();
        Intent launchIntent = c.getPackageManager().getLaunchIntentForPackage(packageName);
        String className = launchIntent.getComponent().getClassName();
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);

        switch (intent.getAction()){
            case "ACTION_REJECT_CALL":
                notificationManager.cancel(74);
                getSinchServiceInterface().getCall().hangup();
                break;
            case "ACTION_ACCEPT_CALL":
                notificationManager.cancel(74);
                Intent i = new Intent(context, getMainActivityClass(context));
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(i);
                getSinchServiceInterface().getCall().answer();
                break;
            case "MISSED_CALL":
                Log.d("SinchVoip", "Missed call");
                break;
            case "CLOSE_NOTIFICATION":
                Log.d("SinchVoip", "Close notification call");
                notificationManager.cancel(74);
                break;
            default:
                throw new IllegalStateException("Unexpected value: " + intent.getAction());
        }
    }
}
