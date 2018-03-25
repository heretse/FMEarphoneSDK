//
//  FMEarphoneSDK.h
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 08/11/2017.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

#import "EADSessionController.h"
#import "FMEarphoneUtils.h"
#import "FMEarphoneStatus.h"

@interface FMEarphoneSDK : NSObject

@property (nonatomic, strong) EAAccessory *selectedAccessory;
@property (nonatomic, strong) EADSessionController *eaSessionController;

- (void)terminate;
- (void)accessoryDidConnect:(NSNotification *)notification;
- (void)accessoryDidDisconnect:(NSNotification *)notification;

#pragma mark - External Earphone Command

- (BOOL)isHeadsetPluggedIn;
- (BOOL)getIsPoweredOn;
- (int)getCurrentFrequency;

- (void)powerOn;
- (void)powerOff;
- (void)seekUp;
- (void)seekDown;
- (void)setDefaultFrequency:(int)frequency;
- (void)setFrequency:(int)frequency;

- (void)getDeviceInfo;

@end
