//
//  FMEarphoneStatus.h
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 17/11/2017.
//

#import <Foundation/Foundation.h>

@interface FMEarphoneStatus : NSObject

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) int  currentFrequency;
@property (nonatomic) BOOL isEQEnabled;
@property (nonatomic) BOOL isSoundEffectEnabled;
    
- (void)reset;
    
@end
