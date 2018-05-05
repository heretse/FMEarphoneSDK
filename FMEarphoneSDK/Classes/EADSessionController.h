/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Provides an interface for communication with an EASession. Also the delegate for the EASession input and output stream objects.
 */

@import Foundation;
@import ExternalAccessory;

extern NSString *EADSessionDataReceivedNotification;

//写入数据操作返回结果代理
@protocol EADSessionDelegate <NSObject>

@required

- (void)sessionOpenCompleted;
- (void)sessionDataReceived:(NSData *)data;
- (void)sessionForceClosed;

@end

// NOTE: EADSessionController is not threadsafe, calling methods from different threads will lead to unpredictable results
@interface EADSessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate>

+ (EADSessionController *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property (nonatomic, assign) id <EADSessionDelegate> delegate;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end
