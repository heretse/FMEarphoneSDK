//
//  FMEarphoneSDK.m
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 08/11/2017.
//

#import "FMEarphoneSDK.h"

#define FM_EARPHONE_EAP @"com.blackloud.sound"

@implementation FMEarphoneSDK {
    FMEarphoneUtils *efUtils;
    FMEarphoneStatus *currentStatus;
    int defaultFrequency;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        
        defaultFrequency = 7600;
        
        currentStatus = [[FMEarphoneStatus alloc] init];
        [currentStatus setCurrentFrequency:defaultFrequency];
        
        _eaSessionController = [EADSessionController sharedController];
        efUtils = [[FMEarphoneUtils alloc] initWithEADSessionController:_eaSessionController andEarphoneStatus:currentStatus];
        
        for (EAAccessory *connectedAccessory in [[EAAccessoryManager sharedAccessoryManager] connectedAccessories]) {
            if ([[connectedAccessory protocolStrings] containsObject:FM_EARPHONE_EAP]) {
                _selectedAccessory = connectedAccessory;
                
                [_eaSessionController setupControllerForAccessory:_selectedAccessory
                                               withProtocolString:FM_EARPHONE_EAP];
                [_eaSessionController openSession];
            }
        }
        
    }
    
    return self;
}

- (void)terminate {
    if (_selectedAccessory != nil) {
        _selectedAccessory = nil;
    }
    
    if (_eaSessionController != nil) {
        [_eaSessionController closeSession];
    }
}

#pragma mark - Internal EAAccessory Notification

- (void)accessoryDidConnect:(NSNotification *)notification {
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    if ([[connectedAccessory protocolStrings] containsObject:FM_EARPHONE_EAP]) {
        _selectedAccessory = connectedAccessory;
        
        [_eaSessionController setupControllerForAccessory:_selectedAccessory
                                      withProtocolString:FM_EARPHONE_EAP];
        [_eaSessionController openSession];
    }
}

- (void)accessoryDidDisconnect:(NSNotification *)notification {
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    if ([disconnectedAccessory connectionID] == [_selectedAccessory connectionID]){
        [self terminate];
    }
}

#pragma mark - External Earphone Command

- (BOOL)isHeadsetPluggedIn {
    if (_selectedAccessory != nil)
        return true;
    
    return false;
}

- (BOOL)getIsPoweredOn {
    if (_selectedAccessory != nil) {
        return [currentStatus isPlaying];
    }
    
    return false;
}

- (int)getCurrentFrequency {
    if (_selectedAccessory != nil && [currentStatus isPlaying]) {
        return [currentStatus currentFrequency];
    }
    
    return 0;
}

- (void)powerOn {
    if (_selectedAccessory != nil && ![currentStatus isPlaying]) {
        [efUtils doDinControlHigh];
    }
}

- (void)powerOff {
    if (_selectedAccessory != nil && [currentStatus isPlaying]) {
        [efUtils doDinControlLow];
    }
}

- (void)seekUp {
    if (_selectedAccessory != nil && [currentStatus isPlaying]) {
        [efUtils setFMSeekStart:0x01 wrap:0x01];
    }
}

- (void)seekDown {
    if (_selectedAccessory != nil && [currentStatus isPlaying]) {
        [efUtils setFMSeekStart:0x00 wrap:0x01];
    }
}

- (void)setDefaultFrequency:(int)frequency {
    defaultFrequency = frequency;
}

- (void)setFrequency:(int)frequency {
    if (_selectedAccessory != nil) {
        [efUtils setFMTuneFreq:(UTF16Char)frequency byUsingCommand:YES];
    }
}

- (void)getDeviceInfo {
    if (_selectedAccessory != nil) {
        [efUtils getDeviceInfo];
    }
}

@end
