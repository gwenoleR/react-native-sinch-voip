import React from 'react';
import {Call, LocalCameraView} from 'react-native-sinch-voip';

export const CallScreen = ({route, navigation}) => {
  const incoming = route.params?.incoming;
  const camera = route.params?.camera;

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
        <LocalCameraView
          style={{
            width: 110,
            height: 156,
            position: 'absolute',
            top: 40,
            right: 16,
            borderRadius: 10,
            overflow: 'hidden',
          }}
        />
      )}
    </>
  );
};
