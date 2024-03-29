//
//  SinchVoip.m
//
//  Created by Gwenole ROTON on 16/11/2020.

#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(SinchVoip, RCTEventEmitter)

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXTERN_METHOD(supportedEvents)

RCT_EXTERN_METHOD(initClient:(NSString *)applicationKey applicationSecret:(NSString *)applicationSecret environmentHost:(NSString *)environmentHost userId:(NSString *)userId userDisplayName:(NSString *)userDisplayName usePushNotification:(BOOL)usePushNotification)

RCT_EXTERN_METHOD(startListeningOnActiveConnection)

RCT_EXTERN_METHOD(stopListeningOnActiveConnection)

RCT_EXTERN_METHOD(callUserWithId:(NSString *)userId)

RCT_EXTERN_METHOD(callUserWithIdUsingVideo:(NSString *)userId)

RCT_EXTERN_METHOD(answer)

RCT_EXTERN_METHOD(hangup)

RCT_EXTERN_METHOD(mute)

RCT_EXTERN_METHOD(unmute)

RCT_EXTERN_METHOD(enableSpeaker)

RCT_EXTERN_METHOD(disableSpeaker)

RCT_EXTERN_METHOD(resumeVideo)

RCT_EXTERN_METHOD(pauseVideo)

RCT_EXTERN_METHOD(switchCamera)

RCT_EXTERN_METHOD(hasCurrentEstablishedCall)

RCT_EXTERN_METHOD(isStarted: (RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)


@end
