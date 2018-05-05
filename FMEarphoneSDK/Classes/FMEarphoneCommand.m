//
//  FMEarphoneCommand.m
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 14/11/2017.
//

#import "FMEarphoneCommand.h"

@implementation FMEarphoneCommand
    
- (NSString *)description {
    return [NSString stringWithFormat: @"Command Type: %ld", _commandType];
}

@end
