//
//  RCTzoom.m
//  zsdkNative
//
//  Created by Mahmoud Hamdy on 22/03/2022.
//

#import <Foundation/Foundation.h>
#import "RCTzoom.h"
#import "ZoomManager.h"
#import <MobileRTC/MobileRTC.h>

@implementation RCTzoom
{
  BOOL isInitialized;
}
- (instancetype)init {
  if (self = [super init]) {
    isInitialized = NO;
  }
  return self;
}

// this macro will export this class to React Native as zoom - RCT prefix is removed!
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(isInitialized: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  @try {
    // todo check from ZoomSdk
    resolve(@(isInitialized));
  } @catch (NSError *ex) {
    reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing isInitialized", ex);
  }
}

//let's init Zoom SDK
RCT_EXPORT_METHOD(initZoom:(NSString *)publicKey
                  privateKey:(NSString *)privateKey
                  domain:(NSString *)domain
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  NSLog(@"Submitted init  request with %@ at %@, %@", publicKey, privateKey, domain);
  
  MobileRTCSDKInitContext *context = [[MobileRTCSDKInitContext alloc] init];
  context.domain = domain;
  context.enableLog = YES;
  context.locale = MobileRTC_ZoomLocale_Default;

  BOOL initializeSuc = [[MobileRTC sharedRTC] initialize:context];
  NSLog(@"initializeContextSuccessful======>%@",@(initializeSuc));
  NSLog(@"MobileRTC Version: %@", [[MobileRTC sharedRTC] mobileRTCVersion]);

  //2nd.step
  MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
  
  if (authService == nil) {
    reject(@"ZOOM_SDK", @"No auth service", nil);
  }
      // we need to implement calback - similar to listener in Android
      authService.delegate = self;
      authService.clientKey = publicKey;
      authService.clientSecret = privateKey;

  @try {
    [authService sdkAuth];
  } @catch (NSError *ex) {
    reject(@"ZOOM_SDK", @"Failed to initialize", ex);
  }
  
  RCTLogInfo(@"ZOOM SDK submitted login request succesfull");
  // NOW WHAT? // so, let'store our promise for later
  self.initializePromiseResolve = resolve;
  self.initializePromiseReject = reject;
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
  
  // new naming standards ? Error__Success ???
  if(returnValue == MobileRTCMeetError_Success){
    NSLog(@"SDK LOG - Auth was initialized succesfully");
    NSDictionary *resultDict;
    resultDict  =  @{@"initialized": @"true"};
    self.initializePromiseResolve(resultDict);
  } else {
    NSLog(@"SDK LOG - Auth was initialized with error");
    self.initializePromiseReject(@"ZOOM_SDK", @"Auth Call Returned Error", nil);
  }
  //VOILA - ZOOM is initialized
}













//--------------------------------LOGIN-END

// START-MEETING
  
RCT_EXPORT_METHOD(startMeeting:(NSString *)meetingNumber
                  withUsername:(NSString *)username
                  withUserId:(NSString *)userId
                  withJwtAccessToken:(NSString *)jwtAccessToken
                  withJwtApiKey:(NSString *) jwtApiKey
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  NSLog(@"Start meeting request with %@ at %@, %@", username, userId, meetingNumber);
  MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        ms.delegate = self;

      NSString * ZAK = [[ZoomManager sharedInstance] requestZAK:userId withJwtAccessToken:jwtAccessToken withJwtApiKey:jwtApiKey];

      MobileRTCMeetingStartParam4WithoutLoginUser * params = [[[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init] autorelease];
      params.userType = MobileRTCUserType_APIUser;
      params.meetingNumber = meetingNumber;
      params.userName = username;
      params.userID = userId; // mail
      params.isAppShare = false;
      params.zak = ZAK;

      MobileRTCMeetError ret = [ms startMeetingWithStartParam:params];
      NSLog(@"onMeetNow ret:%lu",ret);
      return;
    }
}


























RCT_EXPORT_METHOD(
                  joinMeeting: (NSString *)displayName
                  withMeetingNo: (NSString *)meetingNo
                  withPassword: (NSString *)password
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    NSLog(@"Connecting to the meeting %@, %@, %@", displayName, meetingNo, password);
    if (![meetingNo length]){
        NSLog(@"No meeting number, returning without any action");
        return;
    }

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {

      NSLog(@"Joining meeting with %@, %@", displayName, meetingNo);
      ms.delegate = self;

      MobileRTCMeetingJoinParam * joinParam = [[[MobileRTCMeetingJoinParam alloc]init]autorelease];
      joinParam.userName = displayName;
      joinParam.meetingNumber = meetingNo;
      joinParam.password = password != nil ? password : @"";

      MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithJoinParam:joinParam];
      NSLog(@"onJoinaMeeting ret:%lu", joinMeetingResult);
    } else {
      NSLog(@"No meeting service present");
    }
  } @catch (NSError *ex) {
      NSLog(@"Exception");
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
  }
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state;
{
    NSLog(@"onMeetingStateChange:%lu", state);
}

- (void)onMeetingError:(MobileRTCMeetError)error message:(NSString *)message {
    switch (error) {
        case MobileRTCMeetError_PasswordError:
            NSLog(@"Could not join or start meeting because the meeting password was incorrect.");
        default:
            NSLog(@"Could not join or start meeting with MobileRTCMeetError: %lu %@", error, message);
    }
}


- (void)onJoinMeetingConfirmed {
    NSLog(@"Join meeting confirmed.");
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

