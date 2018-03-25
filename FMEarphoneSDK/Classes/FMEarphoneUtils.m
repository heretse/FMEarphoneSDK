//
//  FMEarphoneCommand.m
//  FBSnapshotTestCase
//
//  Created by Winston Hsieh on 14/11/2017.
//

#import "FMEarphoneUtils.h"
#import "FMEarphoneCommand.h"
#import "FMEarphoneCommandDefines.h"
#import "NSMutableArray+QueueAdditions.h"

#define KEY_COMMAND_TYPE @"command_type"
#define KEY_READ_SIZE    @"read_size"

@implementation FMEarphoneUtils {
    EADSessionController *eadSessionController;
    NSArray *bufferDataArray;
    CommandType commandType;
    NSInteger currentIndex;
    FMEarphoneStatus *fmStatus;
    NSMutableArray<FMEarphoneCommand *> *cmdQueue;
    BOOL isRunning;
}

NSString *kFMEarphoneChangedNotification = @"kFMEarphoneChangedNotification";

- (id)initWithEADSessionController:(EADSessionController *)_eadSessionController andEarphoneStatus:(FMEarphoneStatus *)_status {
    self = [super init];
    if (self) {
        eadSessionController = _eadSessionController;
        [eadSessionController setDelegate:self];
        fmStatus = _status;
        cmdQueue = [NSMutableArray<FMEarphoneCommand *> new];
        isRunning = NO;
    }
    
    return self;
}

- (void)sendRawData:(NSData *)data withCommandType:(CommandType)type {
    commandType = type;
    
    [eadSessionController writeData:data];
}

- (void)executeCommand:(FMEarphoneCommand *)newCmd {
    
    if (isRunning) {
        @synchronized(cmdQueue) {
            [cmdQueue enqueue:newCmd];
        }
    } else {
        isRunning = YES;
        commandType = [newCmd commandType];
        bufferDataArray = [newCmd bufferDataArray];
        currentIndex = 0;
        [eadSessionController writeData:[bufferDataArray objectAtIndex:currentIndex]];
    }
}

- (void)checkHasCommandInQueue {
    if (!isRunning) {
        @synchronized(cmdQueue) {
            if ([cmdQueue count] > 0) {
                FMEarphoneCommand *newCmd = (FMEarphoneCommand *)[cmdQueue dequeue];
                
                isRunning = YES;
                commandType = [newCmd commandType];
                bufferDataArray = [newCmd bufferDataArray];
                currentIndex = 0;
                [eadSessionController writeData:[bufferDataArray objectAtIndex:currentIndex]];
            }
        }
    }
}

- (NSString *)getSavedEQSettingsFilePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:@ "CurrentEQSettings.plist" ];
    
    return filePath;
}

#pragma mark - EQ related command

/*
 *  @brief 调节均衡器
 *  @param fGain double，增量
 *  @param band band，波段（0-5）
 */

- (void)setEQ:(double)fGain
       withBand:(NSInteger)band {
    
    Byte bytesDisable[5], bytesEnable[5];
    bytesDisable[0] = bytesEnable[0] = 0xcd;
    bytesDisable[1] = bytesEnable[1] = 0xdc;
    bytesDisable[2] = bytesEnable[2] = 0x20;
    bytesDisable[3] = bytesEnable[3] = 0x01;
    bytesDisable[4] = 0x00;
    bytesEnable[4] = 0x0e;
    NSMutableData *disableData = [NSMutableData dataWithBytes:bytesDisable length:5];
    NSMutableData *enableData = [NSMutableData dataWithBytes:bytesEnable length:5];
    
    NSMutableArray *buffArray = [NSMutableArray new];
    NSMutableArray *eqDataArray = [EqCalculate getCommandData:fGain withBand:band];
    buffArray = [NSMutableArray new];
    [buffArray addObject:disableData];
    [buffArray addObjectsFromArray:eqDataArray];
    [buffArray addObject:enableData];
    
    NSMutableArray *bufferDataArray = [[NSMutableArray alloc] initWithArray:buffArray];
    NSMutableData *data0 = [bufferDataArray objectAtIndex:0];
    /*
    [[EAManager sharedController] ECSendRawData:_device protocol:_protocol data:data0 commandType:CommandSetEQ curDataIndex:0 allDataCount:_bufferDataArray.count];*/
}

/*! @brief 设置EQ是否开启
 *@param enable 布尔型，是否开启DRC(YES-开启 NO-关闭)
 */
- (void)setEQEnable:(BOOL)enable {
    
    NSString *filePath = [self getSavedEQSettingsFilePath];
    NSMutableArray *eqValueArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:0],
                                    [NSNumber numberWithInteger:0],
                                    [NSNumber numberWithInteger:0],
                                    [NSNumber numberWithInteger:0],
                                    [NSNumber numberWithInteger:0],
                                    [NSNumber numberWithInteger:0], nil];
    //读取配置信息
    NSArray *setInfoArr = [NSArray arrayWithContentsOfFile:filePath];
    if (setInfoArr) {
        NSDictionary *EqDict = setInfoArr[0];
        eqValueArray = [EqDict objectForKey:EqSetValueArr];
    }
    
    float gain0 = [[eqValueArray objectAtIndex:0] floatValue];
    float gain1 = [[eqValueArray objectAtIndex:1] floatValue];
    float gain2 = [[eqValueArray objectAtIndex:2] floatValue];
    float gain3 = [[eqValueArray objectAtIndex:3] floatValue];
    float gain4 = [[eqValueArray objectAtIndex:4] floatValue];
    float gain5 = [[eqValueArray objectAtIndex:5] floatValue];
 
    NSLog(@"ESInitSavedInfo gain0:%f, gain1:%f, gain2:%f, gain3:%f, gain4:%f, gain5:%f", gain0, gain1, gain2, gain3, gain4, gain5);
    NSMutableArray *band0Data = [EqCalculate getCommandData:gain0  withBand:0];
    NSMutableArray *band1Data = [EqCalculate getCommandData:gain1  withBand:1];
    NSMutableArray *band2Data = [EqCalculate getCommandData:gain2  withBand:2];
    NSMutableArray *band3Data = [EqCalculate getCommandData:gain3  withBand:3];
    NSMutableArray *band4Data = [EqCalculate getCommandData:gain4  withBand:4];
    NSMutableArray *band5Data = [EqCalculate getCommandData:gain5  withBand:5];
    
    Byte bytes[5];
    bytes[0] = 0xcd;
    bytes[1] = 0xdc;
    bytes[2] = 0x20;
    bytes[3] = 0x01;
    
    if (enable) {
        bytes[4] = 0x0e;
    } else {
        bytes[4] = 0x00;
    }
    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:5];
    
    NSMutableArray *tempBufferData = [NSMutableArray new];
    
    if (enable) {
        //EQ数据
        [tempBufferData addObjectsFromArray:band0Data];
        [tempBufferData addObjectsFromArray:band1Data];
        [tempBufferData addObjectsFromArray:band2Data];
        [tempBufferData addObjectsFromArray:band3Data];
        [tempBufferData addObjectsFromArray:band4Data];
        [tempBufferData addObjectsFromArray:band5Data];
    }
    [tempBufferData addObject:data];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandSetEQStatus];
    [newCmd setBufferDataArray:tempBufferData];
    
    [self executeCommand:newCmd];
}

/*
 * @brief Get current EQ status
 */
- (void)getEQStatus {
    
    Byte bytes[4];
    bytes[0] = 0xdc;
    bytes[1] = 0xcd;
    bytes[2] = 0x20;
    bytes[3] = 0x01;
    
    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:4];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandGetEQStatus];
    [newCmd setBufferDataArray:@[data]];
    
    [self executeCommand:newCmd];
}

/*
 * @brief Get current sound effect status
 */
- (void)getSoundEffectStatus {
    
    Byte bytes[4];
    bytes[0] = 0xdc;
    bytes[1] = 0xcd;
    bytes[2] = 0x39;
    bytes[3] = 0x01;
    
    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:4];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandGetSoundEffectStatus];
    [newCmd setBufferDataArray:@[data]];
    
    [self executeCommand:newCmd];
}

/*
 * @brief 根据场景模式设置EQ
 * @param sceneType 枚举型
 */
- (void)setSceneByType:(SceneType)sceneType {
    NSMutableArray *gainArrays  = [EqCalculate getGainByBySceneType:sceneType];
    [self setSceneWithGains:gainArrays];
}

/*! @brief 根据增量设置EQ
 *  @param gainArrays NSMutableArray 长度为6的数组，存放每段的增量
 */
- (void)setSceneWithGains:(NSMutableArray*)gainArrays {
    
    Byte bytesDisable[5],bytesEnable[5];
    bytesDisable[0] = bytesEnable[0] = 0xcd;
    bytesDisable[1] = bytesEnable[1] = 0xdc;
    bytesDisable[2] = bytesEnable[2] = 0x20;
    bytesDisable[3] = bytesEnable[3] = 0x01;
    bytesDisable[4] = 0x00;
    bytesEnable[4]  = 0x0e;
    NSMutableData *disableData = [NSMutableData dataWithBytes:bytesDisable length:5];
    NSMutableData *enableData = [NSMutableData dataWithBytes:bytesEnable length:5];
    
    double gain0 = [[gainArrays objectAtIndex:0] doubleValue];
    double gain1 = [[gainArrays objectAtIndex:1] doubleValue];
    double gain2 = [[gainArrays objectAtIndex:2] doubleValue];
    double gain3 = [[gainArrays objectAtIndex:3] doubleValue];
    double gain4 = [[gainArrays objectAtIndex:4] doubleValue];
    double gain5 = [[gainArrays objectAtIndex:5] doubleValue];
    
    NSMutableArray *bufferArray = [NSMutableArray new];
    NSMutableArray *band0Data = [EqCalculate getCommandData:gain0  withBand:0];
    NSMutableArray *band1Data = [EqCalculate getCommandData:gain1  withBand:1];
    NSMutableArray *band2Data = [EqCalculate getCommandData:gain2 withBand:2];
    NSMutableArray *band3Data = [EqCalculate getCommandData:gain3  withBand:3];
    NSMutableArray *band4Data = [EqCalculate getCommandData:gain4  withBand:4];
    NSMutableArray *band5Data = [EqCalculate getCommandData:gain5  withBand:5];
    
    [bufferArray addObject:disableData];
    [bufferArray addObjectsFromArray:band0Data];
    [bufferArray addObjectsFromArray:band1Data];
    [bufferArray addObjectsFromArray:band2Data];
    [bufferArray addObjectsFromArray:band3Data];
    [bufferArray addObjectsFromArray:band4Data];
    [bufferArray addObjectsFromArray:band5Data];
    [bufferArray addObject:enableData];
    
    NSMutableArray *bufferDataArray = [[NSMutableArray alloc] initWithArray:bufferArray];
    NSLog(@"setSceneWithGains data: %@", bufferDataArray);
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandSetScene];
    [newCmd setBufferDataArray:bufferDataArray];
    
    [self executeCommand:newCmd];
}

/*! @brief 设置音效增强是否开启
 *@attention 开启音效增强之前要确保已经注册doc和dsp,否则不起作用
 *@param enable 布尔型，是否开启音效增强(YES-开启 NO-关闭)
 */
- (void)ESSetSoundEffectEnable:(BOOL)enable {
    
    //07 06 02 00(0xc7) enable bass and treble
    //10(0x39) enable 3D
    Byte bytes0[5],bytes1[5],bytes2[5],byte3[5];
    bytes0[0] = bytes1[0] = bytes2[0] = byte3[0] = 0xcd;
    bytes0[1] = bytes1[1] = bytes2[1] = byte3[1] = 0xdc;
    bytes0[2] = bytes1[2] = bytes2[2] = 0xc7;
    bytes0[3] = bytes1[3] = bytes2[3] = byte3[3] = 0x01;
    byte3[2] = 0x39;
    if (enable == YES) {
        bytes0[4] = 0x02;
        bytes1[4] = 0x06;
        bytes2[4] = 0x07;
        byte3[4] = 0x10;
    } else {
        bytes0[4] = 0x06;
        bytes1[4] = 0x02;
        bytes2[4] = 0x00;
        byte3[4] = 0x00;
    }
    
    NSMutableData *data0 = [NSMutableData dataWithBytes:bytes0 length:5];
    NSMutableData *data1 = [NSMutableData dataWithBytes:bytes1 length:5];
    NSMutableData *data2 = [NSMutableData dataWithBytes:bytes2 length:5];
    NSMutableData *data3 = [NSMutableData dataWithBytes:byte3 length:5];
    
    NSMutableArray *bufferDataArray = [NSMutableArray new];
    [bufferDataArray addObject:data0];
    [bufferDataArray addObject:data1];
    [bufferDataArray addObject:data2];
    [bufferDataArray addObject:data3];
    
    /*
    _writeCount = 0;
    [[EAManager sharedController] ECSendRawData:_device protocol:_protocol data:data0 commandType:CommandSetSoundEffectStatus curDataIndex:0 allDataCount:_bufferDataArray.count];
     */
}


/*
 * @brief 设置音效增强
 * @param effectMode 枚举型，音效增强模式 SoundEffectBass-低音, SoundEffectTreble-高音, SoundEffect3D-环绕音
 */
/*
- (void)ESSetSoundEffect:(SoundEffectMode)effectMode
               withValue:(float)value{
    NSLog(@"set SE with mode:%d, value:%f", effectMode, value);
    
    switch (effectMode) {
        case SoundEffectBass: {
            int  makeupgain = (int)(value/1.5);
            Byte byteValue = (Byte)(makeupgain & 0xff);
            Byte byts[5];
            byts[0] = 0xcd;
            byts[1] = 0xdc;
            byts[2] = 0xc9;
            byts[3] = 0x01;
            byts[4] = byteValue;
            _bufferDataArray = [NSMutableArray new];
            NSMutableData *data0 = [NSMutableData dataWithBytes:byts length:5];
            _writeCount = 0;
            [[EAManager sharedController] ECSendRawData:_device protocol:_protocol data:data0 commandType:CommandSetSoundEffect curDataIndex:0 allDataCount:1];
        }
            break;
            
        case SoundEffectTreble: {
            int  makeupgain = (int)(value/1.5);
            Byte byteValue = (Byte)(makeupgain & 0xff);
            Byte byts[5];
            byts[0] = 0xcd;
            byts[1] = 0xdc;
            byts[2] = 0xd7;
            byts[3] = 0x01;
            byts[4] = byteValue;
            _bufferDataArray = [NSMutableArray new];
            NSMutableData *data0 = [NSMutableData dataWithBytes:byts length:5];
            [_bufferDataArray addObject:data0];
            _writeCount = 0;
            [[EAManager sharedController] ECSendRawData:_device protocol:_protocol data:data0 commandType:CommandSetSoundEffect curDataIndex:0 allDataCount:1];
        }
            break;
            
        case SoundEffect3D: {
            Byte byts[5];
            byts[0] = 0xcd;
            byts[1] = 0xdc;
            byts[2] = 0x40;
            byts[3] = 0x01;
            byts[4] = 0xae;
            NSMutableData *data0 = [NSMutableData dataWithBytes:byts length:5];
            
            float mult = 4194304.0f;
            int mixval = (int)(floor(value * mult));
            Byte BLow, BMid, BHi;
            BLow = (Byte)(mixval & 0xff);
            BMid = (Byte)((mixval >> 8) & 0xff);
            BHi = (Byte)((mixval >> 16) & 0xff);
            
            Byte bytes[7];
            bytes[0] = 0xcd;
            bytes[1] = 0xdc;
            bytes[2] = 0x3a;
            bytes[3] = 0x03;
            bytes[4] = BLow;
            bytes[5] = BMid;
            bytes[6] = BHi;
            
            NSMutableData *data = [NSMutableData dataWithBytes:bytes length:7];
            _bufferDataArray = [NSMutableArray new];
            [_bufferDataArray addObject:data0];
            [_bufferDataArray addObject:data];
            _writeCount = 0;
            [[EAManager sharedController] ECSendRawData:_device protocol:_protocol data:data0 commandType:CommandSetSoundEffect curDataIndex:0 allDataCount:_bufferDataArray.count];
        }
            break;
            
        default:
            break;
    }
}
*/
/*
 * @brief 重置音效增强
 */
- (void)resetSoundEffect {
    NSLog(@"set se to default:%f", SURROUND_DEFAULT);
    
    Byte bassValue = (Byte)(0 & 0xff);
    Byte bassByts[5];
    bassByts[0] = 0xcd;
    bassByts[1] = 0xdc;
    bassByts[2] = 0xc9;
    bassByts[3] = 0x01;
    bassByts[4] = bassValue;
    NSMutableData *bassData = [NSMutableData dataWithBytes:bassByts length:5];
    
    Byte trebleValue = (Byte)(0 & 0xff);
    Byte trebleByts[5];
    trebleByts[0] = 0xcd;
    trebleByts[1] = 0xdc;
    trebleByts[2] = 0xd7;
    trebleByts[3] = 0x01;
    trebleByts[4] = trebleValue;
    NSMutableData *trebleData = [NSMutableData dataWithBytes:trebleByts length:5];
    
    Byte byts[5];
    byts[0] = 0xcd;
    byts[1] = 0xdc;
    byts[2] = 0x40;
    byts[3] = 0x01;
    byts[4] = 0xae;
    NSMutableData *data0 = [NSMutableData dataWithBytes:byts length:5];
    
    float mult = 4194304.0f;
    int mixval = (int)(floor(SURROUND_DEFAULT * mult));
    Byte BLow, BMid, BHi;
    BLow = (Byte)(mixval & 0xff);
    BMid = (Byte)((mixval >> 8) & 0xff);
    BHi = (Byte)((mixval >> 16) & 0xff);
    Byte bytes[7];
    bytes[0] = 0xcd;
    bytes[1] = 0xdc;
    bytes[2] = 0x3a;
    bytes[3] = 0x03;
    bytes[4] = BLow;
    bytes[5] = BMid;
    bytes[6] = BHi;
    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:7];
    
    NSMutableArray *bufferDataArray = [NSMutableArray new];
    [bufferDataArray addObject:bassData];
    [bufferDataArray addObject:trebleData];
    [bufferDataArray addObject:data0];
    [bufferDataArray addObject:data];
    /*
    [[EAManager sharedController] ECSendRawData:_device protocol:_protocol data:bassData commandType:CommandResetSoundEffect curDataIndex:0 allDataCount:_bufferDataArray.count];
     */
}

#pragma mark - FM related command

- (void)doI2CReadWithCommandType:(CommandType)commandType {
    [self doI2CReadWithCommandType:commandType andSize:0x01];
}

- (void)doI2CReadWithCommandType:(CommandType)commandType andSize:(Byte)size {
    
    Byte cmd[5];
    cmd[0] = 0xde; // Command for external I2C read
    cmd[1] = 0xad; // Command for external I2C read
    cmd[2] = 0x00; // reg; // Si4705 STATUS register address
    cmd[3] = size; // Total number data reads for external I2C device
    cmd[4] = 0x22; // External Si4705 I2C address
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:5];
    
    [self sendRawData:data withCommandType:commandType];
}

- (void)doI2CReadWithTimer:(NSTimer *)timer {
    if (timer == nil) {
        return;
    }
    
    NSInteger commandType = [[[timer userInfo] objectForKey:KEY_COMMAND_TYPE] integerValue];
    
    Byte size[1] = {0x01};
    NSData *readSize = (NSData *)[[timer userInfo] objectForKey:KEY_READ_SIZE];
    if (readSize != nil) {
        [readSize getBytes:size length:1];
    }
    
    [self doI2CReadWithCommandType:commandType andSize:size[0]];
}

- (void)setPropertyWithCommandType:(CommandType)commandType andArguments:(Byte [])argv {
    Byte cmd[10];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_SET_PROPERTY;
    cmd[3] = 0x05;
    cmd[4] = argv[0];
    cmd[5] = argv[1];
    cmd[6] = argv[2];
    cmd[7] = argv[3];
    cmd[8] = argv[4];
    cmd[9] = 0x22;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:10];
    
    [self sendRawData:data withCommandType:commandType];
}

- (void)doDinControlHigh {
    Byte cmd[3];
    cmd[0] = 0xbe;
    cmd[1] = 0xad;
    cmd[2] = 0x01;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:3];
    
    NSArray *allData = @[data];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandDoDinControlHigh];
    [newCmd setBufferDataArray:allData];
    
    [self executeCommand:newCmd];
}

- (void)doDinControlLow {
    Byte cmd[3];
    cmd[0] = 0xbe;
    cmd[1] = 0xad;
    cmd[2] = 0x00;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:3];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandDoDinControlLow];
    [newCmd setBufferDataArray:@[data]];
    
    [self executeCommand:newCmd];
}

- (void)getDeviceInfo {
    Byte bytes[2];
    bytes[0] = 0xab;
    bytes[1] = 0xba;
    
    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:2];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandGetDeviceInfo];
    [newCmd setBufferDataArray:@[data]];
    
    [self executeCommand:newCmd];
}

- (void)setFMPowerUp {
    Byte cmd[8];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_POWER_UP;
    cmd[3] = 0x02;
    cmd[4] = 0xc0;
    cmd[5] = 0xb0;
    cmd[6] = 0x22;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:7];
    
    [self sendRawData:data withCommandType:CommandSetFMPowerUp];
}

- (void)setFMPowerDown {
    Byte cmd[8];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_POWER_DOWN;
    cmd[3] = 0x00;
    cmd[4] = 0x22;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:5];
    
    [self sendRawData:data withCommandType:CommandSetFMPowerDown];
}

/*
 CMD            0x12    SET_PROPERTY
 ARG1           0x00
 ARG2 (PROP)    0x02    REFCLK_FREQ
 ARG3 (PROP)    0x01
 ARG4 (PROPD)   0x7E    REFCLK = 32500 Hz
 ARG5 (PROPD)   0xF4
 STATUS         0x80    Reply Status. Clear-to-send high.
 */
- (void)setRefclkFreq {
    Byte argv[5];
    argv[0] = 0x00;
    argv[1] = 0x02;
    argv[2] = 0x01;
    argv[3] = 0x7d;//0x7e;
    argv[4] = 0x00;//0xf4;
    
    [self setPropertyWithCommandType:CommandSetRefclkFreq andArguments:argv];
}

/*
 CMD            0x12    SET_PROPERTY
 ARG1           0x00
 ARG2 (PROP)    0x02    REFCLK_PRESCALE
 ARG3 (PROP)    0x02
 ARG4 (PROPD)   0x01    Divide by 400
 ARG5 (PROPD)   0x90    (example RCLK = 13 MHz, REFCLK = 32500 Hz)
 STATUS         0x80    Reply Status. Clear-to-send high.
 */
- (void)setRefclkPrescale {
    Byte argv[5];
    argv[0] = 0x00;
    argv[1] = 0x02;
    argv[2] = 0x02;
    argv[3] = 0x10;//0x01;
    argv[4] = 0x60;//0x90;
    
    [self setPropertyWithCommandType:CommandSetRefclkPrescale andArguments:argv];
}

/*
 CMD            0x12    SET_PROPERTY
 ARG1           0x00
 ARG2 (PROP)    0x01    DIGITAL_OUTPUT_SAMPLE_RATE
 ARG3 (PROP)    0x04
 ARG4 (PROPD)   0xBB    Sample rate = 48000Hz = 0xBB80
 ARG5 (PROPD)   0x80
 STATUS         0x80    Reply Status. Clear-to-send high.
 */
- (void)setDigitalOutputSampleRate {
    Byte argv[5];
    argv[0] = 0x00;
    argv[1] = 0x01;
    argv[2] = 0x04;
    argv[3] = 0xbb;
    argv[4] = 0x80;
    
    [self setPropertyWithCommandType:CommandSetDigitalOutputSampleRate andArguments:argv];
}

/*
 CMD            0x12    SET_PROPERTY
 ARG1           0x00
 ARG2 (PROP)    0x01    DIGITAL_OUTPUT_FORMAT
 ARG3 (PROP)    0x02
 ARG4 (PROPD)   0x00    Mode: I2S, stereo, 16bit, sample on rising edge of DCLK.
 ARG5 (PROPD)   0x00
 STATUS         0x80    Reply Status. Clear-to-send high.
 */
- (void)setDigitalOutputFormat {
    Byte argv[5];
    argv[0] = 0x00;
    argv[1] = 0x01;
    argv[2] = 0x02;
    argv[3] = 0x00;
    argv[4] = 0x00;
    
    [self setPropertyWithCommandType:CommandSetDigitalOutputFormat andArguments:argv];
}

/*
 CMD            0x12    SET_PROPERTY
 ARG1           0x00
 ARG2 (PROP)    0x14    FM_SEEK_FREQ_SPACING
 ARG3 (PROP)    0x02
 ARG4 (PROPD)   0x00
 ARG5 (PROPD)   0x14    Freq Spacing = 200 kHz = 0x0014
 STATUS         0x80    Reply Status. Clear-to-send high.
 */
- (void)setFMSeekFreqSpacing {
    Byte argv[5];
    argv[0] = 0x00;
    argv[1] = 0x14;
    argv[2] = 0x02;
    argv[3] = 0x00;
    argv[4] = 0x0a;
    
    [self setPropertyWithCommandType:CommandSetFMSeekFreqSpacing andArguments:argv];
}

/*
 CMD            0x12    SET_PROPERTY
 ARG1           0x00
 ARG2 (PROP)    0x14    FM_SEEK_TUNE_RSSI_THRESHOLD
 ARG3 (PROP)    0x04
 ARG4 (PROPD)   0x00
 ARG5 (PROPD)   0x14    Threshold = 20 dBμV = 0x0014
 STATUS         0x80    Reply Status. Clear-to-send high.
 */
- (void)setFMSeekTuneRssiThreshold {
    Byte argv[5];
    argv[0] = 0x00;
    argv[1] = 0x14;
    argv[2] = 0x04;
    argv[3] = 0x00;
    argv[4] = 0x14;// default value 0x14
    
    [self setPropertyWithCommandType:CommandSetFMSeekTuneRssiThreshold andArguments:argv];
}

- (void)setFMTuneDefaultFreq {
    [self setFMTuneFreq:(UTF16Char)[fmStatus currentFrequency]];
}

- (void)setFMTuneFreq:(UTF16Char)frequency {
    Byte cmd[10];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_FM_TUNE_FREQ;
    cmd[3] = 0x04;
    cmd[4] = 0x00;
    cmd[5] = (Byte)(frequency >> 8);
    cmd[6] = (Byte)(frequency & 0x00FF);
    cmd[7] = (Byte)0x00;
    cmd[8] = 0x22;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:9];
    
    [self sendRawData:data withCommandType:CommandSetFMTuneFreq];
}

/*
 CMD        0x14    GET_INT_STATUS
 STATUS     0x81    Reply Status. Clear-to-send high. STCINT = 1.
 */
- (void)getFMIntStatus {
    Byte cmd[8];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_GET_INT_STATUS;
    cmd[3] = 0x00;
    cmd[4] = 0x22;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:5];
    
    [self sendRawData:data withCommandType:CommandGetFMIntStatus];
}

- (void)getFMTuneStatus {
    [self getFMTuneStatus:0x00 intack:0x00];
}

/*
 Outputs:  These are global variables and are set by this method
 STC:    The seek/tune is complete
 BLTF:   The seek reached the band limit or original start frequency
 AFCRL:  The AFC is railed if this is non-zero
 Valid:  The station is valid if this is non-zero
 Freq:   The current frequency
 RSSI:   The RSSI level read at tune.
 ASNR:   The audio SNR level read at tune.
 AntCap: The current level of the tuning capacitor.
 */
- (void)getFMTuneStatus:(Byte)cancel intack:(Byte)intack {
    Byte cmd[8];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_FM_TUNE_STATUS;
    cmd[3] = 0x01;
    cmd[4] = 0x00;
    cmd[5] = 0x22;
    
    if (cancel)
        cmd[4] |= LAM_FM_TUNE_STATUS_IN_CANCEL;
    if (intack)
        cmd[4] |= LAM_FM_TUNE_STATUS_IN_INTACK;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:6];
    
    [self sendRawData:data withCommandType:CommandGetFMTuneStatus];
}

- (void)setFMSeekStart:(Byte)seekUp wrap:(Byte)wrap {
    Byte cmd[6];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_FM_SEEK_START;
    cmd[3] = 0x01;
    cmd[4] = 0x00;
    cmd[5] = 0x22;
    
    if (wrap)
        cmd[4] |= LAM_FM_SEEK_START_IN_WRAP;
    if (seekUp)
        cmd[4] |= LAM_FM_SEEK_START_IN_SEEKUP;
    
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:6];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandFMSeekStart];
    [newCmd setBufferDataArray:@[data]];
    
    [self executeCommand:newCmd];
}

/*
 Outputs:
 Si47xx_status.Status:  Contains bits about the status returned from the part.
 Si47xx_status.RsqInts: Contains bits about the interrupts
 that have fired related to RSQ.
 SMUTE:   The soft mute function is currently enabled
 AFCRL:   The AFC is railed if this is non-zero
 Valid:   The station is valid if this is non-zero
 Pilot:   A pilot tone is currently present
 Blend:   Percentage of blend for stereo. (100 = full stereo)
 RSSI:    The RSSI level read at tune.
 ASNR:    The audio SNR level read at tune.
 FreqOff: The frequency offset in kHz of the current station
 from the tuned frequency.
 */
- (void)getFMRsqStatus:(Byte)intack {
    Byte cmd[8];
    cmd[0] = 0xfe;
    cmd[1] = 0xed;
    cmd[2] = LAM_FM_RSQ_STATUS;
    cmd[3] = 0x01;
    cmd[4] = 0x00;
    cmd[5] = 0x22;
    
    if (intack)
        cmd[4] |= LAM_FM_TUNE_STATUS_IN_INTACK;
    
    NSMutableData *data = [NSMutableData dataWithBytes:cmd length:6];
    
    FMEarphoneCommand *newCmd = [FMEarphoneCommand new];
    [newCmd setCommandType:CommandGetFMRsqStatus];
    [newCmd setBufferDataArray:@[data]];
    
    [self executeCommand:newCmd];
}

#pragma mark - EADSessionDelegate

- (void)sessionOpenCompleted {
    [self getDeviceInfo];
    [self getFMRsqStatus:0x00];
}

- (void)sessionDataReceived:(NSData *)data {
    
    Byte byte1 = ((Byte*)([data bytes]))[0];
    
    Byte byte5 = '\0';
    if ([data length] >= 5) {
        byte5 = ((Byte*)([data bytes]))[4];
    }
    
    if (CommandSetFMPowerUpRead == commandType) {
        NSLog(@"CommandSetFMPowerUpRead byte4: %@", data);
        //NSLog(@"CommandSetFMPowerUpRead byte4: %hhu", byte5);
    }
    
    if (byte5 == 0x80 || byte5 == 0x81 || byte5 == 0x85) {
        switch (commandType) {
            case CommandSetFMPowerUpRead: {
                NSLog(@"CommandSetFMPowerUpRead completed.");
                [self setRefclkFreq];
            }
                break;
            case CommandSetRefclkFreqRead: {
                NSLog(@"CommandSetRefclkFreqRead completed.");
                [self setRefclkPrescale];
            }
                break;
            case CommandSetRefclkPrescaleRead: {
                NSLog(@"CommandSetRefclkPrescaleRead completed.");
                [self setDigitalOutputSampleRate];
            }
                break;
            case CommandSetDigitalOutputSampleRateRead: {
                NSLog(@"CommandSetDigitalOutputSampleRateRead completed.");
                [self setDigitalOutputFormat];
            }
                break;
            case CommandSetDigitalOutputFormatRead: {
                NSLog(@"CommandSetDigitalOutputFormatRead completed.");
                [self setFMSeekFreqSpacing];
            }
                break;
            case CommandSetFMSeekFreqSpacingRead: {
                NSLog(@"CommandSetFMSeekFreqSpacingRead completed.");
                // Sets the RSSI threshold for a valid FM Seek/Tune.
                [self setFMSeekTuneRssiThreshold];
            }
                break;
            case CommandSetFMSeekTuneRssiThresholdRead: {
                NSLog(@"CommandSetFMSeekTuneRssiThresholdRead completed.");
                [self setFMTuneDefaultFreq];
            }
                break;
            case CommandSetFMTuneFreqRead: {
                NSLog(@"CommandSetFMTuneFreqRead completed.");
                [self getFMIntStatus];
            }
                break;
            case CommandGetFMIntStatusRead: {
                NSLog(@"CommandGetFMIntStatusRead completed.");
                if (byte5 == 0x81) {
                    [self getFMTuneStatus];
                    [fmStatus setIsPlaying:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFMEarphoneChangedNotification object:nil userInfo:nil];
                } else {
                    [self getFMIntStatus];
                }
            }
                break;
            case CommandGetFMTuneStatusRead: {
                NSLog(@"CommandGetFMTuneStatusRead completed.");
                isRunning = NO;
                if ([data length] >= 8) {
                    Byte byte7 = ((Byte*)([data bytes]))[6];
                    Byte byte8 = ((Byte*)([data bytes]))[7];
                    int frequency = 0;
                    frequency += (byte7 << 8);
                    frequency += byte8;
                    
                    [fmStatus setIsPlaying:YES];
                    [fmStatus setCurrentFrequency:frequency];
                    NSLog(@"%@", [NSString stringWithFormat:@"%d", frequency]);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFMEarphoneChangedNotification object:nil userInfo:nil];
                }
            }
                break;
            case CommandFMSeekStartRead: {
                if (byte5 == 0x81) {
                    [self getFMTuneStatus];
                } else {
                    [self getFMIntStatus];
                }
            }
                break;
            case CommandGetFMRsqStatusRead: {
                NSLog(@"CommandGetFMRsqStatusRead completed.");
                if ([data length] >= 10) {
                    Byte byte10 = ((Byte*)([data bytes]))[9];
                    
                    if (byte10 > 0x00) {
                        [self getFMTuneStatus];
                    } else {
                        isRunning = NO;
                    }
                }
            }
                break;
            default:
                break;
        }
        
        return;
    }
    
    if (byte1 == 0x40) {
        switch(commandType) {
            case CommandDoDinControlHigh: {
                NSLog(@"CommandDoDinControlHigh completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setFMPowerUp) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandDoDinControlLow: {
                NSLog(@"CommandDoDinControlLow completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setFMPowerDown) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandSetFMPowerUp: {
                NSLog(@"CommandSetFMPowerUp completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(doI2CReadWithTimer:) userInfo:@{KEY_COMMAND_TYPE:[NSNumber numberWithInteger:CommandSetFMPowerUpRead]} repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandSetRefclkFreq: {
                NSLog(@"CommandSetRefclkFreq completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doI2CReadWithTimer:) userInfo:@{KEY_COMMAND_TYPE:[NSNumber numberWithInteger:CommandSetRefclkFreqRead]} repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandSetRefclkPrescale: {
                NSLog(@"CommandSetRefclkPrescale completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doI2CReadWithTimer:) userInfo:@{KEY_COMMAND_TYPE:[NSNumber numberWithInteger:CommandSetRefclkPrescaleRead]} repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandSetDigitalOutputSampleRate: {
                NSLog(@"CommandSetDigitalOutputSampleRate completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doI2CReadWithTimer:) userInfo:@{KEY_COMMAND_TYPE:[NSNumber numberWithInteger:CommandSetDigitalOutputSampleRateRead]} repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandSetDigitalOutputFormat: {
                NSLog(@"CommandSetDigitalOutputFormat completed.");
                [self doI2CReadWithCommandType:CommandSetDigitalOutputFormatRead andSize:0x01];
            }
                break;
            case CommandSetFMSeekFreqSpacing: {
                NSLog(@"CommandSetFMSeekFreqSpacing completed.");
                [self doI2CReadWithCommandType:CommandSetFMSeekFreqSpacingRead andSize:0x01];
            }
                break;
            case CommandSetFMSeekTuneRssiThreshold: {
                NSLog(@"CommandSetFMSeekTuneRssiThreshold completed.");
                [self doI2CReadWithCommandType:CommandSetFMSeekTuneRssiThresholdRead andSize:0x01];
            }
                break;
            case CommandSetFMTuneFreq: {
                NSLog(@"CommandSetFMTuneFreq completed.");
                [self doI2CReadWithCommandType:CommandSetFMTuneFreqRead andSize:0x01];
            }
                break;
            case CommandGetFMIntStatus: {
                NSLog(@"CommandGetFMIntStatus completed.");
                [self doI2CReadWithCommandType:CommandGetFMIntStatusRead];
            }
                break;
            case CommandGetFMTuneStatus: {
                NSLog(@"CommandGetFMTuneStatus completed.");
                [self doI2CReadWithCommandType:CommandGetFMTuneStatusRead andSize:0x08];
            }
                break;
            case CommandFMSeekStart: {
                NSLog(@"CommandFMSeekStart completed.");
                [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doI2CReadWithTimer:) userInfo:@{KEY_COMMAND_TYPE:[NSNumber numberWithInteger:CommandFMSeekStartRead]} repeats:NO] forMode:NSRunLoopCommonModes];
            }
                break;
            case CommandSetFMPowerDown: {
                NSLog(@"CommandSetFMPowerDown completed.");
                isRunning = NO;
                [fmStatus setIsPlaying:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFMEarphoneChangedNotification object:nil userInfo:nil];
            }
                break;
            case CommandGetFMRsqStatus: {
                NSLog(@"CommandGetFMRsqStatus completed.");
                [self doI2CReadWithCommandType:CommandGetFMRsqStatusRead andSize:0x08];
            }
                break;
                
            case CommandGetDeviceInfo:
                isRunning = NO;
                
                break;
            
            case CommandGetEQStatus:
                
                break;
                
            case CommandSetEQ:
            case CommandSetEQStatus: {
                currentIndex += 1;
                if (currentIndex < [bufferDataArray count]) {
                    // Continue to write data
                    [eadSessionController writeData:[bufferDataArray objectAtIndex:currentIndex]];
                } else {
                    
                }
            }
                
            case CommandGetSoundEffectStatus:
                
                break;
                
            default:
                break;
        }
    } else {
        isRunning = NO;
    }
    
    [self checkHasCommandInQueue];
}

@end
