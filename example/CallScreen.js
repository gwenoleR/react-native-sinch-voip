import React from 'react';
import {TouchableOpacity} from 'react-native';
import SinchVoip, {Call, LocalCameraView} from 'react-native-sinch-voip';

export const CallScreen = ({route, navigation}) => {
  const incoming = route.params?.incoming;
  const camera = route.params?.camera;

  const switchCamera = () => {
    SinchVoip.switchCamera();
  };

  return (
    <>
      <Call
        incoming={incoming}
        camera={camera}
        onCallEnd={() => {
          navigation.goBack();
        }}
      />
      {camera && (
        <TouchableOpacity
          onPress={switchCamera}
          style={{
            width: 110,
            height: 156,
            position: 'absolute',
            top: 40,
            right: 16,
            borderRadius: 10,
            overflow: 'hidden',
          }}>
          <LocalCameraView
            style={{
              flex: 1,
            }}
          />
        </TouchableOpacity>
      )}
    </>
  );
};
