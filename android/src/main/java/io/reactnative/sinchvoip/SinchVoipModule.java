package io.reactnative.sinchvoip;

import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.sinch.android.rtc.calling.Call;


import static android.content.Context.BIND_AUTO_CREATE;

@ReactModule(name = SinchVoipModule.REACT_CLASS)
public class SinchVoipModule extends ReactContextBaseJavaModule implements ServiceConnection {
    public static final String REACT_CLASS = "SinchVoip";
    public static ReactApplicationContext mContext;

    private static SinchVoipService.SinchServiceInterface mSinchServiceInterface;

    public static SinchVoipService.SinchServiceInterface getSinchServiceInterface() {
        return mSinchServiceInterface;
    }

    private void bindService() {
        Intent serviceIntent = new Intent(getReactApplicationContext(), SinchVoipService.class);
        getReactApplicationContext().bindService(serviceIntent, this, BIND_AUTO_CREATE);
    }


    @Override
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        if (SinchVoipService.class.getName().equals(componentName.getClassName())) {
            mSinchServiceInterface = (SinchVoipService.SinchServiceInterface) iBinder;
        }
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {
        if (SinchVoipService.class.getName().equals(componentName.getClassName())) {
            mSinchServiceInterface = null;
        }
    }

    public SinchVoipModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
        bindService();
    }

    private void sendEvent(ReactContext reactContext,
                                 String eventName,
                                 @Nullable WritableMap params) {

        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    public static void sendEvent(
                           String eventName,
                           @Nullable WritableMap params) {

        mContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }


    @Override
    public String getName() {
        return "SinchVoip";
    }

    @ReactMethod
    public void initClient(final String applicationKey, final String applicationSecret, final String environmentHost, final String userId, final String userDisplayName) {
        System.out.println("SinchVoip::Init Client with id " + userId);

        mSinchServiceInterface.startClient(applicationKey, applicationSecret, environmentHost, userId, userDisplayName);

    }

    @ReactMethod
    public void terminate() {
        Log.d("SinchVoip", "terminate");
        mSinchServiceInterface.stopClient();
    }

    @ReactMethod
    public void callUserWithIdUsingVideo(String userId){
        Log.d("SinchVoip", "CallUserUsingVideo");
        mSinchServiceInterface.callUser(userId, true);
    }

    @ReactMethod
    public void callUserWithId(String userId) {
        Log.d("SinchVoip", "CallUser");
        mSinchServiceInterface.callUser(userId, false);
    }

    @ReactMethod
    public void hangup() {
        Log.d("SinchVoip", "hangup");
        Call call = mSinchServiceInterface.getCall();
        if(call != null){
            call.hangup();
        }
    }

    @ReactMethod
    public void answer() {
        Log.d("SinchVoip", "hangup");
        Call call = mSinchServiceInterface.getCall();
        if(call != null){
            call.answer();
        }
    }

    @ReactMethod
    public void mute(){
        mSinchServiceInterface.getAudioController().mute();
    }

    @ReactMethod
    public void unmute() {
        mSinchServiceInterface.getAudioController().unmute();
    }

    @ReactMethod
    public void enableSpeaker() {
        mSinchServiceInterface.getAudioController().enableSpeaker();
    }

    @ReactMethod
    public void disableSpeaker() {
        mSinchServiceInterface.getAudioController().disableSpeaker();
    }

    @ReactMethod
    public void pauseVideo() {
        Call call = mSinchServiceInterface.getCall();
        if(call != null) {
            call.pauseVideo();
        }
    }

    @ReactMethod
    public void resumeVideo(){
        Call call = mSinchServiceInterface.getCall();
        if(call != null) {
            call.resumeVideo();
        }
    }

    @ReactMethod
    public void switchCamera(){
        mSinchServiceInterface.getVideoController().toggleCaptureDevicePosition();
    }

    @ReactMethod
    public void hasCurrentEstablishedCall(){
        Call call = mSinchServiceInterface.getCall();
        if( call != null) {
            WritableMap params = Arguments.createMap();
            params.putBoolean("inCall", true);
            params.putString("remoteUserId", call.getRemoteUserId());
            params.putBoolean("useVideo", call.getDetails().isVideoOffered());

            sendEvent(mContext, "hasCurrentCall", params);
        }
    }

    @ReactMethod
    public void stopListeningOnActiveConnection() {
        mSinchServiceInterface.stopClient();
    }

    @ReactMethod
    public void reportIncommingCallFromPush(ReadableMap remoteMessage){
        if(remoteMessage.hasKey("sinch")){
            try {
                mSinchServiceInterface.relayRemotePushNotificationPayload(remoteMessage.getString("sinch"));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

    }
}
