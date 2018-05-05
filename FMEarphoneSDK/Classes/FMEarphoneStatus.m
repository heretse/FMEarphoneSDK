//
//  FMEarphoneStatus.m
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 17/11/2017.
//

#import "FMEarphoneStatus.h"

@implementation FMEarphoneStatus

- (instancetype)init {
    if (self = [super init]) {
        _isPlaying = NO;
        _isEQEnabled = NO;
        _isSoundEffectEnabled = NO;
    }
    
    return self;
}

- (void)reset {
    _isPlaying = NO;
    _isEQEnabled = NO;
    _isSoundEffectEnabled = NO;
}

@end
