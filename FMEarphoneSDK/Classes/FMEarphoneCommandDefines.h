//
//  FMEarphoneCommandDefines.h
//  Pods
//
//  Created by Winston Hsieh on 15/11/2017.
//

#ifndef FMEarphoneCommandDefines_h
#define FMEarphoneCommandDefines_h

// Equalizer frequency
#define BAND0_FREQ 80.0
#define BAND1_FREQ 200.0
#define BAND2_FREQ 500.0
#define BAND3_FREQ 1000.0
#define BAND4_FREQ 2000.0
#define BAND5_FREQ 5000.0

#define SURROUND_MAX -1.0f
#define SURROUND_MIN 1.0f
#define SURROUND_DEFAULT 0.0f //SURROUND_MIX

// 耳机配置信息
static NSString * const EqOnStatus = @"EqOnStatus";        //Equalizer Status
static NSString * const EqDefaultName = @"EqDefaultName";  //Equalizer Default Name
static NSString * const EqSetValueArr = @"EqSetValueArr" ; //Equalizer Setting Values均衡器设置值数组
static NSString * const EqTypeIndex = @"EqTypeIndex"; //0-None, 1-Custom, 2-Default

// Sound Effect Mode enumeration
typedef enum {
    ModeBass,
    ModeVocal,
    ModeTreble,
    Mode3D
    
} SoundEffectMode;

// Scene Type enumeration
typedef enum {
    SceneTypeNone = 1,
    SceneTypeClassical,
    SceneTypePop,
    SceneTypeDance,
    SceneTypeJazz,
    SceneTypeMetal,
    SceneTypeLatin,
    SceneTypeRock,
    SceneTypeElectronic,
    SceneTypeRB,
    SceneTypeAcoustic,
    SceneTypePiano
} SceneType;

// Command Type enumeration
typedef NS_ENUM(NSInteger, CommandType) {
    CommandGetDeviceInfo = 1,
    CommandResetDeviceInfo,
    CommandUpdateFW,
    CommandSetEQ,
    CommandSetVolume,
    CommandSetScene,
    CommandSetEQStatus,
    CommandGetEQStatus,
    CommandGetSoundEffectStatus,
    CommandSetDrcStatus,
    CommandSetSoundEffectStatus,
    CommandSetSoundEffect,
    CommandResetSoundEffect,
    CommandRegisterDocAndDsp,
    CommandSaveSetting,
    CommandInitSavedInfo,
    CommandTypeSetLimit,
    
    CommandDoDinControlHigh,
    CommandDoDinControlLow,
    
    CommandGetFMIntStatus,
    CommandGetFMIntStatusRead,
    
    CommandGetFMTuneStatus,
    CommandGetFMTuneStatusRead,
    
    CommandGetFMRsqStatus,
    CommandGetFMRsqStatusRead,
    
    CommandSetFMPowerUp,
    CommandSetFMPowerUpRead,
    
    CommandSetFMPowerDown,
    CommandSetFMPowerDownRead,
    
    CommandFMSeekStart,
    CommandFMSeekStartRead,
    
    CommandSetFMTuneFreq,
    CommandSetFMTuneFreqRead,
    
    CommandGetRevision,
    CommandGetRevisionRead,
    
    CommandSetDigitalOutputSampleRate,
    CommandSetDigitalOutputSampleRateRead,
    
    CommandSetDigitalOutputFormat,
    CommandSetDigitalOutputFormatRead,
    
    CommandSetGpoIen,
    CommandSetGpoIenRead,
    
    CommandSetRefclkFreq,
    CommandSetRefclkFreqRead,
    
    CommandSetRefclkPrescale,
    CommandSetRefclkPrescaleRead,
    
    CommandSetRxVolume,
    CommandSetRxVolumeRead,
    
    CommandSetFMDeemphasis,
    CommandSetFMDeemphasisRead,
    
    CommandSetFMHardMute,
    CommandSetFMHardMuteRead,
    
    CommandSetFMBlendRssiStereoThreshold,
    CommandSetFMBlendRssiStereoThresholdRead,
    
    CommandSetFMBlendRssiMonoThreshold,
    CommandSetFMBlendRssiMonoThresholdRead,
    
    CommandSetFMMaxTuneError,
    CommandSetFMMaxTuneErrorRead,
    
    CommandSetFMRsqIntSource,
    CommandSetFMRsqIntSourceRead,
    
    CommandSetFMRsqSnrHiThreshold,
    CommandSetFMRsqSnrHiThresholdRead,
    
    CommandSetFMRsqSnrLoThreshold,
    CommandSetFMRsqSnrLoThresholdRead,
    
    CommandSetFMRsqBlendThreshold,
    CommandSetFMRsqBlendThresholdRead,
    
    CommandSetFMSoftMuteMaxAttenuation,
    CommandSetFMSoftMuteMaxAttenuationRead,
    
    CommandSetFMSoftMuteSnrThreshold,
    CommandSetFMSoftMuteSnrThresholdRead,
    
    CommandSetFMSeekBandBottom,
    CommandSetFMSeekBandBottomRead,
    
    CommandSetFMSeekBandTop,
    CommandSetFMSeekBandTopRead,
    
    CommandSetFMSeekFreqSpacing,
    CommandSetFMSeekFreqSpacingRead,
    
    CommandSetFMSeekTuneSnrThreshold,
    CommandSetFMSeekTuneSnrThresholdRead,
    
    CommandSetFMSeekTuneRssiThreshold,
    CommandSetFMSeekTuneRssiThresholdRead,
    
    CommandSetFMRdsIntSource,
    CommandSetFMRdsIntSourceRead,
    
    CommandSetFMRdsIntFifoCount,
    CommandSetFMRdsIntFifoCountRead,
    
    CommandSetFMRdsConfig,
    CommandSetFMRdsConfigRead,
    
    CommandGetFMRdsStatus,
    CommandGetFMRdsStatusRead
};

static Byte const LAM_POWER_UP = 0x01;
static Byte const LAM_POWER_DOWN = 0x11;
static Byte const LAM_SET_PROPERTY = 0x12;
static Byte const LAM_FM_TUNE_FREQ = 0x20;
static Byte const LAM_GET_INT_STATUS = 0x14;

/* FM_TUNE_STATUS */
static Byte const LAM_FM_TUNE_STATUS = 0x22;
static Byte const LAM_FM_TUNE_STATUS_IN_INTACK = 0x01;
static Byte const LAM_FM_TUNE_STATUS_IN_CANCEL = 0x02;
static Byte const LAM_FM_TUNE_STATUS_OUT_VALID = 0x01;
static Byte const LAM_FM_TUNE_STATUS_OUT_AFCRL = 0x02;
static Byte const LAM_FM_TUNE_STATUS_OUT_BTLF = 0x80;

/* FM_RSQ_STATUS */
static Byte const LAM_FM_RSQ_STATUS = 0x23;

/* FM_SEEK_START */
static Byte const LAM_FM_SEEK_START = 0x21;
static Byte const LAM_FM_SEEK_START_IN_WRAP = 0x04;
static Byte const LAM_FM_SEEK_START_IN_SEEKUP = 0x08;

#endif /* FMEarphoneCommandDefines_h */
