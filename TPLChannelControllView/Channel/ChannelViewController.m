//
//  ChannelViewController.m
//  波波二期联播界面实验
//
//  Created by 谭鄱仑 on 15-1-15.
//  Copyright (c) 2015年 谭鄱仑. All rights reserved.
//

#import "ChannelViewController.h"

#import "VideoItemViewCell.h"
//#import "TPLTablePullRefreshView.h"
//#import "IFMKModel+DataList.h"





#define videoItemCellIdentify @"videoItemCell"


@interface ChannelViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TPLTablePullRefreshViewDelegate>
{
//view
    ChannelVideoPlayerView * _playerView;
    UICollectionView * _videoListCollectionView;
    TPLTablePullRefreshView * _pullHeadRefreshView;
    TPLTablePullRefreshView * _pullFooterRefreshView;
//data
    NSMutableArray * _videosDataArray;
    
//辅助
    int _page;
    NSInteger _responseZone;
    
    
}


//头部播放视图
-(void)initHeadPlayerView;
//底部列表视图
-(void)initVideoListCollectionView;
//添加下拉刷新，上拉加载
-(void)addPullRefreshView;

@end

@implementation ChannelViewController
@synthesize channelTag = _channelTag;
@synthesize playerView = _playerView;


-(NSString*)getStatisticsString
{
    NSString * labelString = @"";
    switch (self.channelTag)
    {
        case 1:
            labelString = LABEL_CHANNEL_YLRD;
            break;
        case 2:
            labelString = LABEL_CHANNEL_QSSK;
            break;
        case 3:
            labelString = LABEL_CHANNEL_GRCY;
            break;
        case 4:
            labelString = LABEL_CHANNEL_YDQQ;
            break;
        case 5:
            labelString = LABEL_CHANNEL_MV;
            break;
        default:
            break;
    }
    return labelString;
}
#pragma mark
#pragma mark           property
#pragma mark
-(void)setChannelColor:(UIColor *)channelColor
{
    _channelColor = channelColor;
    _playerView.timeProgressColor = channelColor;
}

-(void)initHeadPlayerView
{
    _playerView = [[ChannelVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,180)];
    _playerView.timeProgressColor = _channelColor;
//    _playerView.image = [UIImage imageNamed:@"bg_default_img_640x320.png"];
//    _playerView.backgroundColor = [TPLHelpTool getRandomColor];
    [self.view addSubview:_playerView];
}

//底部列表视图
-(void)initVideoListCollectionView
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((self.view.bounds.size.width - 14 - 8)/2, 102);
    flowLayout.minimumInteritemSpacing = 8.0f;
    flowLayout.minimumLineSpacing = 8.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(7, 7, 0, 7);
    _videoListCollectionView  = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, _playerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _playerView.frame.size.height) collectionViewLayout:flowLayout];
    _videoListCollectionView.backgroundColor = [TPLHelpTool getHexColor:@"#dfdfdf"];//[UIColor colorWithWhite:0.9 alpha:1];
    [_videoListCollectionView registerClass:[VideoItemViewCell class] forCellWithReuseIdentifier:videoItemCellIdentify];
    _videoListCollectionView.delegate = self;
    _videoListCollectionView.dataSource = self;
    [self.view addSubview:_videoListCollectionView];
    self.view.autoresizesSubviews = YES;
    _videoListCollectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

}

//添加下拉刷新，上拉加载
-(void)addPullRefreshView
{
    //下拉刷新
    _pullHeadRefreshView = [[TPLTablePullRefreshView alloc] init];
    _pullHeadRefreshView.backgroundColor = [UIColor clearColor];
    _pullHeadRefreshView.visibleHeight = 70;
    _pullHeadRefreshView.style = TPLTablePullRefreshViewHeaderStyle;
    _pullHeadRefreshView.showStyle = 2;
    _pullHeadRefreshView.scrollView = _videoListCollectionView;
    _pullHeadRefreshView.delegate = self;
    _pullHeadRefreshView.loadingImageView.frame = CGRectMake(0, 5, self.view.bounds.size.width, 70);
    _pullHeadRefreshView.pullImageView.frame = CGRectMake(0, 5, self.view.bounds.size.width, 70);
    _pullHeadRefreshView.pullImagePath = [[NSBundle mainBundle] pathForResource:@"down" ofType:@"gif"];
    _pullHeadRefreshView.loadingImagePath =  [[NSBundle mainBundle] pathForResource:@"down" ofType:@"gif"];
    
    //上拉加载
    _pullFooterRefreshView = [[TPLTablePullRefreshView alloc] init];
    _pullFooterRefreshView.backgroundColor = [UIColor clearColor];
    _pullFooterRefreshView.visibleHeight = 0;
    _pullFooterRefreshView.style = TPLTablePullRefreshViewFooterStyle;
    _pullFooterRefreshView.showStyle = 2;
    _pullFooterRefreshView.scrollView = _videoListCollectionView;
    _pullFooterRefreshView.pullImagePath = @"";
    _pullFooterRefreshView.loadingImagePath = @"";
    _pullFooterRefreshView.textLabel.hidden = YES;
    _pullFooterRefreshView.delegate = self;
    
    
    //关联
    _pullFooterRefreshView.groupView = _pullHeadRefreshView;
    _pullHeadRefreshView.groupView = _pullFooterRefreshView;

}

-(void)initBaseData
{
    _page = 1;
    _channelTag = 1;
    _responseZone = 1;
    _videosDataArray = [[NSMutableArray alloc] initWithCapacity:0];
}
-(id)init
{
    self = [super init];
    if (self)
    {
        [self initBaseData];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
//    _videoListCollectionView.frame = CGRectMake(self.view.bounds.origin.x, _playerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _playerView.frame.size.height);
//    if (animated == NO)
//    {
//        NSLog(@"");
//        [BoBoStatisticsModel statisticsForBeginTime:EVENT_CHANNEL_DURING label:[self getStatisticsString]];
//        _pullHeadRefreshView.loading = YES;
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [TPLHelpTool getHexColor:@"#dfdfdf"];//[UIColor colorWithWhite:0.9 alpha:1];
    
    [self initHeadPlayerView];
    [self initVideoListCollectionView];
    [self addPullRefreshView];
    
    
//    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, _playerView.frame.size.height + -100, self.view.bounds.size.width, 70)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = self.title;
//    [self.view addSubview:label];
    
}


#pragma mark
#pragma mark           request
#pragma mark
-(void)refreshRequest
{
    
    [[IFMKModel model] getChannelVideoListByClassId:_channelTag withZone:1 withPage:1 withCallbackBlock:^(NSNumber *code,NSMutableArray *array, NSInteger responseZone, NSInteger responsePage,ResponseError error){
        
        if (array>0)
        {
            _page = 1;
            _responseZone = responseZone;
            [_videosDataArray removeAllObjects];
            [_videosDataArray addObjectsFromArray:array];
            _pullHeadRefreshView.loading = NO;
            _pullFooterRefreshView.loading = NO;
            
            [_videoListCollectionView reloadData];
            //            [_playerView resetVideoList:_videosDataArray];
            
            //            [[FPCDModel model] deleteVideoCacheByClass_id:1];
            //            [categoryVideoListVC settingTableDataScource:array];
        }
        //        [categoryVideoListVC.videoTableView headerEndRefreshing];
        //        currentVC.isRefreshing = NO;
        else
        {
            _pullHeadRefreshView.loading = NO;
            _pullFooterRefreshView.loading = NO;
        }
        
        
    }];
    
    [[IFMKModel model] getRecommendVideoListByClassId:_channelTag withCallbackBlock:^(NSNumber *code,NSMutableArray *array, NSInteger responseZone, NSInteger responsePage,ResponseError error){
        
        if (array>0)
        {
            
            [_playerView resetVideoList:array];
            
            //            [[FPCDModel model] deleteVideoCacheByClass_id:1];
            //            [categoryVideoListVC settingTableDataScource:array];
        }
        //        [categoryVideoListVC.videoTableView headerEndRefreshing];
        //        currentVC.isRefreshing = NO;
        else
        {
            //            _pullHeadRefreshView.loading = NO;
            //            _pullFooterRefreshView.loading = NO;
        }
        
        
    }];

//================zhubo test====================
//    [[IFMKModel model] getChannelVideoListByClassId:_channelTag withZone:1 withPage:1 withCallbackBlock:^(NSNumber *code,NSMutableArray *array, NSInteger responseZone, NSInteger responsePage,ResponseError error){
//        
//        if (array>0)
//        {
//            _page = 1;
//            _responseZone = responseZone;
//            [_videosDataArray removeAllObjects];
//            [_videosDataArray addObjectsFromArray:array];
//            _pullHeadRefreshView.loading = NO;
//            _pullFooterRefreshView.loading = NO;
//            
//            [_videoListCollectionView reloadData];
////            [_playerView resetVideoList:_videosDataArray];
//            
//            //            [[FPCDModel model] deleteVideoCacheByClass_id:1];
//            //            [categoryVideoListVC settingTableDataScource:array];
//        }
//        //        [categoryVideoListVC.videoTableView headerEndRefreshing];
//        //        currentVC.isRefreshing = NO;
//        else
//        {
//            _pullHeadRefreshView.loading = NO;
//            _pullFooterRefreshView.loading = NO;
//        }
//
//        
//    }];
//    
//    [[IFMKModel model] getRecommendVideoListByClassId:_channelTag withCallbackBlock:^(NSNumber *code,NSMutableArray *array, NSInteger responseZone, NSInteger responsePage,ResponseError error){
//        
//        if (array>0)
//        {
//            
//            [_playerView resetVideoList:array];
//            
//            //            [[FPCDModel model] deleteVideoCacheByClass_id:1];
//            //            [categoryVideoListVC settingTableDataScource:array];
//        }
//        //        [categoryVideoListVC.videoTableView headerEndRefreshing];
//        //        currentVC.isRefreshing = NO;
//        else
//        {
////            _pullHeadRefreshView.loading = NO;
////            _pullFooterRefreshView.loading = NO;
//        }
//        
//        
//    }];
//================zhubo test====================
}

-(void)getRequestForPage:(int)page
{
    [[IFMKModel model] getChannelVideoListByClassId:_channelTag withZone:_responseZone withPage:page withCallbackBlock:^(NSNumber *code,NSMutableArray *array, NSInteger responseZone, NSInteger responsePage,ResponseError error){
        
        if (array>0)
        {
            _page = page;
            _responseZone = responseZone;
            
            [_videosDataArray addObjectsFromArray:array];
            _pullHeadRefreshView.loading = NO;
            _pullFooterRefreshView.loading = NO;
            
            [_videoListCollectionView reloadData];
            //            [[FPCDModel model] deleteVideoCacheByClass_id:1];
            //            [categoryVideoListVC settingTableDataScource:array];
        }
        else
        {
            _pullHeadRefreshView.loading = NO;
            _pullFooterRefreshView.loading = NO;
        }
        //        [categoryVideoListVC.videoTableView headerEndRefreshing];
        //        currentVC.isRefreshing = NO;
        
        
    }];
    

}

#pragma mark
#pragma mark           UICollectionViewDelegate & UICollectionViewDataSource
#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _videosDataArray.count;
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoItemViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:videoItemCellIdentify forIndexPath:indexPath];
//    cell.backgroundColor = [TPLHelpTool getRandomColor];
    cell.backgroundColor = [UIColor whiteColor];
    cell.model = [_videosDataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_playerView resetVideoList:_videosDataArray];
    [_playerView playIndex:indexPath.row];
}
#pragma mark
#pragma mark           TPLTablePullRefreshViewDelegate
#pragma mark
//下拉刷新
-(void)refreshScrollView:(UIScrollView*)scrollView TPLTablePullRefreshView:(TPLTablePullRefreshView*)view
{
//    [self refreshRequest];
//    [self performSelector:@selector(testOK) withObject:nil afterDelay:3];
}
//上拉加载
-(void)addMoreScrollView:(UIScrollView*)scrollView TPLTablePullRefreshView:(TPLTablePullRefreshView*)view
{
//    [self getRequestForPage:_page+1];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    _pullHeadRefreshView.scrollView = nil;
    _pullFooterRefreshView.scrollView = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
