//
//  EqCalculate.m
//  Earphone
//
//  Created by heya on 17/4/6.
//  Copyright © 2017年 bpyc. All rights reserved.
//

#import "EqCalculate.h"


@implementation EqCalculate

typedef enum {
    EQ_BAND_1 = 0,
    EQ_BAND_2 = 1,
    EQ_BAND_3 = 2,
    EQ_BAND_4 = 3,
    EQ_BAND_5 = 4,
    EQ_BAND_6 = 5,
} EQ_BAND_ID;

+ (struct BiQuadCoeffs)CalcCoeffs:(double)fGain
                        frequency:(double)fFreq {

    struct BiQuadCoeffs ret;

    double A;
    double omega;
    double sn;
    double cs;
    double alpha;
    
    // truncate to the nearest 100th
    fGain = (fGain * 100.0) / 100.0;
    fFreq = (fFreq * 100.0) / 100.0;
    A = pow(10.0, (fGain / 40.0));
    omega = 2 * M_PI * fFreq / 48000;
    sn = sin(omega);
    cs = cos(omega);

    alpha = sn * sinh((log(2.0) / 2.0) * 1.0 * (omega / sn));

    ret.B0 = 1.0 + alpha * A;
    ret.B1 = -2.0 * cs;
    ret.B2 = 1.0 - alpha * A;
    ret.A0 = 1.0 + alpha / A;
    ret.A1 = -2.0 * cs;
    ret.A2 = 1.0 - alpha / A;

    // Now normalize by A0
    ret = [self ClipBand:ret];;

    return ret;

}

+ (struct BiQuadCoeffs)ClipBand:(struct BiQuadCoeffs)curVal {
    double theA0 = curVal.A0;
    struct BiQuadCoeffs ret = curVal;
    ret.B0 = curVal.B0 / theA0;
    ret.B1 = curVal.B1 / theA0;
    ret.B2 = curVal.B2 / theA0;
    ret.A0 = curVal.A0 / theA0;
    ret.A1 = curVal.A1 / theA0;
    ret.A2 = curVal.A2 / theA0;
    return ret;
}

+ (struct BiQuadCoeffsInt)calculateEQ:(double)fGain
                            frequency:(double)fFreq {

    struct BiQuadCoeffs coeffs = [self CalcCoeffs:fGain frequency:fFreq];
    struct BiQuadCoeffsInt coeffsInt;
    double mult = pow(2, 22);
    coeffsInt.B0 = (int) floor(coeffs.B0 * mult);
    coeffsInt.B1 = (int) floor(coeffs.B1 * mult);
    coeffsInt.B2 = (int) floor(coeffs.B2 * mult);
    coeffsInt.A1 = (int) (-1.0 * floor(coeffs.A1 * mult));
    coeffsInt.A2 = (int) (-1.0 * floor(coeffs.A2 * mult));
    return coeffsInt;
}

+ (Byte)getStartAddressByBand:(NSInteger)band
                   AndChannel:(EQ_CHANNEL_ID)channel {

    Byte address = '\0';

    switch (band) {
        case 0: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x00;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x20;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 1: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x05;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x25;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 2: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x0A;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x2A;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 3: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x0F;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x2F;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 4: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x14;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x34;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 5: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x19;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x39;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 6: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x40;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x60;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 7: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x45;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x65;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 8: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x4A;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x6A;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 9: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x4F;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x6F;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 10: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x54;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x74;
                }
                    break;
                default:
                    break;
            }

        }
            break;
            
        case 11: {
            switch (channel) {
                case EQ_CHANNEL_0: {
                    address = 0x59;
                }
                    break;
                case EQ_CHANNEL_1: {
                    address = 0x79;
                }
                    break;
                default:
                    break;
            }

        }
            break;

        default:
            break;
    }


    return address;
}

+ (NSMutableArray *)getCommandData:(double)fGain
                          withBand:(NSInteger)band {

    NSMutableArray *dataArray = [NSMutableArray new];

    double fFreq = 0.0;
    switch (band) {
        case EQ_BAND_1: {
            fFreq = BAND0_FREQ;
        }
            break;
        case EQ_BAND_2: {
            fFreq = BAND1_FREQ;
        }
            break;
        case EQ_BAND_3: {
            fFreq = BAND2_FREQ;
        }
            break;
        case EQ_BAND_4: {
            fFreq = BAND3_FREQ;
        }
            break;
        case EQ_BAND_5: {
            fFreq = BAND4_FREQ;
        }
            break;
        case EQ_BAND_6: {
            fFreq = BAND5_FREQ;
        }
            break;

        default:
            break;
    }

    NSLog(@"eq - getCommandData gain=%f,freq=%f", fGain, fFreq);
    struct BiQuadCoeffsInt coeffsInt = [EqCalculate calculateEQ:fGain frequency:fFreq];
    NSLog(@"eq - coeffsInt B0=%zi,B1=%zi,B2=%zi,A1=%zi,A2=%zi", coeffsInt.B0, coeffsInt.B1, coeffsInt.B2, coeffsInt.A1, coeffsInt.A2);

    Byte channel0 = [EqCalculate getStartAddressByBand:band AndChannel:EQ_CHANNEL_0];
    Byte channel1 = [EqCalculate getStartAddressByBand:band AndChannel:EQ_CHANNEL_1];
    Byte channel0Bytes[5], channel1Bytes[5];
    // 0xCD, 0xDC, 0x40(表示发送地址), 0x01（长度）, 0x05（地址）

    channel0Bytes[0] = channel1Bytes[0] = 0xcd;
    channel0Bytes[1] = channel1Bytes[1] = 0xdc;
    channel0Bytes[2] = channel1Bytes[2] = 0x40;
    channel0Bytes[3] = channel1Bytes[3] = 0x01;
    channel0Bytes[4] = channel0;
    channel1Bytes[4] = channel1;

    // 0xCD, 0xDC, 0x39（表示发送DSB）, 0x03, B0-low, B0-mid, B0-high
    Byte bytesBO[7], bytesB1[7], bytesB2[7], bytesA1[7], bytesA2[7];
    //B0
    Byte B0Low, B0Mid, B0Hi;
    B0Low = (Byte) (coeffsInt.B0 & 0xff);
    B0Mid = (Byte) ((coeffsInt.B0 >> 8) & 0xff);
    B0Hi = (Byte) ((coeffsInt.B0 >> 16) & 0xff);
    bytesBO[0] = 0xcd;
    bytesBO[1] = 0xdc;
    bytesBO[2] = 0x3a;
    bytesBO[3] = 0x03;
    bytesBO[4] = B0Low;
    bytesBO[5] = B0Mid;
    bytesBO[6] = B0Hi;
    //B1
    Byte B1Low, B1Mid, B1Hi;
    B1Low = (Byte) (coeffsInt.B1 & 0xff);
    B1Mid = (Byte) ((coeffsInt.B1 >> 8) & 0xff);
    B1Hi = (Byte) ((coeffsInt.B1 >> 16) & 0xff);
    bytesB1[0] = 0xcd;
    bytesB1[1] = 0xdc;
    bytesB1[2] = 0x3a;
    bytesB1[3] = 0x03;
    bytesB1[4] = B1Low;
    bytesB1[5] = B1Mid;
    bytesB1[6] = B1Hi;
    //B2
    Byte B2Low, B2Mid, B2Hi;
    B2Low = (Byte) (coeffsInt.B2 & 0xff);
    B2Mid = (Byte) ((coeffsInt.B2 >> 8) & 0xff);
    B2Hi = (Byte) ((coeffsInt.B2 >> 16) & 0xff);
    bytesB2[0] = 0xcd;
    bytesB2[1] = 0xdc;
    bytesB2[2] = 0x3a;
    bytesB2[3] = 0x03;
    bytesB2[4] = B2Low;
    bytesB2[5] = B2Mid;
    bytesB2[6] = B2Hi;
    //A1
    Byte A1Low, A1Mid, A1Hi;
    A1Low = (Byte) (coeffsInt.A1 & 0xff);
    A1Mid = (Byte) ((coeffsInt.A1 >> 8) & 0xff);
    A1Hi = (Byte) ((coeffsInt.A1 >> 16) & 0xff);
    bytesA1[0] = 0xcd;
    bytesA1[1] = 0xdc;
    bytesA1[2] = 0x3a;
    bytesA1[3] = 0x03;
    bytesA1[4] = A1Low;
    bytesA1[5] = A1Mid;
    bytesA1[6] = A1Hi;
    //A2
    Byte A2Low, A2Mid, A2Hi;
    A2Low = (Byte) (coeffsInt.A2 & 0xff);
    A2Mid = (Byte) ((coeffsInt.A2 >> 8) & 0xff);
    A2Hi = (Byte) ((coeffsInt.A2 >> 16) & 0xff);
    bytesA2[0] = 0xcd;
    bytesA2[1] = 0xdc;
    bytesA2[2] = 0x3a;
    bytesA2[3] = 0x03;
    bytesA2[4] = A2Low;
    bytesA2[5] = A2Mid;
    bytesA2[6] = A2Hi;


    NSMutableData *channel0Data = [NSMutableData dataWithBytes:channel0Bytes length:5];
    NSMutableData *channel1Data = [NSMutableData dataWithBytes:channel1Bytes length:5];
    NSMutableData *b0Data = [NSMutableData dataWithBytes:bytesBO length:7];
    NSMutableData *b1Data = [NSMutableData dataWithBytes:bytesB1 length:7];
    NSMutableData *b2Data = [NSMutableData dataWithBytes:bytesB2 length:7];
    NSMutableData *a1Data = [NSMutableData dataWithBytes:bytesA1 length:7];
    NSMutableData *a2Data = [NSMutableData dataWithBytes:bytesA2 length:7];


    [dataArray addObject:channel0Data];
    [dataArray addObject:b0Data];
    [dataArray addObject:b1Data];
    [dataArray addObject:b2Data];
    [dataArray addObject:a1Data];
    [dataArray addObject:a2Data];
    [dataArray addObject:channel1Data];
    [dataArray addObject:b0Data];
    [dataArray addObject:b1Data];
    [dataArray addObject:b2Data];
    [dataArray addObject:a1Data];
    [dataArray addObject:a2Data];

    return dataArray;
}

+ (NSMutableArray *)getGainByBySceneType:(SceneType)sceneType {

    NSMutableArray *gainArrays = [NSMutableArray new];

    double gain0;
    double gain1;
    double gain2;
    double gain3;
    double gain4;
    double gain5;

    switch (sceneType) {
        case SceneTypeNone: {
            gain0 = 0;
            gain1 = 0;
            gain2 = 0;
            gain3 = 0;
            gain4 = 0;
            gain5 = 0;

        }

            break;
        case SceneTypeClassical: {
            gain0 = 5;
            gain1 = 3;
            gain2 = 3;
            gain3 = -2;
            gain4 = 4;
            gain5 = 4;
        }

            break;
        case SceneTypePop: {
            gain0 = -1;
            gain1 = 2;
            gain2 = 2;
            gain3 = 5;
            gain4 = 1;
            gain5 = -2;
        }

            break;
        case SceneTypeDance: {
            gain0 = 6;
            gain1 = 0;
            gain2 = 0;
            gain3 = 2;
            gain4 = 4;
            gain5 = 1;
        }

            break;
        case SceneTypeJazz: {
            gain0 = 4;
            gain1 = 2;
            gain2 = 2;
            gain3 = -2;
            gain4 = 2;
            gain5 = 5;
        }

            break;
        case SceneTypeMetal: {
            gain0 = 4;
            gain1 = 1;
            gain2 = 1;
            gain3 = 9;
            gain4 = 3;
            gain5 = 0;
        }

            break;
        case SceneTypeLatin: {
            gain0 = 5;
            gain1 = 0.5;
            gain2 = 0.5;
            gain3 = 0;
            gain4 = 0.5;
            gain5 = 5;
        }

            break;
        case SceneTypeRock: {
            gain0 = 5;
            gain1 = 3;
            gain2 = 3;
            gain3 = -1;
            gain4 = 3;
            gain5 = 5;
        }

            break;
        case SceneTypeElectronic: {
            gain0 = 5;
            gain1 = 0.5;
            gain2 = 0.5;
            gain3 = 3.5;
            gain4 = 0;
            gain5 = -5;
        }

            break;
        case SceneTypeRB: {
            gain0 = 3;
            gain1 = 2;
            gain2 = 2;
            gain3 = 2.5;
            gain4 = 4.5;
            gain5 = 4.5;
        }

            break;
        case SceneTypeAcoustic: {
            gain0 = 5;
            gain1 = 3;
            gain2 = 3;
            gain3 = 2;
            gain4 = 4;
            gain5 = 4;
        }

            break;
        case SceneTypePiano: {
            gain0 = -3;
            gain1 = 0;
            gain2 = 0;
            gain3 = 3;
            gain4 = -1;
            gain5 = 1;
        }

            break;

        default:
            break;
    }

    [gainArrays addObject:[NSNumber numberWithDouble:gain0]];
    [gainArrays addObject:[NSNumber numberWithDouble:gain1]];
    [gainArrays addObject:[NSNumber numberWithDouble:gain2]];
    [gainArrays addObject:[NSNumber numberWithDouble:gain3]];
    [gainArrays addObject:[NSNumber numberWithDouble:gain4]];
    [gainArrays addObject:[NSNumber numberWithDouble:gain5]];

    return gainArrays;
}

+ (NSMutableArray *)getDACData {

    Byte byte0[9], byte1[9], byte2[9], byte3[9], byte4[6];
    byte0[0] = byte1[0] = byte2[0] = byte3[0] = byte4[0] = 0xcd;
    byte0[1] = byte1[1] = byte2[1] = byte3[1] = byte4[1] = 0xdc;
    byte0[2] = 0xc8;
    byte0[3] = 0x05;
    byte0[4] = 0x2a;
    byte0[5] = 0x02;
    byte0[6] = 0xca;
    byte0[7] = 0x04;
    byte0[8] = 0x36;

    byte1[2] = 0xcd;
    byte1[3] = 0x05;
    byte1[4] = 0xff;
    byte1[5] = 0x36;
    byte1[6] = 0xff;
    byte1[7] = 0x02;
    byte1[8] = 0xca;

    byte2[2] = 0xd2;
    byte2[3] = 0x05;
    byte2[4] = 0x04;
    byte2[5] = 0x36;
    byte2[6] = 0xff;
    byte2[7] = 0x36;
    byte2[8] = 0xff;

    byte3[2] = 0xd7;
    byte3[3] = 0x05;
    byte3[4] = 0x02;
    byte3[5] = 0xca;
    byte3[6] = 0x04;
    byte3[7] = 0x36;
    byte3[8] = 0xff;

    byte4[2] = 0xdc;
    byte4[3] = 0x02;
    byte4[4] = 0x36;
    byte4[5] = 0xff;

    NSMutableData *data0 = [NSMutableData dataWithBytes:byte0 length:9];
    NSMutableData *data1 = [NSMutableData dataWithBytes:byte1 length:9];
    NSMutableData *data2 = [NSMutableData dataWithBytes:byte2 length:9];
    NSMutableData *data3 = [NSMutableData dataWithBytes:byte3 length:9];
    NSMutableData *data4 = [NSMutableData dataWithBytes:byte4 length:6];

    NSMutableArray *dataArray = [NSMutableArray new];
    [dataArray addObject:data0];
    [dataArray addObject:data1];
    [dataArray addObject:data2];
    [dataArray addObject:data3];
    [dataArray addObject:data4];

    return dataArray;
}


+ (NSMutableArray *)getDSPData {

    Byte address0[5];
    address0[0] = 0xcd;
    address0[1] = 0xdc;
    address0[2] = 0x40;
    address0[3] = 0x01;
    address0[4] = 0xb0;
    Byte byte0[7];
    byte0[0] = 0xcd;
    byte0[1] = 0xdc;
    byte0[2] = 0x3a;
    byte0[3] = 0x03;
    byte0[4] = 0x3a;
    byte0[5] = 0x06;
    byte0[6] = 0x00;
    NSMutableData *sdData0 = [NSMutableData dataWithBytes:address0 length:5];
    NSMutableData *data0 = [NSMutableData dataWithBytes:byte0 length:7];

    Byte address1[5];
    address1[0] = 0xcd;
    address1[1] = 0xdc;
    address1[2] = 0x40;
    address1[3] = 0x01;
    address1[4] = 0xb1;
    Byte byte1[7];
    byte1[0] = 0xcd;
    byte1[1] = 0xdc;
    byte1[2] = 0x3a;
    byte1[3] = 0x03;
    byte1[6] = 0x00;
    byte1[5] = 0x0c;
    byte1[4] = 0x75;
    NSMutableData *sdData1 = [NSMutableData dataWithBytes:address1 length:5];
    NSMutableData *data1 = [NSMutableData dataWithBytes:byte1 length:7];


    Byte address2[5];
    address2[0] = 0xcd;
    address2[1] = 0xdc;
    address2[2] = 0x40;
    address2[3] = 0x01;
    address2[4] = 0xb2;
    Byte byte2[7];
    byte2[0] = 0xcd;
    byte2[1] = 0xdc;
    byte2[2] = 0x3a;
    byte2[3] = 0x03;
    byte2[6] = 0x00;
    byte2[5] = 0x06;
    byte2[4] = 0x3a;
    NSMutableData *sdData2 = [NSMutableData dataWithBytes:address2 length:5];
    NSMutableData *data2 = [NSMutableData dataWithBytes:byte2 length:7];


    Byte address3[5];
    address3[0] = 0xcd;
    address3[1] = 0xdc;
    address3[2] = 0x40;
    address3[3] = 0x01;
    address3[4] = 0xb3;
    Byte byte3[7];
    byte3[0] = 0xcd;
    byte3[1] = 0xdc;
    byte3[2] = 0x3a;
    byte3[3] = 0x03;
    byte3[6] = 0x7e;
    byte3[5] = 0x26;
    byte3[4] = 0x5c;
    NSMutableData *sdData3 = [NSMutableData dataWithBytes:address3 length:5];
    NSMutableData *data3 = [NSMutableData dataWithBytes:byte3 length:7];

    Byte address4[5];
    address4[0] = 0xcd;
    address4[1] = 0xdc;
    address4[2] = 0x40;
    address4[3] = 0x01;
    address4[4] = 0xb4;
    Byte byte4[7];
    byte4[0] = 0xcd;
    byte4[1] = 0xdc;
    byte4[2] = 0x3a;
    byte4[3] = 0x03;
    byte4[6] = 0xc1;
    byte4[5] = 0xc0;
    byte4[4] = 0xba;
    NSMutableData *sdData4 = [NSMutableData dataWithBytes:address4 length:5];
    NSMutableData *data4 = [NSMutableData dataWithBytes:byte4 length:7];


    Byte address5[5];
    address5[0] = 0xcd;
    address5[1] = 0xdc;
    address5[2] = 0x40;
    address5[3] = 0x01;
    address5[4] = 0xb5;
    Byte byte5[7];
    byte5[0] = 0xcd;
    byte5[1] = 0xdc;
    byte5[2] = 0x3a;
    byte5[3] = 0x03;
    byte5[6] = 0x00;
    byte5[5] = 0x06;
    byte5[4] = 0x3a;
    NSMutableData *sdData5 = [NSMutableData dataWithBytes:address5 length:5];
    NSMutableData *data5 = [NSMutableData dataWithBytes:byte5 length:7];


    Byte address6[5];
    address6[0] = 0xcd;
    address6[1] = 0xdc;
    address6[2] = 0x40;
    address6[3] = 0x01;
    address6[4] = 0xb6;
    Byte byte6[7];
    byte6[0] = 0xcd;
    byte6[1] = 0xdc;
    byte6[2] = 0x3a;
    byte6[3] = 0x03;
    byte6[6] = 0x00;
    byte6[5] = 0x0c;
    byte6[4] = 0x75;
    NSMutableData *sdData6 = [NSMutableData dataWithBytes:address6 length:5];
    NSMutableData *data6 = [NSMutableData dataWithBytes:byte6 length:7];


    Byte address7[5];
    address7[0] = 0xcd;
    address7[1] = 0xdc;
    address7[2] = 0x40;
    address7[3] = 0x01;
    address7[4] = 0xb7;
    Byte byte7[7];
    byte7[0] = 0xcd;
    byte7[1] = 0xdc;
    byte7[2] = 0x3a;
    byte7[3] = 0x03;
    byte7[6] = 0x00;
    byte7[5] = 0x06;
    byte7[4] = 0x3a;
    NSMutableData *sdData7 = [NSMutableData dataWithBytes:address7 length:5];
    NSMutableData *data7 = [NSMutableData dataWithBytes:byte7 length:7];


    Byte address8[5];
    address8[0] = 0xcd;
    address8[1] = 0xdc;
    address8[2] = 0x40;
    address8[3] = 0x01;
    address8[4] = 0xb8;
    Byte byte8[7];
    byte8[0] = 0xcd;
    byte8[1] = 0xdc;
    byte8[2] = 0x3a;
    byte8[3] = 0x03;
    byte8[6] = 0x7e;
    byte8[5] = 0x26;
    byte8[4] = 0x5c;
    NSMutableData *sdData8 = [NSMutableData dataWithBytes:address8 length:5];
    NSMutableData *data8 = [NSMutableData dataWithBytes:byte8 length:7];


    Byte address9[5];
    address9[0] = 0xcd;
    address9[1] = 0xdc;
    address9[2] = 0x40;
    address9[3] = 0x01;
    address9[4] = 0xb9;
    Byte byte9[7];
    byte9[0] = 0xcd;
    byte9[1] = 0xdc;
    byte9[2] = 0x3a;
    byte9[3] = 0x03;
    byte9[6] = 0xc1;
    byte9[5] = 0xc0;
    byte9[4] = 0xba;
    NSMutableData *sdData9 = [NSMutableData dataWithBytes:address9 length:5];
    NSMutableData *data9 = [NSMutableData dataWithBytes:byte9 length:7];


    Byte address10[5];
    address10[0] = 0xcd;
    address10[1] = 0xdc;
    address10[2] = 0x40;
    address10[3] = 0x01;
    address10[4] = 0xba;
    Byte byte10[7];
    byte10[0] = 0xcd;
    byte10[1] = 0xdc;
    byte10[2] = 0x3a;
    byte10[3] = 0x03;
    byte10[6] = 0x3f;
    byte10[5] = 0x19;
    byte10[4] = 0x68;
    NSMutableData *sdData10 = [NSMutableData dataWithBytes:address10 length:5];
    NSMutableData *data10 = [NSMutableData dataWithBytes:byte10 length:7];


    Byte address11[5];
    address11[0] = 0xcd;
    address11[1] = 0xdc;
    address11[2] = 0x40;
    address11[3] = 0x01;
    address11[4] = 0xbb;
    Byte byte11[7];
    byte11[0] = 0xcd;
    byte11[1] = 0xdc;
    byte11[2] = 0x3a;
    byte11[3] = 0x03;
    byte11[6] = 0x81;
    byte11[5] = 0xcd;
    byte11[4] = 0x2f;
    NSMutableData *sdData11 = [NSMutableData dataWithBytes:address11 length:5];
    NSMutableData *data11 = [NSMutableData dataWithBytes:byte11 length:7];


    Byte address12[5];
    address12[0] = 0xcd;
    address12[1] = 0xdc;
    address12[2] = 0x40;
    address12[3] = 0x01;
    address12[4] = 0xbc;
    Byte byte12[7];
    byte12[0] = 0xcd;
    byte12[1] = 0xdc;
    byte12[2] = 0x3a;
    byte12[3] = 0x03;
    byte12[6] = 0x3f;
    byte12[5] = 0x19;
    byte12[4] = 0x68;
    NSMutableData *sdData12 = [NSMutableData dataWithBytes:address12 length:5];
    NSMutableData *data12 = [NSMutableData dataWithBytes:byte12 length:7];

    Byte address13[5];
    address13[0] = 0xcd;
    address13[1] = 0xdc;
    address13[2] = 0x40;
    address13[3] = 0x01;
    address13[4] = 0xbd;
    Byte byte13[7];
    byte13[0] = 0xcd;
    byte13[1] = 0xdc;
    byte13[2] = 0x3a;
    byte13[3] = 0x03;
    byte13[6] = 0x7e;
    byte13[5] = 0x26;
    byte13[4] = 0x5c;
    NSMutableData *sdData13 = [NSMutableData dataWithBytes:address13 length:5];
    NSMutableData *data13 = [NSMutableData dataWithBytes:byte13 length:7];


    Byte address14[5];
    address14[0] = 0xcd;
    address14[1] = 0xdc;
    address14[2] = 0x40;
    address14[3] = 0x01;
    address14[4] = 0xbe;
    Byte byte14[7];
    byte14[0] = 0xcd;
    byte14[1] = 0xdc;
    byte14[2] = 0x3a;
    byte14[3] = 0x03;
    byte14[6] = 0xc1;
    byte14[5] = 0xc0;
    byte14[4] = 0xba;
    NSMutableData *sdData14 = [NSMutableData dataWithBytes:address14 length:5];
    NSMutableData *data14 = [NSMutableData dataWithBytes:byte14 length:7];


    Byte address15[5];
    address15[0] = 0xcd;
    address15[1] = 0xdc;
    address15[2] = 0x40;
    address15[3] = 0x01;
    address15[4] = 0xbf;
    Byte byte15[7];
    byte15[0] = 0xcd;
    byte15[1] = 0xdc;
    byte15[2] = 0x3a;
    byte15[3] = 0x03;
    byte15[6] = 0x00;
    byte15[5] = 0xff;
    byte15[4] = 0x7a;
    NSMutableData *sdData15 = [NSMutableData dataWithBytes:address15 length:5];
    NSMutableData *data15 = [NSMutableData dataWithBytes:byte15 length:7];

    Byte address16[5];
    address16[0] = 0xcd;
    address16[1] = 0xdc;
    address16[2] = 0x40;
    address16[3] = 0x01;
    address16[4] = 0xc0;
    Byte byte16[7];
    byte16[0] = 0xcd;
    byte16[1] = 0xdc;
    byte16[2] = 0x3a;
    byte16[3] = 0x03;
    byte16[6] = 0x01;
    byte16[5] = 0xfe;
    byte16[4] = 0xf4;
    NSMutableData *sdData16 = [NSMutableData dataWithBytes:address16 length:5];
    NSMutableData *data16 = [NSMutableData dataWithBytes:byte16 length:7];


    Byte address17[5];
    address17[0] = 0xcd;
    address17[1] = 0xdc;
    address17[2] = 0x40;
    address17[3] = 0x01;
    address17[4] = 0xc1;
    Byte byte17[7];
    byte17[0] = 0xcd;
    byte17[1] = 0xdc;
    byte17[2] = 0x3a;
    byte17[3] = 0x03;
    byte17[6] = 0x00;
    byte17[5] = 0xff;
    byte17[4] = 0x7a;
    NSMutableData *sdData17 = [NSMutableData dataWithBytes:address17 length:5];
    NSMutableData *data17 = [NSMutableData dataWithBytes:byte17 length:7];


    Byte address18[5];
    address18[0] = 0xcd;
    address18[1] = 0xdc;
    address18[2] = 0x40;
    address18[3] = 0x01;
    address18[4] = 0xc2;
    Byte byte18[7];
    byte18[0] = 0xcd;
    byte18[1] = 0xdc;
    byte18[2] = 0x3a;
    byte18[3] = 0x03;
    byte18[6] = 0x71;
    byte18[5] = 0x28;
    byte18[4] = 0xde;
    NSMutableData *sdData18 = [NSMutableData dataWithBytes:address18 length:5];
    NSMutableData *data18 = [NSMutableData dataWithBytes:byte18 length:7];

    //TODO
    Byte address19[5];
    address19[0] = 0xcd;
    address19[1] = 0xdc;
    address19[2] = 0x40;
    address19[3] = 0x01;
    address19[4] = 0xc3;
    Byte byte19[7];
    byte19[0] = 0xcd;
    byte19[1] = 0xdc;
    byte19[2] = 0x3a;
    byte19[3] = 0x03;
    byte19[6] = 0xca;
    byte19[5] = 0xd9;
    byte19[4] = 0x3a;
    NSMutableData *sdData19 = [NSMutableData dataWithBytes:address19 length:5];
    NSMutableData *data19 = [NSMutableData dataWithBytes:byte19 length:7];

    Byte address20[5];
    address20[0] = 0xcd;
    address20[1] = 0xdc;
    address20[2] = 0x40;
    address20[3] = 0x01;
    address20[4] = 0xc4;
    Byte byte20[7];
    byte20[0] = 0xcd;
    byte20[1] = 0xdc;
    byte20[2] = 0x3a;
    byte20[3] = 0x03;
    byte20[6] = 0x39;
    byte20[5] = 0x93;
    byte20[4] = 0xe8;
    NSMutableData *sdData20 = [NSMutableData dataWithBytes:address20 length:5];
    NSMutableData *data20 = [NSMutableData dataWithBytes:byte20 length:7];


    Byte address21[5];
    address21[0] = 0xcd;
    address21[1] = 0xdc;
    address21[2] = 0x40;
    address21[3] = 0x01;
    address21[4] = 0xc5;
    Byte byte21[7];
    byte21[0] = 0xcd;
    byte21[1] = 0xdc;
    byte21[2] = 0x3a;
    byte21[3] = 0x03;
    byte21[6] = 0x8c;
    byte21[5] = 0xd8;
    byte21[4] = 0x2e;
    NSMutableData *sdData21 = [NSMutableData dataWithBytes:address21 length:5];
    NSMutableData *data21 = [NSMutableData dataWithBytes:byte21 length:7];


    Byte address22[5];
    address22[0] = 0xcd;
    address22[1] = 0xdc;
    address22[2] = 0x40;
    address22[3] = 0x01;
    address22[4] = 0xc6;
    Byte byte22[7];
    byte22[0] = 0xcd;
    byte22[1] = 0xdc;
    byte22[2] = 0x3a;
    byte22[3] = 0x03;
    byte22[6] = 0x39;
    byte22[5] = 0x93;
    byte22[4] = 0xe8;
    NSMutableData *sdData22 = [NSMutableData dataWithBytes:address22 length:5];
    NSMutableData *data22 = [NSMutableData dataWithBytes:byte22 length:7];

    Byte address23[5];
    address23[0] = 0xcd;
    address23[1] = 0xdc;
    address23[2] = 0x40;
    address23[3] = 0x01;
    address23[4] = 0xc7;
    Byte byte23[7];
    byte23[0] = 0xcd;
    byte23[1] = 0xdc;
    byte23[2] = 0x3a;
    byte23[3] = 0x03;
    byte23[6] = 0x71;
    byte23[5] = 0x28;
    byte23[4] = 0xde;
    NSMutableData *sdData23 = [NSMutableData dataWithBytes:address23 length:5];
    NSMutableData *data23 = [NSMutableData dataWithBytes:byte23 length:7];


    Byte address24[5];
    address24[0] = 0xcd;
    address24[1] = 0xdc;
    address24[2] = 0x40;
    address24[3] = 0x01;
    address24[4] = 0xc8;
    Byte byte24[7];
    byte24[0] = 0xcd;
    byte24[1] = 0xdc;
    byte24[2] = 0x3a;
    byte24[3] = 0x03;
    byte24[6] = 0xca;
    byte24[5] = 0xd9;
    byte24[4] = 0x3a;
    NSMutableData *sdData24 = [NSMutableData dataWithBytes:address24 length:5];
    NSMutableData *data24 = [NSMutableData dataWithBytes:byte24 length:7];


    Byte address25[5];
    address25[0] = 0xcd;
    address25[1] = 0xdc;
    address25[2] = 0x40;
    address25[3] = 0x01;
    address25[4] = 0xc9;
    Byte byte25[7];
    byte25[0] = 0xcd;
    byte25[1] = 0xdc;
    byte25[2] = 0x3a;
    byte25[3] = 0x03;
    byte25[6] = 0x39;
    byte25[5] = 0x93;
    byte25[4] = 0xe8;
    NSMutableData *sdData25 = [NSMutableData dataWithBytes:address25 length:5];
    NSMutableData *data25 = [NSMutableData dataWithBytes:byte25 length:7];


    Byte address26[5];
    address26[0] = 0xcd;
    address26[1] = 0xdc;
    address26[2] = 0x40;
    address26[3] = 0x01;
    address26[4] = 0xca;
    Byte byte26[7];
    byte26[0] = 0xcd;
    byte26[1] = 0xdc;
    byte26[2] = 0x3a;
    byte26[3] = 0x03;
    byte26[6] = 0x8c;
    byte26[5] = 0xd8;
    byte26[4] = 0x2e;
    NSMutableData *sdData26 = [NSMutableData dataWithBytes:address26 length:5];
    NSMutableData *data26 = [NSMutableData dataWithBytes:byte26 length:7];


    Byte address27[5];
    address27[0] = 0xcd;
    address27[1] = 0xdc;
    address27[2] = 0x40;
    address27[3] = 0x01;
    address27[4] = 0xcb;
    Byte byte27[7];
    byte27[0] = 0xcd;
    byte27[1] = 0xdc;
    byte27[2] = 0x3a;
    byte27[3] = 0x03;
    byte27[6] = 0x39;
    byte27[5] = 0x93;
    byte27[4] = 0xe8;
    NSMutableData *sdData27 = [NSMutableData dataWithBytes:address27 length:5];
    NSMutableData *data27 = [NSMutableData dataWithBytes:byte27 length:7];


    Byte address28[5];
    address28[0] = 0xcd;
    address28[1] = 0xdc;
    address28[2] = 0x40;
    address28[3] = 0x01;
    address28[4] = 0xcc;
    Byte byte28[7];
    byte28[0] = 0xcd;
    byte28[1] = 0xdc;
    byte28[2] = 0x3a;
    byte28[3] = 0x03;
    byte28[6] = 0x71;
    byte28[5] = 0x28;
    byte28[4] = 0xde;
    NSMutableData *sdData28 = [NSMutableData dataWithBytes:address28 length:5];
    NSMutableData *data28 = [NSMutableData dataWithBytes:byte28 length:7];


    Byte address29[5];
    address29[0] = 0xcd;
    address29[1] = 0xdc;
    address29[2] = 0x40;
    address29[3] = 0x01;
    address29[4] = 0xcd;
    Byte byte29[7];
    byte29[0] = 0xcd;
    byte29[1] = 0xdc;
    byte29[2] = 0x3a;
    byte29[3] = 0x03;
    byte29[6] = 0xca;
    byte29[5] = 0xd9;
    byte29[4] = 0x3a;
    NSMutableData *sdData29 = [NSMutableData dataWithBytes:address29 length:5];
    NSMutableData *data29 = [NSMutableData dataWithBytes:byte29 length:7];

    NSMutableArray *dataArray = [NSMutableArray new];
    [dataArray addObject:sdData0];
    [dataArray addObject:data0];
    [dataArray addObject:sdData1];
    [dataArray addObject:data1];
    [dataArray addObject:sdData2];
    [dataArray addObject:data2];
    [dataArray addObject:sdData3];
    [dataArray addObject:data3];
    [dataArray addObject:sdData4];
    [dataArray addObject:data4];
    [dataArray addObject:sdData5];
    [dataArray addObject:data5];
    [dataArray addObject:sdData6];
    [dataArray addObject:data6];
    [dataArray addObject:sdData7];
    [dataArray addObject:data7];
    [dataArray addObject:sdData8];
    [dataArray addObject:data8];
    [dataArray addObject:sdData9];
    [dataArray addObject:data9];
    [dataArray addObject:sdData10];
    [dataArray addObject:data10];
    [dataArray addObject:sdData11];
    [dataArray addObject:data11];
    [dataArray addObject:sdData12];
    [dataArray addObject:data12];
    [dataArray addObject:sdData13];
    [dataArray addObject:data13];
    [dataArray addObject:sdData14];
    [dataArray addObject:data14];
    [dataArray addObject:sdData15];
    [dataArray addObject:data15];
    [dataArray addObject:sdData16];
    [dataArray addObject:data16];
    [dataArray addObject:sdData17];
    [dataArray addObject:data17];
    [dataArray addObject:sdData18];
    [dataArray addObject:data18];
    [dataArray addObject:sdData19];
    [dataArray addObject:data19];
    [dataArray addObject:sdData20];
    [dataArray addObject:data20];
    [dataArray addObject:sdData21];
    [dataArray addObject:data21];
    [dataArray addObject:sdData22];
    [dataArray addObject:data22];
    [dataArray addObject:sdData23];
    [dataArray addObject:data23];
    [dataArray addObject:sdData24];
    [dataArray addObject:data24];
    [dataArray addObject:sdData25];
    [dataArray addObject:data25];
    [dataArray addObject:sdData26];
    [dataArray addObject:data26];
    [dataArray addObject:sdData27];
    [dataArray addObject:data27];
    [dataArray addObject:sdData28];
    [dataArray addObject:data28];
    [dataArray addObject:sdData29];
    [dataArray addObject:data29];

    return dataArray;

}


+ (NSMutableArray *)getLimitData {

    Byte byte0[9], byte1[9], byte2[8];
    byte0[0] = byte1[0] = byte2[0] = 0xcd;
    byte0[1] = byte1[1] = byte2[1] = 0xdc;
    byte0[2] = 0x25;
    byte0[3] = 0x05;
    byte0[4] = 0x1b;
    byte0[5] = 0x00;
    byte0[6] = 0xf7;
    byte0[7] = 0x07;
    byte0[8] = 0x67;

    byte1[2] = 0x2a;
    byte1[3] = 0x05;
    byte1[4] = 0xb1;
    byte1[5] = 0x9b;
    byte1[6] = 0xff;
    byte1[7] = 0xff;
    byte1[8] = 0xf8;

    byte2[2] = 0x2f;
    byte2[3] = 0x04;
    byte2[4] = 0x67;
    byte2[5] = 0xb1;
    byte2[6] = 0x67;
    byte2[7] = 0xb1;


    NSMutableData *data0 = [NSMutableData dataWithBytes:byte0 length:9];
    NSMutableData *data1 = [NSMutableData dataWithBytes:byte1 length:9];
    NSMutableData *data2 = [NSMutableData dataWithBytes:byte2 length:8];

    NSMutableArray *dataArray = [NSMutableArray new];
    [dataArray addObject:data0];
    [dataArray addObject:data1];
    [dataArray addObject:data2];

    NSLog(@"getLimitData %@", dataArray);

    return dataArray;


}


@end
