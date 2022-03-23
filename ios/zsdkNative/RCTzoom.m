//
//  RCTzoom.m
//  zsdkNative
//
//  Created by Mahmoud Hamdy on 22/03/2022.
//

#import <ReplayKit/ReplayKit.h>
#import "RCTzoom.h"
//#import "ZoomManager.h"

@implementation RCTzoom
{
  BOOL isInitialized;
  BOOL shouldAutoConnectAudio;
  BOOL hasObservers;
  RCTPromiseResolveBlock initializePromiseResolve;
  RCTPromiseRejectBlock initializePromiseReject;
  RCTPromiseResolveBlock meetingPromiseResolve;
  RCTPromiseRejectBlock meetingPromiseReject;
  // If screenShareExtension is set, the Share Content > Screen option will automatically be
  // enabled in the UI
  NSString *screenShareExtension;

  NSString *jwtToken;
}


- (instancetype)init {
  if (self = [super init]) {
    isInitialized = NO;
    initializePromiseResolve = nil;
    initializePromiseReject = nil;
    shouldAutoConnectAudio = nil;
    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
    screenShareExtension = nil;
    jwtToken = nil;
  }
  return self;
}

// this macro will export this class to React Native as AwesomeZoomSDK - RCT prefix is removed!
RCT_EXPORT_MODULE();


// check if isInitialized
RCT_EXPORT_METHOD(isInitialized: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  @try {
    // todo check from ZoomSdk
    resolve(@(isInitialized));
  } @catch (NSError *ex) {
    reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing isInitialized", ex);
  }
}

//let's init Zoom SDK
RCT_EXPORT_METHOD(initZoom:(NSString *)jwtToken
                  domain:(NSString *)domain
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  if (isInitialized) {
    resolve(@"Already initialize Zoom SDK successfully.");
    return;
  }

  
  MobileRTCSDKInitContext* initContext = [[MobileRTCSDKInitContext alloc] init];
  initContext.domain = @"https://zoom.us";
  // Set your Apple AppGroupID here
  initContext.appGroupId = @"com.ouredu.net";
  // Turn on SDK logging
  initContext.enableLog = YES;
  initContext.locale = MobileRTC_ZoomLocale_Default;
  if ([[MobileRTC sharedRTC] initialize:initContext]) {
      MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
      if (authService) {
        @try {
          authService.jwtToken = jwtToken;
          authService.delegate = self;
          [authService sdkAuth];
          isInitialized = true;
        } @catch (NSException *exception) {
          NSLog(@"%@", jwtToken);
        }
      }
  }

}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
    switch (returnValue) {
        case MobileRTCAuthError_Success:
            NSLog(@"SDK successfully initialized.");
            break;
        case MobileRTCAuthError_KeyOrSecretEmpty:
            NSLog(@"SDK key/secret was not provided. Replace sdkKey and sdkSecret at the top of this file with your SDK key/secret.");
            break;
        case MobileRTCAuthError_KeyOrSecretWrong:
            NSLog(@"SDK key/secret is not valid.");
            break;
        case MobileRTCAuthError_Unknown:
            NSLog(@"SDK key/secret is not valid.");
            break;
        default:
            NSLog(@"SDK Authorization failed with MobileRTCAuthError: %u", returnValue);
    }
}

//--------------------------------LOGIN-END

RCT_EXPORT_METHOD(
  startMeeting: (NSDictionary *)data
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
 
  @try {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
      ms.delegate = self;
      

      MobileRTCMeetingStartParam4WithoutLoginUser * params = [[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init];
      params.userName = data[@"userName"];
      params.meetingNumber = data[@"meetingNumber"];
      params.userID = data[@"userId"];
      params.userType = 99;
      params.zak = data[@"zoomAccessToken"];
      MobileRTCMeetError startMeetingResult = [ms startMeetingWithStartParam:params];
      NSLog(@"startMeeting, startMeetingResult=%lu", startMeetingResult);
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
  }
}


// JOIN MEETING

RCT_EXPORT_METHOD(
 joinMeeting:(NSString *)meetingNumber meetingPassword:(NSString *)meetingPassword {
  // Get MobileRTCMeetingService instance from sharedRTC
   @try {
     MobileRTCMeetingService *meetService = [[MobileRTC sharedRTC] getMeetingService];
         if (meetService) {
             MobileRTCMeetingJoinParam *joinParams = [[MobileRTCMeetingJoinParam alloc] init];
             joinParams.meetingNumber = meetingNumber;
             joinParams.password = meetingPassword;
           [meetService joinMeetingWithJoinParam:joinParams];
         }
     }
    @catch(NSError *ex){
      NSLog(ex);
   }
 }
 
)

- (void)onMeetingStateChange:(MobileRTCMeetingState)state;
{
  NSString* statusString = [self formatStateToString:state];
  NSLog(@"%@:", statusString);
}

- (NSString*)formatStateToString:(MobileRTCMeetingState)state {
    NSString *result = nil;

    // naming synced with android enum MeetingStatus
    switch(state) {
        case MobileRTCMeetingState_Connecting:
            result = @"MEETING_STATUS_CONNECTING";
            break;
        case MobileRTCMeetingState_Idle:
            result = @"MEETING_STATUS_IDLE";
            break;
        case MobileRTCMeetingState_Failed:
            result = @"MEETING_STATUS_FAILED";
            break;
        case MobileRTCMeetingState_WebinarPromote:
            result = @"MEETING_STATUS_WEBINAR_PROMOTE";
            break;
        case MobileRTCMeetingState_WebinarDePromote:
            result = @"MEETING_STATUS_WEBINAR_DEPROMOTE";
            break;
        case MobileRTCMeetingState_InWaitingRoom:
            result = @"MEETING_STATUS_IN_WAITING_ROOM";
            break;
        case MobileRTCMeetingState_WaitingForHost:
            result = @"MEETING_STATUS_WAITINGFORHOST";
            break;
        case MobileRTCMeetingState_Disconnecting:
            result = @"MEETING_STATUS_DISCONNECTING";
            break;
        case MobileRTCMeetingState_InMeeting:
            result = @"MEETING_STATUS_INMEETING";
            break;
        case MobileRTCMeetingState_Reconnecting:
            result = @"MEETING_STATUS_RECONNECTING";
            break;
        case MobileRTCMeetingState_Unknow:
            result = @"MEETING_STATUS_UNKNOWN";
            break;

        // only iOS (guessed naming)
        case MobileRTCMeetingState_WaitingExternalSessionKey:
            result = @"MEETING_STATUS_WAITING_EXTERNAL_SESSION_KEY";
            break;
        case MobileRTCMeetingState_Ended:
            result = @"MEETING_STATUS_ENDED";
            break;
        case MobileRTCMeetingState_Locked:
            result = @"MEETING_STATUS_LOCKED";
            break;
        case MobileRTCMeetingState_Unlocked:
            result = @"MEETING_STATUS_UNLOCKED";
            break;
        case MobileRTCMeetingState_JoinBO:
            result = @"MEETING_STATUS_JOIN_BO";
            break;
        case MobileRTCMeetingState_LeaveBO:
            result = @"MEETING_STATUS_LEAVE_BO";
            break;

        default:
            [NSException raise:NSGenericException format:@"Unexpected state."];
    }

    return result;
}
// TODO - neccesary
+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

@end
