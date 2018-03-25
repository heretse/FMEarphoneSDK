//
//  FMEarphoneCommand.h
//  Pods
//
//  Created by Winston Hsieh on 18/01/2018.
//
#import "FMEarphoneCommandDefines.h"

@interface FMEarphoneCommand : NSObject

@property(retain, nonatomic) NSArray *bufferDataArray;
@property(nonatomic) CommandType commandType;

@end
