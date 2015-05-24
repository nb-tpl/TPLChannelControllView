//
//  ChannelViewController.h
//  波波二期联播界面实验
//
//  Created by 谭鄱仑 on 15-1-15.
//  Copyright (c) 2015年 谭鄱仑. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelVideoPlayerView.h"

@interface ChannelViewController : UIViewController


//默认为1
@property(nonatomic,assign)NSInteger channelTag;
@property(nonatomic,strong)UIColor * channelColor;

@property(nonatomic,readonly)ChannelVideoPlayerView * playerView;


-(NSString*)getStatisticsString;

@end
