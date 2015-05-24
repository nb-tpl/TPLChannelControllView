//
//  ChannelVideoPlayerView.m
//  BoBoBox
//
//  Created by 谭鄱仑 on 15-1-26.
//  Copyright (c) 2015年 zhubo. All rights reserved.
//

#import "ChannelVideoPlayerView.h"

//#import "UIImageView+WebCache.h"

//#import "SHMediaBase.h"
//#import "BoBoVideoEntity.h"

@interface ChannelVideoPlayerView ()<SHPlayerControlCenterDelegate>
{
//view
    UIButton * _playButton;
    UILabel * _totalTimeLabel;
    UILabel * _titleLabel;
    UIView * _timeProgressView;
    UIActivityIndicatorView * _activityView;
//data
    NSMutableArray * _videoList;
//辅助
    int _curretnVideoIndex;
}

@end

@implementation ChannelVideoPlayerView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark
#pragma mark           property
#pragma mark
-(void)setTimeProgressColor:(UIColor *)timeProgressColor
{
    _timeProgressColor = timeProgressColor;
    _timeProgressView.backgroundColor = _timeProgressColor;
}

-(void)setPlayer:(SHPlayerControlCenter *)player
{
    _player = player;
    _player.delegate = self;
    [_player settingVideoViewFrame:self.bounds addParentView:self];
}

-(BoBoVideoEntity*)getCurrentVideoEntity
{
    return [_videoList objectAtIndex:_curretnVideoIndex];
}

#pragma mark
#pragma mark           init
#pragma mark
-(void)initBaseData
{
    _videoList = [[NSMutableArray alloc] initWithCapacity:0];
    _curretnVideoIndex = 0;
}
-(void)initUI
{
    //播放器
    self.player =[SHPlayerControlCenter new];
    _player.delegate = self;
    [_player settingVideoViewFrame:self.bounds addParentView:self];
    [_player removeAllMediaOfPlayList];
    
    //播放按钮
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake((self.frame.size.width - 70)/2, (self.frame.size.height - 70)/2, 70, 70);
    [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    
    
    //标题
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 5 - 30, self.frame.size.width, 30)];
    UIImageView * titleBackImageView = [[UIImageView alloc] initWithFrame:_titleLabel.frame];
    titleBackImageView.image = [UIImage imageNamed:@"bg_video_title.png"];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x + 12, _titleLabel.frame.origin.y, _titleLabel.frame.size.width - 12*2, _titleLabel.frame.size.height);
    [self addSubview:titleBackImageView];
    [self addSubview:_titleLabel];
    
    
    //加载进度条
    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:_playButton.frame];
    _activityView.color = _timeProgressColor;
    [self addSubview:_activityView];
    _activityView.hidden = YES;
    
    //时间展示Label
    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 0, 50, 25)];
    _totalTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    _totalTimeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _totalTimeLabel.textColor = [UIColor whiteColor];
    _totalTimeLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_totalTimeLabel];
    //时间进度条
    _timeProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 5, 0, 5)];
    UIView * timeProgressBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 5, self.frame.size.width, 5)];
    timeProgressBackView.backgroundColor = [UIColor blackColor];
    _timeProgressView.backgroundColor = _timeProgressColor;
    [self addSubview:timeProgressBackView];
    [self addSubview:_timeProgressView];
}
//添加手势
-(void)addGestureRecognizer
{
    UITapGestureRecognizer * tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOne:)];
    tapOne.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer * tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTwice:)];
    tapTwice.numberOfTapsRequired = 2;

    [tapOne requireGestureRecognizerToFail:tapTwice];
    [self addGestureRecognizer:tapOne];
    [self addGestureRecognizer:tapTwice];

}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        [self initBaseData];
        [self initUI];
        [self addGestureRecognizer];
//        self.backgroundColor = [UIColor greenColor];
        self.image = [UIImage imageNamed:@"bg_default_img_640x360.png"];
    }
    return self;
}


//重置播放列表
-(void)resetVideoList:(NSArray*)videoList
{
    [_videoList removeAllObjects];
    [_videoList addObjectsFromArray:videoList];
    _curretnVideoIndex = 0;
    [self setImageWithURL:[NSURL URLWithString:[(BoBoVideoEntity*)_videoList.firstObject videoCoverImageUrl]]];
    _totalTimeLabel.text = [IFUtils integerToString:[(BoBoVideoEntity*)[_videoList objectAtIndex:_curretnVideoIndex] videoPlayTimeTotal]];
    _titleLabel.text = [(BoBoVideoEntity*)[_videoList objectAtIndex:_curretnVideoIndex] videoTitle];

}
//增加播放列表
-(void)addVideoList:(NSArray*)videoList
{
    [_videoList addObjectsFromArray:videoList];
}


- (void)playIndex:(int)index
{
    if (_videoList.count > index)
    {
        BoBoVideoEntity * entity = [_videoList objectAtIndex:index];
        [self setImageWithURL:[NSURL URLWithString:entity.videoCoverImageUrl]];
        _titleLabel.text = entity.videoTitle;
        _totalTimeLabel.text = [IFUtils integerToString:entity.videoPlayTimeTotal];
        _timeProgressView.frame = CGRectMake(0, self.frame.size.height - 5, 0, 5);
        _activityView.hidden = NO;
        _playButton.hidden = YES;
        [_activityView startAnimating];
        
        
        //设置播放项
        SHMediaBase *playItem = [self createMediaBaseByVideoEntity:entity];
        if (playItem)
        {
            _curretnVideoIndex = index;
            [_player removeAllMediaOfPlayList];
            [_player addMediaToPlayList:playItem];
            [_player start];
        }
    }
}




#pragma mark
#pragma mark           contro player(控制播放)
#pragma mark
-(void)pause
{
    if (_playButton.hidden)
    {
        [_player pause];
        _playButton.hidden = NO;
        _titleLabel.hidden = NO;
    }
}


#pragma mark
#pragma mark           clicked(点击事件)
#pragma mark

-(void)playButtonClicked:(id)sender
{
    if (_videoList.count > 0)
    {
        if (_player.playList.count == 0)
        {
            [self playIndex:0];
        }
        else
        {
            [_player play];
        }
        _playButton.hidden = YES;
    }
    else//没有推荐视频
    {
    }
}

-(void)tapOne:(UITapGestureRecognizer*)tapOne
{
    if (_playButton.hidden && (_player.playbackStatus == SHPlayerPlaybackStatusPlaying || _player.playbackStatus == SHPlayerPlaybackStatusReady))
    {
        [_player pause];
        _playButton.hidden = NO;
        _titleLabel.hidden = NO;
        [_activityView stopAnimating];
        _activityView.hidden = YES;
    }
}

-(void)tapTwice:(UITapGestureRecognizer*)tapTwice
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        if ([[UIDevice currentDevice] orientation] != UIInterfaceOrientationPortrait)
        {
            val = UIInterfaceOrientationPortrait;
        }
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark
#pragma mark           help
#pragma mark

-(SHMediaBase*)createMediaBaseByVideoEntity:(BoBoVideoEntity*)entity
{
    SHMediaBase *playItem = [SHMediaBase new];
    playItem.mediaID = entity.videoId;
    playItem.mediaTotalTime = entity.videoPlayTimeTotal;
    playItem.mediaPlayTitle = entity.videoTitle;
    playItem.mediaCoverImage = entity.videoCoverImageUrl;
    //    playItem.mediaIsAttention = [[BoBoCDModel model] isFavor:cell.cellVideoEntity.videoId];
    playItem.mediaClassId = entity.classId;
    playItem.mediaTagId =entity.tagId;
    
    if (playItem.mediaIsAttention) {
        NSLog(@"111111111111111111111111");
    }
    else{
        NSLog(@"000000000000000000000000000");
    }
    //播放地址
    if ([entity.videoPlayUrl isKindOfClass:[NSString class]]) {
        if ([entity.videoPlayUrl indexOf:@"http://"]>0 && [entity.videoPlayUrl indexOf:@".mp4"]>0) {
            playItem.mediaPlayUrl = entity.videoPlayUrl;
        }
    }
    else{
        NSString *play_url_350 = [entity getVideoPlayUrlByRateKey:FPVideoEntity_VideoPlayUrl_RateKey_350];
        NSString *play_url_550 = [entity getVideoPlayUrlByRateKey:FPVideoEntity_VideoPlayUrl_RateKey_550];
        
        if (play_url_350 && play_url_350.length >0 && [play_url_350 indexOf:@"http://"]>0 && [play_url_350 indexOf:@".mp4"]>0) {
            playItem.mediaPlayUrl = play_url_350;
        }else if (play_url_550 && play_url_550.length >0 && [play_url_550 indexOf:@"http://"]>0 && [play_url_350 indexOf:@".mp4"]>0) {
            playItem.mediaPlayUrl = play_url_550;
        }else{
            //            [self MBProgressHUDPopUpMessage:@"正在加载超清视频，请耐心等待..." withTimeInterval:1.5f];
            NSLog(@"需要提示");
        }
    }
    return playItem;
}

#pragma mark
#pragma mark           SHPlayerControlCenterDelegate
#pragma mark

//播放状态改变
- (void)mediaPlayerPlaybackStatusDidChanged:(SHPlayerControlCenter *)mediaPlayer
{
    switch (mediaPlayer.playbackStatus)
    {
        case SHPlayerPlaybackStatusPlaying:
            [_activityView stopAnimating];
            _activityView.hidden = YES;
            _titleLabel.hidden = YES;
            break;
        case SHPlayerPlaybackStatusLoading:
            
            break;
            
            
        default:
            break;
    }
}
//播放器操作事件改变
- (void)mediaPlayerOperationEventDidChanged:(SHPlayerControlCenter *)mediaPlayer
{
    
}

//播放结束
- (void)mediaPlayerPlaybackDidEnd:(SHPlayerControlCenter *)mediaPlayer
{
    if (_videoList.count > _curretnVideoIndex + 1)
    {
        [self playIndex:_curretnVideoIndex+1];
    }
    else if (_curretnVideoIndex == _videoList.count - 1)
    {
        [self playIndex:0];
    }
}

//播放结束时失败
- (void)mediaPlayerPlaybackFailedDidEnd:(SHPlayerControlCenter *)mediaPlayer
{
    
}

//播放进度
- (void)mediaPlayerPlaybackProgress:(double)progressTime WithController:(SHPlayerControlCenter *)mediaPlayer
{
    BoBoVideoEntity * entity = [_videoList objectAtIndex:_curretnVideoIndex];
    CGFloat ratio = progressTime / (entity.videoPlayTimeTotal - 1);
    NSLog(@"ratio = %f",ratio);
    _timeProgressView.frame = CGRectMake(_timeProgressView.frame.origin.x, _timeProgressView.frame.origin.y, ratio*self.frame.size.width, _timeProgressView.frame.size.height);
}

@end
