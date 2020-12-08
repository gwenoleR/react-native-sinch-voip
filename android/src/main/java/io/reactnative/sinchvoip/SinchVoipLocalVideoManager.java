package io.reactnative.sinchvoip;

import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.hardware.Camera;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.sinch.android.rtc.video.VideoController;
import com.sinch.android.rtc.video.VideoScalingType;

import static io.reactnative.sinchvoip.SinchVoipModule.getSinchServiceInterface;

public class SinchVoipLocalVideoManager extends SimpleViewManager {
    private String REACT_CLASS = "SinchVoipLocalVideo";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected View createViewInstance(@NonNull ThemedReactContext reactContext) {
//         SinchVoipModule sinchInstance = reactContext.getNativeModule(SinchVoipModule.class);

        if (ContextCompat.checkSelfPermission(reactContext, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            Log.d("SinchVoip", "Problem with permissions");
        } else {
            Log.d("SinchVoip", "Permission ok !");
        }

         VideoController vc = getSinchServiceInterface().getVideoController();
         vc.setResizeBehaviour(VideoScalingType.ASPECT_FILL);

         View localeVideo = vc.getLocalView();


         return localeVideo;
    }
}
