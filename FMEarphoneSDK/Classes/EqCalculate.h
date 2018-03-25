//
//  EqCalculate.h
//  Earphone
//
//  Created by heya on 17/4/6.
//  Copyright © 2017年 bpyc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMEarphoneCommandDefines.h"

struct BiQuadCoeffs {
    double A0;
    double A1;
    double A2;
    double B0;
    double B1;
    double B2;
};

struct BiQuadCoeffsInt {
    int A1;
    int A2;
    int B0;
    int B1;
    int B2;
};

typedef enum {
    EQ_CHANNEL_0,
    EQ_CHANNEL_1,
} EQ_CHANNEL_ID;

@interface EqCalculate : NSObject

+ (struct BiQuadCoeffsInt)calculateEQ:(double)fGain
                            frequency:(double)fFreq;

+ (Byte)getStartAddressByBand:(NSInteger)band
                   AndChannel:(EQ_CHANNEL_ID)channel;

+ (NSMutableArray *)getCommandData:(double)fGain
                          withBand:(NSInteger)band;

+ (NSMutableArray *)getGainByBySceneType:(SceneType)sceneType;

+ (NSMutableArray *)getDACData;

+ (NSMutableArray *)getDSPData;

+ (NSMutableArray *)getLimitData;

@end
