//
//  DBAudioMicrophone.h
//  Studing1.0
//
//  Created by ByteDance on 2023/6/24.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBAudioMicrophone;
@protocol DBAudioMicrophoneDelegate <NSObject>
@optional
- (void)audioMicrophone:(DBAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize;

- (void)audioCallBackVoiceGrade:(NSInteger)grade;

@end

@interface DBAudioMicrophone : NSObject
// 录音器，audioQueue的方式驱动
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) AudioStreamBasicDescription audioDescription; //音频输出参数
@property (nonatomic, copy) void(^configAudioSession)(AVAudioSession *audioSession);
@property (nonatomic, weak) id <DBAudioMicrophoneDelegate> delegate;

- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel configAudioSession:(void (^_Nullable)(AVAudioSession *audioSesson))sessionConfig;
- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel;
- (instancetype)initWithSampleRate:(NSInteger)sampleRate;

- (void)start;
- (void)stop;
- (void)pause;
@end

NS_ASSUME_NONNULL_END
