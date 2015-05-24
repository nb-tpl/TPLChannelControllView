//
//  ChannelVideoPlayerView.h
//  BoBoBox
//
//  Created by 谭鄱仑 on 15-1-26.
//  Copyright (c) 2015年 zhubo. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SHPlayerControlCenter.h"

@class BoBoVideoEntity;
@interface ChannelVideoPlayerView : UIImageView


//@property(nonatomic,strong)SHPlayerControlCenter * player;


@property(nonatomic,strong)UIColor * timeProgressColor;



//重置播放列表
-(void)resetVideoList:(NSArray*)videoList;
//添加播放列表
-(void)addVideoList:(NSArray*)videoList;

-(BoBoVideoEntity*)getCurrentVideoEntity;


//控制
//暂停
-(void)pause;
//播放第几个
- (void)playIndex:(int)index;


@end
