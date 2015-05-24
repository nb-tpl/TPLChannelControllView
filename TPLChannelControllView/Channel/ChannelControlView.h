//
//  ChannelControlView.h
//  BoBoBox
//
//  Created by 谭鄱仑 on 15-1-20.
//  Copyright (c) 2015年 zhubo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelControlView : UIView

//视图
@property(nonatomic,readonly)UIImageView * headBackImageView;

//数据
@property(nonatomic,strong)NSMutableArray * titlesArray;
@property(nonatomic,strong)NSMutableArray * viewControllersArray;//每次滑到对应视图控制器会调用viewDidAppear，参数为NO
@property(nonatomic,strong)NSMutableArray * headBackColorsArray;

//选中颜色
@property(nonatomic,strong)UIColor * titleSelectColor;
//正常颜色
@property(nonatomic,strong)UIColor * titleNormalColor;
//选中下标颜色
@property(nonatomic,strong)UIColor * titleSelectBottomLineColor;
//标题字体
@property(nonatomic,strong)UIFont * titleFont;

@property(nonatomic,assign)int currentIndex;
@property(nonatomic,assign)int beforeIndex;


//样式
//是否需要上下同步，默认为YES
@property(nonatomic,assign)BOOL synchro;
//是否需要滚动完毕后自动适配
@property(nonatomic,assign)BOOL fitTitleAlways;
//调整时切换是否需要动画
@property(nonatomic,assign)BOOL needAnimation;





//添加视图方法
//-(void)addViewController:(UIViewController*)viewController withTitle:(NSString*)title color:(UIColor*)color;
//-(void)addViewControllers:(NSArray*)viewcontrollers withTitles:(NSArray*)titles colors:(NSArray*)colors;
//-(void)addViewControllersAndTitlesFromDict:(NSDictionary*)dict;


@end
