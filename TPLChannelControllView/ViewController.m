//
//  ViewController.m
//  TPLChannelControllView
//
//  Created by 谭鄱仑 on 15-2-5.
//  Copyright (c) 2015年 谭鄱仑. All rights reserved.
//

#import "ViewController.h"

//#import "ChannelViewController.h"
#import "TestViewController.h"
#import "ChannelControlView.h"

#import "TPLHelpTool.h"

@interface ViewController ()
{
    ChannelControlView * _channelControllView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    _channelControllView = [[ChannelControlView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 44)];
    [self.view addSubview:_channelControllView];
    _channelControllView.synchro = NO;
    _channelControllView.needAnimation = NO;
    _channelControllView.fitTitleAlways = YES;
    //    _channelControllView.headBackImageView.alpha = 0.8;
    
    NSMutableArray * viewControllers = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * colorsArray = [[NSMutableArray alloc] initWithObjects:[TPLHelpTool getHexColor:@"#23b9b3"],[TPLHelpTool getHexColor:@"#fc6e51"],[TPLHelpTool getHexColor:@"#75b92b"],[TPLHelpTool getHexColor:@"29b3e3"],[TPLHelpTool getHexColor:@"#ed5565"], nil];
    NSMutableArray * titlesArray =  [@[@"娱乐热点",@"轻松时刻",@"感人创意",@"运动奇趣",@"MV"] mutableCopy];
    //    NSMutableArray * titlesArray =  [@[@"漫画",@"热点",@"最新"] mutableCopy];
    
    for (int i = 0; i < 5; i++)
    {
        TestViewController * vc = [[TestViewController alloc] init];
//        vc.channelTag = i + 1;
//        vc.channelColor = [colorsArray objectAtIndex:i];
//        vc.title = [titlesArray objectAtIndex:i];
        vc.view.backgroundColor = [TPLHelpTool getRandomColor];
        [viewControllers addObject:vc];
        //        vc.view.backgroundColor = [TPLHelpTool getRandomColor];
    }
    
    _channelControllView.viewControllersArray = viewControllers;
    _channelControllView.headBackColorsArray = colorsArray;
    _channelControllView.titlesArray = titlesArray;
    
//    //获得头背景色
//    [_channelControllView.headBackImageView addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];
//    [_channelControllView addObserver:self forKeyPath:@"beforeIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//    navBar.backgroundColor = _channelControllView.headBackImageView.backgroundColor;
    /* tpl  实验 */

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
