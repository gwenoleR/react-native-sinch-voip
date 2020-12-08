package io.reactnative.sinchvoip;

import android.graphics.Color;
import android.hardware.Camera;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.sinch.android.rtc.video.VideoController;
import com.sinch.android.rtc.video.VideoScalingType;

import static io.reactnative.sinchvoip.SinchVoipModule.getSinchServiceInterface;

public class SinchVoipRemoteVideoManager extends SimpleViewManager {
    private String REACT_CLASS = "SinchVoipRemoteVideo";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected View createViewInstance(@NonNull ThemedReactContext reactContext) {
        VideoController vc = getSinchServiceInterface().getVideoController();
        vc.setResizeBehaviour(VideoScalingType.ASPECT_FILL);

        View remoteVideo = vc.getRemoteView();
        remoteVideo.setBackgroundColor(Color.YELLOW);

        return remoteVideo;
    }
}
