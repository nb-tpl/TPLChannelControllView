//
//  ChannelViewController.m
//  BoBoBox
//
//  Created by zhubo on 15-1-7.
//  Copyright (c) 2015年 zhubo. All rights reserved.
//

#import "ChannelControlViewController.h"
#import "ChannelViewController.h"
#import "BoBoNavigationBar.h"
#import "HomeViewController.h"
#import "BoBoFullPlayerViewcontroller.h"
#import "ChannelControlView.h"

@interface ChannelControlViewController (){
    BoBoNavigationBar *navBar;
    HomeViewController *homeVC;
    ChannelControlView * _channelControllView;
    
    BoBoFullPlayerViewcontroller * _fullPlayVC;
}

@end

@implementation ChannelControlViewController


-(void)dealloc
{
    [_channelControllView.headBackImageView removeObserver:self forKeyPath:@"backgroundColor" context:nil];
    [_channelControllView removeObserver:self forKeyPath:@"beforeIndex" context:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    UIViewController * firstVC = _channelControllView.viewControllersArray.firstObject;
    [firstVC viewDidAppear:NO];
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildComponent];
}

-(void)buildComponent{
    
    
    
    navBar = [[BoBoNavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, navHeight)];
    navBar.titleLabel.text = @"视频联播";
    navBar.titleLabel.textColor = [UIColor whiteColor];
//    navBar.backgroundColor = [UIColor blueColor];
    navBar.leftButton.backgroundColor = [UIColor clearColor];
    navBar.rightButton.hidden = YES;
    [navBar.leftButton setBackgroundImage:[UIImage imageNamed:@"btn_titlebar_home_lianbo_default.png"] forState:UIControlStateNormal];
    [navBar.leftButton setBackgroundImage:[UIImage imageNamed:@"btn_titlebar_home_lianbo_focused.png"] forState:UIControlStateHighlighted];
    [navBar.leftButton setBackgroundImage:[UIImage imageNamed:@"btn_titlebar_home_lianbo_focused.png"] forState:UIControlStateSelected];
    
    [navBar.leftButton addTarget:self action:@selector(toHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBar];
    
    
    
    /* tpl  实验 */
    _channelControllView = [[ChannelControlView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, self.view.frame.size.height - navHeight)];
    [self.view addSubview:_channelControllView];
    _channelControllView.synchro = NO;
//    _channelControllView.headBackImageView.alpha = 0.8;
    
    NSMutableArray * viewControllers = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * colorsArray = [[NSMutableArray alloc] initWithObjects:[TPLHelpTool getHexColor:@"#23b9b3"],[TPLHelpTool getHexColor:@"#fc6e51"],[TPLHelpTool getHexColor:@"#75b92b"],[TPLHelpTool getHexColor:@"29b3e3"],[TPLHelpTool getHexColor:@"#ed5565"], nil];
    NSMutableArray * titlesArray =  [@[@"娱乐热点",@"轻松时刻",@"感人创意",@"运动奇趣",@"MV"] mutableCopy];
//    NSMutableArray * titlesArray =  [@[@"漫画",@"热点",@"最新"] mutableCopy];

    for (int i = 0; i < 5; i++)
    {
        ChannelViewController * vc = [[ChannelViewController alloc] init];
        vc.channelTag = i + 1;
        vc.channelColor = [colorsArray objectAtIndex:i];
        vc.title = [titlesArray objectAtIndex:i];
        [viewControllers addObject:vc];
//        vc.view.backgroundColor = [TPLHelpTool getRandomColor];
    }
    
    _channelControllView.viewControllersArray = viewControllers;
    _channelControllView.headBackColorsArray = colorsArray;
    _channelControllView.titlesArray = titlesArray;
    
    //获得头背景色
    [_channelControllView.headBackImageView addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];
    [_channelControllView addObserver:self forKeyPath:@"beforeIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    navBar.backgroundColor = _channelControllView.headBackImageView.backgroundColor;
    /* tpl  实验 */

}


/* KVO function， 只要object的keyPath属性发生变化，就会调用此函数*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"backgroundColor"] && object == _channelControllView.headBackImageView)
    {
        navBar.backgroundColor = _channelControllView.headBackImageView.backgroundColor;
    }
    else if ([keyPath isEqualToString:@"beforeIndex"])//暂停之前的
    {
        int old = [[change objectForKey:@"old"] intValue];
        ChannelViewController * channelVC = (ChannelViewController*)[_channelControllView.viewControllersArray objectAtIndex:old];
        [channelVC.playerView pause];
        
        [BoBoStatisticsModel statisticsForEndTime:EVENT_CHANNEL_DURING label:[channelVC getStatisticsString]];
    }
}

#pragma mark 屏幕旋转

-(BOOL)shouldAutorotate
{
    return [self canAutorotated];
}

- (BOOL)canAutorotated{
    //视频在播放，但playbackStatus=SHPlayerPlaybackStatusReady
    SHPlayerControlCenter * player = [(ChannelViewController*)[_channelControllView.viewControllersArray objectAtIndex:_channelControllView.currentIndex] playerView].player;
    
    if ([player inParentViewForPlayerView]&&(player.playbackStatus == SHPlayerPlaybackStatusReady||player.playbackStatus == SHPlayerPlaybackStatusPlaying)) {
        return YES;
    }
    else
        return NO;
}


-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"横屏");
        [self showFullPlayerView];
        
    }else{
        NSLog(@"竖屏================");
        [self exitFullPlayerView];
    }

}


#pragma mark 全屏播放器

//进入全屏播放器
-(void)showFullPlayerView{
    
    SHPlayerControlCenter * player = [self getCurrentPlayer];
    ChannelVideoPlayerView * playView = [(ChannelViewController*)[_channelControllView.viewControllersArray objectAtIndex:_channelControllView.currentIndex] playerView];
    [UIView animateWithDuration:0.2f animations:^{
        NSLog(@"show");
        
        if(!_fullPlayVC){
            _fullPlayVC = [[BoBoFullPlayerViewcontroller alloc] init];
        }
        [player removeFromParentViewForPlayerView];
        [_fullPlayVC.view removeFromSuperview];
        [player settingVideoViewFrame:CGRectMake(0,0,SCREENWIDTH, SCREENHEIGHT) addParentView:_fullPlayVC.view];
        _fullPlayVC.proViewController = 1;
        [_fullPlayVC settingPlayer:player WithVideoEntity:[playView getCurrentVideoEntity]];
        [self.view addSubview:_fullPlayVC.view];
    }];
}

//退出全屏播放器
-(void)exitFullPlayerView{
    
    NSLog(@"exit");
//    SHPlayerControlCenter * player = [self getCurrentPlayer];
    __block ChannelVideoPlayerView * playView = [(ChannelViewController*)[_channelControllView.viewControllersArray objectAtIndex:_channelControllView.currentIndex] playerView];

    if(playView.player && _fullPlayVC){
        [UIView animateWithDuration:0.2f animations:^{
            [_fullPlayVC.fullPlayer removeFromParentViewForPlayerView];
            [_fullPlayVC.view removeFromSuperview];
//            [self updataCurrentCellUI];
            playView.player = _fullPlayVC.fullPlayer;
//            [playView.player settingVideoViewFrame:CGRectMake(0, 0,playView.bounds.size.width,playView.bounds.size.height) addParentView:playView];
//            [currentVC resetFromFullPlayer];
//            [currentVC.currentCell.cellVideoView updateUIForProgress:fullPlayVC.fullPlayer.currentPlayItem.mediaLastPlayTime];
            _fullPlayVC.fullPlayer = nil;
            _fullPlayVC.fullPlayer.delegate = nil;
            _fullPlayVC = nil;
        }];
    }
}


#pragma mark
#pragma mark           help
#pragma mark
-(SHPlayerControlCenter*)getCurrentPlayer
{
    return [(ChannelViewController*)[_channelControllView.viewControllersArray objectAtIndex:_channelControllView.currentIndex] playerView].player;
}

#pragma mark 导航按钮事件

-(void)toHome:(UIButton *)sender{
   
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
