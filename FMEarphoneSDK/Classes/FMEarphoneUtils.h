//
//  FMEarphoneCommand.h
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 14/11/2017.
//

#import <Foundation/Foundation.h>

#import "EADSessionController.h"
#import "EqCalculate.h"
#import "FMEarphoneStatus.h"

extern NSString *kFMEarphoneStatusChangedNotification;

@interface FMEarphoneUtils : NSObject <EADSessionDelegate>

- (id)initWithEADSessionController:(EADSessionController *)eadSessionController andEarphoneStatus:(FMEarphoneStatus *)status;

- (void)getDeviceInfo;

#pragma mark - FM related commands
- (void)doDinControlHigh;
- (void)doDinControlLow;
- (void)setFMSeekStart:(Byte)seekUp wrap:(Byte)wrap;
- (void)setFMTuneFreq:(UTF16Char)frequency byUsingCommand:(BOOL)usingCommand;

#pragma mark - EQ related commands
- (void)getEQStatus;
- (void)setEQEnable:(BOOL)enable;
- (void)setSceneByType:(SceneType)sceneType;

#pragma mark - Sound Effect related commands
- (void)getSoundEffectStatus;

@end
