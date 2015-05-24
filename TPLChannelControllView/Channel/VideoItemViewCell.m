//
//  VideoItemView.m
//  BoBoBox
//
//  Created by 谭鄱仑 on 15-1-24.
//  Copyright (c) 2015年 zhubo. All rights reserved.
//

#import "VideoItemViewCell.h"
//#import "UIImageView+WebCache.h"


//#import "BoBoVideoEntity.h"



@interface VideoItemViewCell ()
{
//View
    UIImageView * _contentImageView;
    UILabel * _detailLabel;
}
@end

@implementation VideoItemViewCell


-(void)setModel:(NSObject *)model
{
    _model = model;
    
//    if ([model isKindOfClass:[BoBoVideoEntity class]])
//    {
//        BoBoVideoEntity * videoEntity = (BoBoVideoEntity*)model;
//
//        [_contentImageView setImageWithURL:[NSURL URLWithString:videoEntity.videoCoverImageUrl] placeholderImage:[UIImage imageNamed:@"bg_default_img_298x168.png"]];
//        _detailLabel.text = videoEntity.videoTitle;
//    }
}





-(void)initUI
{
    //详情图片
    _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20)];
    _contentImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_contentImageView];
    _contentImageView.image = [UIImage imageNamed:@"bg_default_img_298x168.png"];
    //详情文字
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _contentImageView.frame.size.height, self.frame.size.width - 10*2, 20)];
    _detailLabel.textColor = [UIColor grayColor];
    _detailLabel.font = [UIFont systemFontOfSize:14];
    _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:_detailLabel];
    //播放按钮
    //播放按钮
     UIButton * playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake((_contentImageView.frame.size.width - 40)/2, (_contentImageView.frame.size.height - 40)/2, 40, 40);
    [playButton setBackgroundImage:[UIImage imageNamed:@"btn_play_small.png"] forState:UIControlStateNormal];
//    [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_contentImageView addSubview:playButton];

 
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
