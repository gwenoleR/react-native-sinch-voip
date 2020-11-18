import { NativeModules } from 'react-native';

const { SinchVoip } = NativeModules;

export * from './src/call-manager'
export * from './src/CallView'
export * from './src/LocalCameraView'
export * from './src/RemoteCameraView'

export default SinchVoip;