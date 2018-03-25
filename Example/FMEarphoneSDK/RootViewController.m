//
//  RootViewController.m
//  FMEarphoneSDK
//
//  Created by winston_hsieh@gemteks.com on 11/08/2017.
//  Copyright (c) 2017 heretse@gmail.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"

#import "FMEarphoneSDK.h"

@interface RootViewController () {
    FMEarphoneSDK *fmEarphoneSDK;
    AVAudioPlayer *audioPlayer;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    fmEarphoneSDK = [[FMEarphoneSDK alloc] init];
    
    [fmEarphoneSDK setDefaultFrequency:10490];
    
    NSError *error = nil;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Silence01min" withExtension:@"mp3"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    if (error == nil) {
        [audioPlayer setNumberOfLoops:-1];
    } else {
        NSLog(@"Error: %@", [error description]);
    }
    
    // watch for the accessory being disconnected
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fmStatusChanged:) name:kFMEarphoneChangedNotification object:nil];
    
    // watch for received data from the accessory
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDataReceived:) name:EADSessionDataReceivedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
    
    [fmEarphoneSDK terminate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Interpret a UITextField's string at a sequence of hex bytes and send those bytes to the accessory
- (IBAction)btnPowerOnPressed:(id)sender;
{
    [fmEarphoneSDK powerOn];
}

- (IBAction)btnPowerOffPressed:(id)sender {
    [fmEarphoneSDK powerOff];
}

- (IBAction)btnSeekUpPressed:(id)sender {
    [fmEarphoneSDK seekUp];
}

- (IBAction)btnSeekDownPressed:(id)sender {
    [fmEarphoneSDK seekDown];
}

- (void)accessoryDidConnect:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Earphone connected" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"OK");
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)accessoryDidDisconnect:(NSNotification *)notification
{
//    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
//    if ([disconnectedAccessory connectionID] == [fmEarphoneSDK.selectedAccessory connectionID])
    dispatch_async(dispatch_get_main_queue(), ^{
        [_receivedBytesTextView setText:@""];
        _totalBytesRead = 0;
        [_receivedBytesCountLabel setText:[NSString stringWithFormat:@"Bytes Received from Session: %u", (unsigned int)_totalBytesRead]];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Earphone disconnected" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"OK");
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

// Data was received from the accessory, real apps should do something with this data but currently:
//    1. bytes counter is incremented
//    2. bytes are read from the session controller and thrown away
- (void)sessionDataReceived:(NSNotification *)notification
{
    EADSessionController *sessionController = (EADSessionController *)[notification object];
    uint32_t bytesAvailable = 0;
    
    while ((bytesAvailable = (uint32_t)[sessionController readBytesAvailable]) > 0) {
        NSData *data = [sessionController readData:bytesAvailable];
        if (data) {
            
            _totalBytesRead = _totalBytesRead + bytesAvailable;
        }
        
        [_receivedBytesTextView setText:[NSString stringWithFormat:@"%@", data]];
    }
    
    [_receivedBytesCountLabel setText:[NSString stringWithFormat:@"Bytes Received from Session: %u", (unsigned int)_totalBytesRead]];
    
}

- (void)fmStatusChanged:(NSNotification *)notification {
    
    if ([fmEarphoneSDK getIsPoweredOn]) {
        NSString *channleStr = [NSString stringWithFormat:@"%d", [fmEarphoneSDK getCurrentFrequency]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.powerUpButton setEnabled:NO];
            [self.powerDownButton setEnabled:YES];
            [self.seekForwardButton setEnabled:YES];
            [self.seekBackwardButton setEnabled:YES];
            
            if ([channleStr length] <= 4) {
                [self.channelLabel setText:[NSString stringWithFormat:@"%@.%@", [channleStr substringWithRange:NSMakeRange(0, 2)], [channleStr substringWithRange:NSMakeRange(2, [channleStr length] - 2)]]];
            } else {
                [self.channelLabel setText:[NSString stringWithFormat:@"%@.%@", [channleStr substringWithRange:NSMakeRange(0, 3)], [channleStr substringWithRange:NSMakeRange(3, [channleStr length] - 3)]]];
            }
        });
        
        [audioPlayer play];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.powerUpButton setEnabled:YES];
            [self.powerDownButton setEnabled:NO];
            [self.seekForwardButton setEnabled:NO];
            [self.seekBackwardButton setEnabled:NO];
            [self.channelLabel setText:@""];
        });
        
        [audioPlayer pause];
    }
}

@end
