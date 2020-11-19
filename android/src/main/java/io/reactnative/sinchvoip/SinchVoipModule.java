package io.reactnative.sinchvoip;

import android.os.Handler;
import android.util.Log;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.sinch.android.rtc.ClientRegistration;
import com.sinch.android.rtc.PushPair;
import com.sinch.android.rtc.Sinch;
import com.sinch.android.rtc.SinchClient;
import com.sinch.android.rtc.SinchClientListener;
import com.sinch.android.rtc.SinchError;
import com.sinch.android.rtc.calling.Call;
import com.sinch.android.rtc.calling.CallClient;
import com.sinch.android.rtc.calling.CallClientListener;
import com.sinch.android.rtc.calling.CallListener;
import com.sinch.android.rtc.video.VideoCallListener;

import java.util.List;

@ReactModule(name = SinchVoipModule.REACT_CLASS)
public class SinchVoipModule extends ReactContextBaseJavaModule {
    public static final String REACT_CLASS = "SinchVoip";
    private final ReactApplicationContext mContext;
    public SinchClient sinchClient;
    private Call mCall;

    public SinchVoipModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.mContext = reactContext;
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }


    @Override
    public String getName() {
        return "SinchVoip";
    }

    @ReactMethod
    public void sampleMethod(String stringArgument, int numberArgument, Callback callback) {
        // TODO: Implement some actually useful functionality
        callback.invoke("Received numberArgument: " + numberArgument + " stringArgument: " + stringArgument);
    }

    @ReactMethod
    public void initClient(final String applicationKey, final String applicationSecret, final String environmentHost, final String userId) {
        System.out.println("SinchVoip::Init Client with id " + userId);
        final android.content.Context context = this.getReactApplicationContext();
        Handler mainHandler = new Handler(context.getMainLooper());

        Runnable mainThreadRunnable = new Runnable() {
            @Override
            public void run() {
                sinchClient = Sinch.getSinchClientBuilder().context(context)
                        .applicationKey(applicationKey)
                        .applicationSecret(applicationSecret)
                        .environmentHost(environmentHost)
                        .userId(userId)
                        .build();

                sinchClient.setSupportCalling(true);
                sinchClient.setSupportActiveConnectionInBackground(true);
                sinchClient.startListeningOnActiveConnection();

                sinchClient.start();

                sinchClient.addSinchClientListener(new SinchClientListener() {
                    public void onClientStarted(SinchClient client) {
                        Log.d("SinchVoip", "onClientStarted");

                        CallClient callClient = client.getCallClient();
                        callClient.addCallClientListener(new CallClientListener() {
                            @Override
                            public void onIncomingCall(CallClient callClient, Call call) {
                                Log.d("SinchVoip", "onIncomingCall");

                                WritableMap params = Arguments.createMap();
                                params.putString("callId", call.getCallId());
                                params.putString("userId", call.getRemoteUserId());
                                params.putBoolean("camera", call.getDetails().isVideoOffered());

                                sendEvent(mContext, "receiveIncomingCall", params);

                                call.addCallListener(new CallListener() {
                                    @Override
                                    public void onCallProgressing(Call call) {
                                        Log.d("SinchVoip", "onCallProgressing");
                                    }

                                    @Override
                                    public void onCallEstablished(Call call) {
                                        Log.d("SinchVoip", "onCallEstablished");

                                        WritableMap params = Arguments.createMap();
                                        params.putString("callId", call.getCallId());

                                        sendEvent(mContext, "callEstablish", params);

                                    }

                                    @Override
                                    public void onCallEnded(Call call) {
                                        Log.d("SinchVoip", "onCallEnded");

                                        WritableMap params = Arguments.createMap();
                                        params.putString("callId", call.getCallId());

                                        sendEvent(mContext, "callEnd", params);

                                        mCall = null;
                                    }

                                    @Override
                                    public void onShouldSendPushNotification(Call call, List<PushPair> list) {
                                        Log.d("SinchVoip", "onShouldSendPushNotification");
                                    }
                                });

                                mCall = call;
                            }
                        });



                    }

                    public void onClientStopped(SinchClient client) {
                        Log.d("SinchVoip", "onClientStopped");
                    }

                    public void onClientFailed(SinchClient client, SinchError error) {
                        Log.d("SinchVoip", "onClientFailed");
                    }

                    public void onRegistrationCredentialsRequired(SinchClient client, ClientRegistration registrationCallback) { }

                    public void onLogMessage(int level, String area, String message) { }
                });


            }
        };

        mainHandler.post(mainThreadRunnable);
    }



    @ReactMethod
    public void terminate() {
        Log.d("SinchVoip", "terminate");

        sinchClient.stopListeningOnActiveConnection();
        sinchClient.terminate();
        sinchClient = null;
    }

    @ReactMethod
    public void callUserWithIdUsingVideo(String userId){
        Log.d("SinchVoip", "CallUserUsingVideo");
        Call call = sinchClient.getCallClient().callUserVideo(userId);
        call.addCallListener(new VideoCallListener() {
            @Override
            public void onVideoTrackAdded(Call call) {
                Log.d("SinchVoip", "onVideoTrackAdded");
            }

            @Override
            public void onVideoTrackPaused(Call call) {
                Log.d("SinchVoip", "onVideoTrackPaused");
            }

            @Override
            public void onVideoTrackResumed(Call call) {
                Log.d("SinchVoip", "onVideoTrackResumed");
            }

            @Override
            public void onCallProgressing(Call call) {
                Log.d("SinchVoip", "onCallProgressing");
            }

            @Override
            public void onCallEstablished(Call call) {
                Log.d("SinchVoip", "onCallEstablished");

                WritableMap params = Arguments.createMap();
                params.putString("callId", call.getCallId());

                sendEvent(mContext, "callEstablish", params);

            }

            @Override
            public void onCallEnded(Call call) {
                Log.d("SinchVoip", "onCallEnded");

                WritableMap params = Arguments.createMap();
                params.putString("callId", call.getCallId());

                sendEvent(mContext, "callEnd", params);

                mCall = null;
            }

            @Override
            public void onShouldSendPushNotification(Call call, List<PushPair> list) {
                Log.d("SinchVoip", "onShouldSendPushNotification");
            }
        });

        mCall = call;
    }

    @ReactMethod
    public void callUserWithId(String userId) {
        Log.d("SinchVoip", "CallUser");
        Call call = sinchClient.getCallClient().callUser(userId);
        call.addCallListener(new CallListener() {
            @Override
            public void onCallProgressing(Call call) {
                Log.d("SinchVoip", "onCallProgressing");
            }

            @Override
            public void onCallEstablished(Call call) {
                Log.d("SinchVoip", "onCallEstablished");

                WritableMap params = Arguments.createMap();
                params.putString("callId", call.getCallId());

                sendEvent(mContext, "callEstablish", params);

            }

            @Override
            public void onCallEnded(Call call) {
                Log.d("SinchVoip", "onCallEnded");

                WritableMap params = Arguments.createMap();
                params.putString("callId", call.getCallId());

                sendEvent(mContext, "callEnd", params);

                mCall = null;
            }

            @Override
            public void onShouldSendPushNotification(Call call, List<PushPair> list) {
                Log.d("SinchVoip", "onShouldSendPushNotification");
            }
        });

        mCall = call;
    }

    @ReactMethod
    public void hangup() {
        Log.d("SinchVoip", "hangup");
        mCall.hangup();
        mCall = null;
    }

    @ReactMethod
    public void answer() {
        if (mCall != null) {
            Log.d("SinchVoip", "answer");
            mCall.answer();
        }
    }

    @ReactMethod
    public void mute(){
        sinchClient.getAudioController().mute();
    }

    @ReactMethod
    public void unmute() {
        sinchClient.getAudioController().unmute();
    }

    @ReactMethod
    public void enableSpeaker() {
        sinchClient.getAudioController().enableSpeaker();
    }

    @ReactMethod
    public void disableSpeaker() {
        sinchClient.getAudioController().disableSpeaker();
    }

    @ReactMethod
    public void pauseVideo() {
        mCall.pauseVideo();
    }

    @ReactMethod
    public void resumeVideo(){
        mCall.resumeVideo();
    }

    @ReactMethod
    public void switchCamera(){
        sinchClient.getVideoController().toggleCaptureDevicePosition()
    }

}
