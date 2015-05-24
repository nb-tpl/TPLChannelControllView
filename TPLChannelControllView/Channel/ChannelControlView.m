//
//  ChannelControlView.m
//  BoBoBox
//
//  Created by 谭鄱仑 on 15-1-20.
//  Copyright (c) 2015年 zhubo. All rights reserved.
//

#import "ChannelControlView.h"

//默认变量
//默认频道导航高度
#define default_headBackHeight 30
//字体默认
#define default_titleFont  [UIFont systemFontOfSize:15]
//中间白条标志宽度
#define default_titleBottomLineWidth self.frame.size.width/4
//头标记线颜色
#define default_titleBottomLineColor [UIColor whiteColor]
//头部默认背景颜色
#define default_headBackViewColor [UIColor yellowColor]


#define default_titleSelectColor [UIColor colorWithRed:255.0 green:255.0f blue:255.0f alpha:1.0f]
#define default_titleNormalColor [UIColor colorWithRed:255.0 green:255.0f blue:255.0f alpha:0.5f]





@interface ChannelControlView ()<UIScrollViewDelegate>
{
//视图
    //头部背景视图
    UIImageView * _headBackImageView;
    //头部滚动视图
    UIScrollView * _headScrollView;
    //内容滚动视图
    UIScrollView * _contentScrollView;
    UIView * _titleBottomLine;
//data
    //头标题
//    NSMutableArray * _titleArray;
    //头标题对应的视图控制器
//    NSMutableArray * _viewControllersArray;
    //每个视图对应的头颜色
//    NSMutableArray * _headColorsArray;
//头标题Label数组
    NSMutableArray * _titleLabelArray;
    //头标题字体
    UIFont * _titleFont;
    //头标记线颜色
    UIColor * _titleSelectBottomLineColor;
    //头标题背景高度
    CGFloat  _titleBackHeight;
    //是否动画
    BOOL _isAnimation;
    

//辅助
    int _currentIndex;
    int _beforeIndex;
    UIViewController * _visibleViewController;
    UIScrollView * _draggingScrollView;

    
}
@end


@implementation ChannelControlView
@synthesize headBackImageView = _headBackImageView;
@synthesize titleFont = _titleFont;
@synthesize titleSelectBottomLineColor = _titleSelectBottomLineColor;
#pragma mark
#pragma mark           property
#pragma mark

//下标颜色
-(void)setTitleSelectBottomLineColor:(UIColor *)titleSelectBottomLineColor
{
    _titleSelectBottomLineColor = titleSelectBottomLineColor;
    _titleBottomLine.backgroundColor = titleSelectBottomLineColor;
}
//文字字体
-(void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    for (UILabel * label in _titleLabelArray)
    {
        label.font = titleFont;
    }
}



//暂时没有处理小于三个的，小于三个的不适合这个控件
-(void)setViewControllersArray:(NSMutableArray *)viewControllersArray
{
    //清空之前的
    for (UIViewController * vc in _viewControllersArray)
    {
        [vc.view removeFromSuperview];
    }

    _viewControllersArray = viewControllersArray;
    while(_headBackColorsArray.count < _viewControllersArray.count)//颜色补全
    {
        [_headBackColorsArray addObject:default_headBackViewColor];
    }

    _contentScrollView.contentSize = CGSizeMake((_viewControllersArray.count + 2) * _contentScrollView.frame.size.width, _contentScrollView.frame.size.height);
    for (int i = 0; i < viewControllersArray.count; i++)
    {
        UIViewController * vc = [viewControllersArray objectAtIndex:i];
        vc.view.frame = CGRectMake((i+1)*_contentScrollView.frame.size.width, 0, _contentScrollView.frame.size.width, _contentScrollView.frame.size.height);
        [_contentScrollView addSubview:vc.view];
    }
    _contentScrollView.contentOffset = CGPointMake(_contentScrollView.frame.size.width, 0);
}
//头部背景颜色数组
-(void)setHeadBackColorsArray:(NSMutableArray *)headBackColorsArray
{
    _headBackColorsArray = headBackColorsArray;
    while(_headBackColorsArray.count < _viewControllersArray.count)//颜色补全
    {
        [_headBackColorsArray addObject:default_headBackViewColor];
    }
    _headBackImageView.backgroundColor = [_headBackColorsArray objectAtIndex:_currentIndex];
}

//头部标题数组,大于等于3
-(void)setTitlesArray:(NSMutableArray *)titlesArray
{
    
    _titlesArray = titlesArray;

    
    while (_titleLabelArray.count > 0)
    {
        [(UIView*)_titleLabelArray.firstObject removeFromSuperview];
    }
    
    NSMutableArray * tempArray = [NSMutableArray arrayWithObject:[[titlesArray objectAtIndex:titlesArray.count - 2] copy]];
    [tempArray addObject:[[titlesArray objectAtIndex:titlesArray.count - 1] copy]];
    [tempArray addObjectsFromArray:titlesArray];
    [tempArray addObject:[titlesArray.firstObject copy]];
    [tempArray addObject:[[titlesArray objectAtIndex:1] copy]];

    
    CGFloat width = _contentScrollView.frame.size.width/3;
    for (int i = 0; i < tempArray.count; i++)
    {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(i*width,0,_headBackImageView.frame.size.width/3, _headBackImageView.frame.size.height)];
        label.userInteractionEnabled = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [tempArray objectAtIndex:i];
        label.font = _titleFont;
        label.textColor = _titleNormalColor;//[TPLHelpTool getHexColor:@"#ffffff"];
//        label.alpha = 0.5;
        [_headScrollView addSubview:label];
        [_titleLabelArray addObject:label];
        UITapGestureRecognizer * tapTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTitle:)];
        tapTitle.numberOfTapsRequired = 1;
        [label addGestureRecognizer:tapTitle];
    }
    _headScrollView.contentOffset = CGPointMake(width, 0);
    [(UILabel*)[_titleLabelArray objectAtIndex:2] setTextColor:_titleSelectColor];
    
    
    _headScrollView.contentSize = CGSizeMake(_titleLabelArray.count*width, _headScrollView.frame.size.height);
}



#pragma mark
#pragma mark           view life
#pragma mark
//初始化基本数据
-(void)initData
{
    _currentIndex = 0;
    _beforeIndex = 0;
    _titleBackHeight = default_headBackHeight;
    _titleFont = default_titleFont;
    _titleSelectColor = default_titleSelectColor; //[TPLHelpTool getHexColor:@"#23b9b3"];
    _titleNormalColor = default_titleNormalColor ;//[TPLHelpTool getHexColor:@"#666666"];
    _titleSelectBottomLineColor = default_titleBottomLineColor;
    _titlesArray = [[NSMutableArray alloc] initWithCapacity:0];
    _viewControllersArray = [[NSMutableArray alloc] initWithCapacity:0];
    _headBackColorsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _titleLabelArray = [[NSMutableArray alloc] initWithCapacity:0];
    _isAnimation = NO;
    self.synchro = YES;
    self.fitTitleAlways = YES;
    self.needAnimation = NO;
}
//初始化视图
-(void)initView
{
    //头背景
    _headBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _titleBackHeight)];
    _headBackImageView.backgroundColor = default_headBackViewColor;
    _headBackImageView.userInteractionEnabled = YES;
    [self addSubview:_headBackImageView];
    
    //头滚动
    _headScrollView = [[UIScrollView alloc] initWithFrame:_headBackImageView.bounds];
    _headScrollView.backgroundColor = [UIColor clearColor];
    _headScrollView.showsHorizontalScrollIndicator = NO;
    _headScrollView.delegate = self;
    [_headBackImageView addSubview:_headScrollView];
    
    //头中间文字下部线颜色
    _titleBottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width*3/8,_headBackImageView.frame.size.height - 2, default_titleBottomLineWidth, 2)];
    _titleBottomLine.backgroundColor = default_titleBottomLineColor;
    [_headBackImageView addSubview:_titleBottomLine];
    
    
    //内容滚动
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _headBackImageView.frame.size.height, self.frame.size.width, self.frame.size.height - _headBackImageView.frame.size.height)];
    _contentScrollView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width * 3, _contentScrollView.frame.size.height);
    [self addSubview:_contentScrollView];
    
    
}

//初始化
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
       //data
        [self initData];
        //view
        [self initView];
    }
    return self;
}


//刷新视图位置
-(void)updateViewFrame
{
    
}

#pragma mark
#pragma mark           UIScrollView delegate
#pragma mark
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (YES == _headScrollView.decelerating)
    {
        return;
    }
    _draggingScrollView = scrollView;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == _headScrollView && !decelerate && self.fitTitleAlways)//有可能没有速度了，并且需不需要时刻调整
    {
        [self fitTitle];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
//    NSLog(@"content %@",NSStringFromCGPoint(_contentScrollView.contentOffset));
//    NSLog(@"head %@",NSStringFromCGPoint(_headScrollView.contentOffset));
    
    //头标题
    if (_headScrollView == scrollView && _draggingScrollView == _headScrollView && NO == _isAnimation)
    {
        CGFloat value =  _headScrollView.frame.size.width/3;
//        NSLog(@" value = %f ,_head x = %f ",value,_headScrollView.contentOffset.x);
        
        CGFloat ratio = 0;
        if (_headScrollView.contentOffset.x < value && _headScrollView.contentOffset.x > 0)
        {
            ratio = _headScrollView.contentOffset.x/value;
            if (ratio < 0.5)
            {
              _headScrollView.contentOffset = CGPointMake(ratio*value + value*_titlesArray.count, _headScrollView.contentOffset.y);
                //切换之后将Label颜色还原
                UILabel * firstLabel = [_titleLabelArray objectAtIndex:2];
                firstLabel.textColor = _titleNormalColor;
                UILabel * lastLabel = [_titleLabelArray objectAtIndex:1];
                lastLabel.textColor = _titleNormalColor;
            }
            if(self.synchro)
            {
                _contentScrollView.contentOffset = CGPointMake(ratio*_contentScrollView.frame.size.width, _contentScrollView.contentOffset.y);
            }
        }
        else if (_headScrollView.contentOffset.x > value*_titlesArray.count && _headScrollView.contentOffset.x < value*(_titlesArray.count + 1))
        {

            ratio = (_headScrollView.contentOffset.x - value*_titlesArray.count)/value;
            if(ratio > 0.5)//避免冲突
            {
                _headScrollView.contentOffset = CGPointMake(ratio*value, _headScrollView.contentOffset.y);
                //切换之后将Label颜色还原
                UILabel * firstLabel = [_titleLabelArray objectAtIndex:_titleLabelArray.count - 2];
                firstLabel.textColor = _titleNormalColor;
                UILabel * lastLabel = [_titleLabelArray objectAtIndex:_titleLabelArray.count - 3];
                lastLabel.textColor = _titleNormalColor;

            }
            if (self.synchro)
            {
                _contentScrollView.contentOffset = CGPointMake(_viewControllersArray.count*_contentScrollView.frame.size.width+ratio*_contentScrollView.frame.size.width, _contentScrollView.contentOffset.y);
            }
        }
        else
        {

            int currentTitleIndex = (int)_headScrollView.contentOffset.x/(int)value;
            ratio = (_headScrollView.contentOffset.x - currentTitleIndex*value)/value;
            if (ratio < 0)
            {
                ratio = 0;
            }
            if (self.synchro)
            {
                _contentScrollView.contentOffset = CGPointMake(_contentScrollView.frame.size.width*currentTitleIndex+_contentScrollView.frame.size.width*ratio, _contentScrollView.contentOffset.y);
            }
        }
        
        [self changeTitleBarWithRatio:ratio];
    }
    
    if (_contentScrollView == scrollView)
    {
//        NSLog(@" _bottom x = %f ",_contentScrollView.contentOffset.x);

        _currentIndex = (int)scrollView.contentOffset.x/(int)scrollView.frame.size.width - 1;
        //看是否已经超过一半,超过一半第一个放后面
        if(scrollView.contentOffset.x > scrollView.contentSize.width/2 && [(UIViewController*)_viewControllersArray.firstObject view].frame.origin.x != scrollView.contentSize.width - scrollView.frame.size.width)
        {
            UIViewController * firstVC = (UIViewController*)_viewControllersArray.firstObject;
            firstVC.view.frame = CGRectMake(scrollView.contentSize.width - scrollView.frame.size.width, firstVC.view.frame.origin.y, firstVC.view.frame.size.width, firstVC.view.frame.size.height);
            
            UIViewController * lastVC = (UIViewController*)_viewControllersArray.lastObject;
            lastVC.view.frame = CGRectMake(scrollView.contentSize.width - scrollView.frame.size.width*2, lastVC.view.frame.origin.y, lastVC.view.frame.size.width, lastVC.view.frame.size.height);
        }
        else if(scrollView.contentOffset.x < scrollView.contentSize.width/2 &&[(UIViewController*)_viewControllersArray.lastObject view].frame.origin.x != 0)
        {
            UIViewController * firstVC = (UIViewController*)_viewControllersArray.firstObject;
            firstVC.view.frame = CGRectMake(scrollView.frame.size.width, firstVC.view.frame.origin.y, firstVC.view.frame.size.width, firstVC.view.frame.size.height);
            
            UIViewController * lastVC = (UIViewController*)_viewControllersArray.lastObject;
            lastVC.view.frame = CGRectMake(0, lastVC.view.frame.origin.y, lastVC.view.frame.size.width, lastVC.view.frame.size.height);
        }
        
        //切换循环
        if (scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width)
        {

            UIViewController * firstVC = (UIViewController*)_viewControllersArray.firstObject;
            firstVC.view.frame = CGRectMake(scrollView.frame.size.width, firstVC.view.frame.origin.y, firstVC.view.frame.size.width, firstVC.view.frame.size.height);
            CGFloat temp = scrollView.contentOffset.x - (scrollView.contentSize.width - scrollView.frame.size.width);
            _contentScrollView.contentOffset = CGPointMake(firstVC.view.frame.origin.x + temp, _contentScrollView.contentOffset.y);
        }
        else if(scrollView.contentOffset.x <= 0)
        {

            UIViewController * lastVC = (UIViewController*)_viewControllersArray.lastObject;
            lastVC.view.frame = CGRectMake(scrollView.contentSize.width - 2*scrollView.frame.size.width, lastVC.view.frame.origin.y, lastVC.view.frame.size.width, lastVC.view.frame.size.height);
            CGFloat temp = scrollView.contentOffset.x;
            _contentScrollView.contentOffset = CGPointMake(lastVC.view.frame.origin.x + temp, _contentScrollView.contentOffset.y);
        }

        if(_draggingScrollView == _contentScrollView)
        {
            [self synchroTitleBar];
        }
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_headScrollView == _draggingScrollView && self.fitTitleAlways)
    {
        [self fitTitle];
    }
    else if(scrollView == _contentScrollView)
    {
        _currentIndex = (int)scrollView.contentOffset.x/(int)scrollView.frame.size.width - 1;
        
        if (_currentIndex == -1)
        {
            return;
        }
        
//        NSLog(@"current index = %d",_currentIndex);
        if (_beforeIndex == _currentIndex)
        {
    
        }
        else
        {
            self.currentIndex = _currentIndex;
            [(UIViewController*)[_viewControllersArray objectAtIndex:_currentIndex] viewDidAppear:NO];
            self.beforeIndex = _currentIndex;
        }
    }
//    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//    if (_headScrollView == scrollView)
//    {
//        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_contentScrollView == scrollView)
    {
        _currentIndex = (int)scrollView.contentOffset.x/(int)scrollView.frame.size.width - 1;
        
        
        //    NSLog(@"current index = %d",_currentIndex);
        if (_beforeIndex == _currentIndex)
        {
            
        }
        else
        {
            self.currentIndex = _currentIndex;
            [(UIViewController*)[_viewControllersArray objectAtIndex:_currentIndex] viewDidAppear:NO];
            self.beforeIndex = _currentIndex;
        }
    }
    else if(scrollView == _headScrollView)
    {
        _currentIndex = (int)scrollView.contentOffset.x/(int)(scrollView.frame.size.width/3) - 1;

        if (!self.needAnimation)
        {
            [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.frame.size.width*(_currentIndex +1), _contentScrollView.contentOffset.y) animated:NO];
            self.currentIndex = _currentIndex;
            [(UIViewController*)[_viewControllersArray objectAtIndex:_currentIndex] viewDidAppear:NO];
            self.beforeIndex = _currentIndex;
        }
        NSLog(@"head contentOffset = %@",NSStringFromCGPoint(_headScrollView.contentOffset));
    }
    
    _isAnimation = NO;
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}


#pragma mark
#pragma mark           help function
#pragma mark

//头标题单独滑动是混色改标题
-(void)changeTitleBarWithRatio:(CGFloat)ratio
{
    //混色
    CGFloat value = _headScrollView.frame.size.width/3.0f;
    int temp;
    int currentIndex = (int)(_headScrollView.contentOffset.x/value) - 1;
    //    NSLog(@"currentInex head %d",currentIndex);
    //    CGFloat ratio;//混色比率
    //    ratio = 1 - (scrollView.contentOffset.x - scrollView.frame.size.width*(_currentIndex + 1))/scrollView.frame.size.width;
    temp = currentIndex+1;
    
    int currentLabelIndex = currentIndex + 2;
    if (currentIndex == _titlesArray.count - 1)
    {
        temp = 0;
    }
    if (currentIndex < 0)
    {
        currentIndex = (int)_titlesArray.count - 1;
        temp = 0;
        currentLabelIndex = 1;
    }
    //            NSLog(@"current = %d, temp = %d ,ratio = %f",_currentIndex,temp,ratio);
    _headBackImageView.backgroundColor = [ChannelControlView mixColor1:[_headBackColorsArray objectAtIndex:currentIndex] color2:[_headBackColorsArray objectAtIndex:temp] ratio:(1-ratio)];
    
    
    //切换标题
    if(_titleLabelArray.count > currentIndex+2)
    {
        int index = currentLabelIndex;
        int tempIndex = index + 1;
        
        if (currentIndex == _viewControllersArray.count - 1)
        {
            tempIndex = index+1;
            UILabel * label = [_titleLabelArray objectAtIndex:2];
            label.textColor = _titleNormalColor;
            
            label = [_titleLabelArray objectAtIndex:currentIndex];
            label.textColor = _titleNormalColor;

        }
        if (currentIndex == 0)
        {
            UILabel * label = [_titleLabelArray objectAtIndex:_titleLabelArray.count - 3];
            label.textColor = _titleNormalColor;
        }
        
        
        //        CGFloat width = _contentScrollView.frame.size.width/3;
        UILabel * currentLabel = [_titleLabelArray objectAtIndex:index];
        //        _headScrollView.contentOffset = CGPointMake(currentLabel.frame.origin.x - ratio*width, 0);
        currentLabel.textColor = [ChannelControlView mixColor1:_titleSelectColor color2:_titleNormalColor ratio:(1 - ratio)];
        UILabel * tempLabel = [_titleLabelArray objectAtIndex:tempIndex];
        tempLabel.textColor = [ChannelControlView mixColor1:_titleSelectColor color2:_titleNormalColor ratio:ratio];
        if (ratio >= 1)//调整误差
        {
            currentLabel.textColor = self.titleSelectColor;
            tempLabel.textColor = self.titleNormalColor;
        }
        
    }
}

//关联运动是，底部驱动标题变化
-(void)synchroTitleBar
{
    //混色
    int temp;
    CGFloat ratio;//混色比率
    ratio = 1 - (_contentScrollView.contentOffset.x - _contentScrollView.frame.size.width*(_currentIndex + 1))/_contentScrollView.frame.size.width;
    temp = _currentIndex+1;
    
    if (_currentIndex < 0)
    {
        _currentIndex = (int)_viewControllersArray.count - 1;
        temp = 0;
    }
    if (_currentIndex == (int)_viewControllersArray.count - 1)
    {
        temp = 0;
    }
    //        NSLog(@"current = %d, temp = %d ,ratio = %f",_currentIndex,temp,ratio);
    _headBackImageView.backgroundColor = [ChannelControlView mixColor1:[_headBackColorsArray objectAtIndex:_currentIndex] color2:[_headBackColorsArray objectAtIndex:temp] ratio:ratio];
    
    
    //切换标题
    if(_titleLabelArray.count > _currentIndex+2)
    {
        int index = _currentIndex + 2;
        int tempIndex = temp + 2;
        
        CGFloat width = _contentScrollView.frame.size.width/3;
        UILabel * currentLabel = [_titleLabelArray objectAtIndex:index];
        _headScrollView.contentOffset = CGPointMake(currentLabel.frame.origin.x - ratio*width, 0);
        currentLabel.textColor = [ChannelControlView mixColor1:_titleSelectColor color2:_titleNormalColor ratio:ratio];
        UILabel * tempLabel = [_titleLabelArray objectAtIndex:tempIndex];
        tempLabel.textColor = [ChannelControlView mixColor1:_titleSelectColor color2:_titleNormalColor ratio:(1-ratio)];
        if (ratio >= 1)//调整误差
        {
            currentLabel.textColor = self.titleSelectColor;
            tempLabel.textColor = self.titleNormalColor;
        }
        
    }
}


//混合颜色,ratio 0~1
+(UIColor *)mixColor1:(UIColor*)color1 color2:(UIColor *)color2 ratio:(CGFloat)ratio
{
//    NSLog(@"ratio = %f",ratio);
    if(ratio >= 1)
        ratio = 1;
    const CGFloat * components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat * components2 = CGColorGetComponents(color2.CGColor);
//        NSLog(@"Red1: %f", components1[0]);
//        NSLog(@"Green1: %f", components1[1]);
//        NSLog(@"Blue1: %f", components1[2]);
//        NSLog(@"alpha1: %f", components1[3]);
//
//        NSLog(@"Red2: %f", components2[0]);
//        NSLog(@"Green2: %f", components2[1]);
//        NSLog(@"Blue2: %f", components2[2]);
//        NSLog(@"alpha2: %f", components1[3]);

    
//    NSLog(@"ratio = %f",ratio);
    CGFloat r = components1[0]*ratio + components2[0]*(1-ratio);
    CGFloat g = components1[1]*ratio + components2[1]*(1-ratio);
    CGFloat b = components1[2]*ratio + components2[2]*(1-ratio);
    CGFloat alpha = components1[3]*ratio + components2[3]*(1-ratio);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

-(void)fitTitle//调整滚动后的头标题
{
    CGFloat value = _headScrollView.frame.size.width/3;
    int index = (int)_headScrollView.contentOffset.x/(int)value;
    
    CGFloat tempCenterX = _headScrollView.contentOffset.x + _headScrollView.frame.size.width/2;
    CGFloat minValue = _headScrollView.frame.size.width;
    UILabel * closeLabel = nil;
    for (int i = 0; i < 3; i++)
    {
        UILabel * label = [_titleLabelArray objectAtIndex:i + index];
        CGFloat compareValue = abs((int)(label.center.x - tempCenterX));
        if(compareValue < minValue)
        {
            minValue = compareValue;
            closeLabel = label;
        }
    }
    
    [self tapTitleLabel:closeLabel];
}


#pragma mark
#pragma mark           tap ||
#pragma mark
-(void)tapTitle:(UITapGestureRecognizer*)tapTitle
{
    UILabel * label = (UILabel*)tapTitle.view;
    _draggingScrollView = _headScrollView;
    if (_titleSelectColor == label.textColor)
    {
        return;
    }
    [self tapTitleLabel:label];
}

-(void)tapTitleLabel:(UILabel*)titleLabel
{
    int index = (int)[_titleLabelArray indexOfObject:titleLabel];
    int changeToIndex = index - 2;
    if (index == 1)
    {
        changeToIndex = -1;
    }
    if (index == 0)
    {
        changeToIndex = (int)_viewControllersArray.count - 2;
    }
    if (index == _titleLabelArray.count - 1)
    {
        changeToIndex = 1;
    }
    if (index == _titleLabelArray.count - 2)
    {
        changeToIndex = (int)_viewControllersArray.count;
    }
    
    
    if (self.needAnimation)//需要动画
    {
        _isAnimation = YES;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        _draggingScrollView = _contentScrollView;
        [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.frame.size.width*(changeToIndex + 1),0) animated:self.needAnimation];
    }
    else if (!self.needAnimation)
    {
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [_headScrollView setContentOffset:CGPointMake(_headScrollView.frame.size.width/3*(changeToIndex + 1), _headScrollView.contentOffset.y) animated:YES];
    }
}


#pragma mark
#pragma mark           add function
#pragma mark
//添加视图控制器方法
-(void)addViewController:(UIViewController*)viewController withTitle:(NSString*)title color:(UIColor*)color
{
    
}
-(void)addViewControllers:(NSArray*)viewcontrollers withTitles:(NSArray*)titles colors:(NSArray*)colors
{
    
}







/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
