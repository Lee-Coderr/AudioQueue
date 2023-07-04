//
//  AudioViewController.m
//  Studing1.0
//
//  Created by admin on 2022/3/17.
//

#import "AudioViewController.h"
#import "AWEHeaderFile.h"
#import "DBAudioMicrophone.h"
#import "DBPCMDataPlayer.h"

@interface AudioViewController () <DBAudioMicrophoneDelegate, DBPCMPlayDelegate>

@property (nonatomic, strong) DBAudioMicrophone *audioMicrophone;
@property (nonatomic, strong) DBPCMDataPlayer *pcmPlayer;
@property (nonatomic, strong) NSFileHandle *writeFileHandle;
@property (nonatomic, strong) NSFileHandle *readFileHandle;

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_setupUI];
    [self p_setupAudioMicrophone];
}

- (void)dealloc
{
    [_writeFileHandle closeFile];
    [_readFileHandle closeFile];
    _writeFileHandle = nil;
    _readFileHandle = nil;
}

- (void)p_setupUI
{
    UILabel *recordLabel = [[UILabel alloc] init];
    UIButton *recordBtn = [[UIButton alloc] init];
    UIButton *recordStopBtn = [[UIButton alloc] init];
    { // recorder ui
        recordLabel.text = @"录制";
        [recordLabel sizeToFit];
        [recordBtn setImage:[UIImage imageNamed:@"playIcon"] forState:UIControlStateNormal];
        [recordBtn setImage:[UIImage imageNamed:@"pauseIcon"] forState:UIControlStateSelected];
        @weakify(self);@weakify(recordBtn);
        [recordBtn awe_addSingleTapRecognizerWithBlock:^(UITapGestureRecognizer * _Nonnull sender) {
            @strongify(self);@strongify(recordBtn);
            recordBtn.selected = !recordBtn.selected;
            if (recordBtn.selected) {
                [self startRecord];
            } else {
                [self stopRecord];
            }
        }];
        [recordStopBtn setImage:[UIImage imageNamed:@"stopIcon"] forState:UIControlStateNormal];
        [recordStopBtn awe_addSingleTapRecognizerWithBlock:^(id  _Nonnull sender) {
            @strongify(self);@strongify(recordBtn);
            recordBtn.selected = NO;
            [self stopRecord];
        }];
    }
    
    UILabel *playbackLabel = [[UILabel alloc] init];
    UIButton *playbackBtn = [[UIButton alloc] init];
    UIButton *playbackStopBtn = [[UIButton alloc] init];
    { // playback ui
        playbackLabel.text = @"播放";
        [playbackLabel sizeToFit];
        [playbackBtn setImage:[UIImage imageNamed:@"playIcon"] forState:UIControlStateNormal];
        [playbackBtn setImage:[UIImage imageNamed:@"pauseIcon"] forState:UIControlStateSelected];
        @weakify(self);@weakify(playbackBtn);
        [playbackBtn awe_addSingleTapRecognizerWithBlock:^(id  _Nonnull sender) {
            @strongify(self);@strongify(playbackBtn);
            playbackBtn.selected = !playbackBtn.selected;
            if (playbackBtn.selected) {
                [self startPlay];
            } else {
                [self pausePlay];
            }
        }];
        [playbackStopBtn setImage:[UIImage imageNamed:@"stopIcon"] forState:UIControlStateNormal];
        [playbackStopBtn awe_addSingleTapRecognizerWithBlock:^(id  _Nonnull sender) {
            @strongify(self);@strongify(playbackBtn);
            playbackBtn.selected = NO;
            [self stopPlay];
        }];
    }
    
    { // layout
        UIView *container = [UIView new];
        container.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [self.view addSubview:container];
        [container addSubview:recordLabel];
        [container addSubview:recordBtn];
        [container addSubview:recordStopBtn];
        [container addSubview:playbackLabel];
        [container addSubview:playbackBtn];
        [container addSubview:playbackStopBtn];
        NSInteger iconWidth = 50;
        AWEMasMaker(container, {
            make.center.equalTo(self.view);
        })
        AWEMasMaker(recordLabel, {
            make.left.top.equalTo(container);
        })
        AWEMasMaker(recordBtn, {
            make.left.equalTo(recordLabel.mas_right).offset(50);
            make.centerY.equalTo(recordLabel);
            make.top.equalTo(container);
            make.size.equalTo(@(CGSizeMake(iconWidth, iconWidth)));
        })
        AWEMasMaker(recordStopBtn, {
            make.size.centerY.equalTo(recordBtn);
            make.left.equalTo(recordBtn.mas_right).offset(10);
            make.right.equalTo(container);
        })
        
        AWEMasMaker(playbackLabel, {
            make.top.equalTo(recordLabel.mas_bottom).offset(50);
            make.left.bottom.equalTo(container);
        })
        AWEMasMaker(playbackBtn, {
            make.left.equalTo(playbackLabel.mas_right).offset(50);
            make.bottom.equalTo(container);
            make.size.equalTo(@(CGSizeMake(iconWidth, iconWidth)));
        })
        AWEMasMaker(playbackStopBtn, {
            make.size.centerY.equalTo(playbackBtn);
            make.left.equalTo(playbackBtn.mas_right).offset(10);
            make.right.equalTo(container);
        })
    }
}

#pragma mark - Audio Microphone

- (void)p_setupAudioMicrophone
{
    self.audioMicrophone = [[DBAudioMicrophone alloc] initWithSampleRate:44100 numerOfChannel:2];
    self.audioMicrophone.delegate = self;
}

- (void)startRecord
{
    NSLog(@"startRecord");
    [self.audioMicrophone start];
}

- (void)pauseRecord
{
    NSLog(@"pauseRecord");
    [self.audioMicrophone pause];
}

- (void)stopRecord
{
    NSLog(@"stopRecord");
    [self.audioMicrophone stop];
}

/// DBAudioMicrophoneDelegate
- (void)audioMicrophone:(DBAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize
{
    NSLog(@"audioByteSize = %@", @(byteSize));
    [self.writeFileHandle writeData:[NSData dataWithBytes:pcmByte length:byteSize]];
    
}

- (void)audioCallBackVoiceGrade:(NSInteger)grade
{
    NSLog(@"VoiceGrade = %@", @(grade));
}

#pragma mark - Audio Playback

- (void)readPCMAudioFile
{
    if (self.pcmPlayer.readyToPlay) {
        return;
    }
    
    [self.writeFileHandle seekToFileOffset:0];
    NSError *error;
    NSData *data = [self.readFileHandle readDataToEndOfFileAndReturnError:&error];
    [self.pcmPlayer appendData:data totalDatalength:data.length endFlag:YES];
}

- (void)startPlay
{
    NSLog(@"startPlay");
    [self readPCMAudioFile];
    [self.pcmPlayer startPlay];
}

- (void)pausePlay
{
    NSLog(@"pausePlay");
    [self.pcmPlayer pausePlay];
}

- (void)stopPlay
{
    NSLog(@"stopPlay");
    [self.pcmPlayer stopPlay];
}

/// 准备好了，可以开始播放了，回调
- (void)readlyToPlay
{
    NSLog(@"readlyToPlay, length=%@", @(self.pcmPlayer.audioLength));
}

/// 播放完成回调
- (void)playFinished
{
    NSLog(@"playFinished");
}

/// 播放暂停回调
- (void)playPausedIfNeed
{
    NSLog(@"playPausedIfNeed");
}

/// 播放开始回调
- (void)playResumeIfNeed
{
    NSLog(@"playResumeIfNeed");
}

///更新buffer的位置回调
-  (void)updateBufferPositon:(float)bufferPosition
{
    NSLog(@"updateBufferPositon=%@", @(bufferPosition));
}

/// 播放错误的回调
- (void)playerCallBackFaiure:(NSString *)errorStr
{
    NSLog(@"playerCallBackFaiure=%@", errorStr);
}

- (DBPCMDataPlayer *)pcmPlayer
{
    if (!_pcmPlayer) {
        _pcmPlayer = [[DBPCMDataPlayer alloc] initWithType:@""];
        _pcmPlayer.delegate = self;
    }
    return _pcmPlayer;
}

- (NSFileHandle *)writeFileHandle {
    if (!_writeFileHandle) {
        NSString *audioPath = [self audioPath];
        NSLog(@"PCM file path: %@", audioPath);
        [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:audioPath contents:nil attributes:nil];
        _writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:audioPath];
    }
    return _writeFileHandle;
}

- (NSFileHandle *)readFileHandle
{
    if (!_readFileHandle) {
        NSString *audioPath = [self audioPath];
        NSLog(@"PCM file path: %@", audioPath);
        _readFileHandle = [NSFileHandle fileHandleForReadingAtPath:audioPath];
    }
    return _readFileHandle;
}

- (NSString *)audioPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.pcm"];
}

@end
