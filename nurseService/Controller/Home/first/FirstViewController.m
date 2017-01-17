//
//  FirstViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "FirstViewController.h"
#import "LBBanner.h"
#import "HomePageTableCell.h"
#import "RESideMenu.h"
#import "AppDelegate.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "ImageScale.h"
#import "HeServiceDetailVC.h"
#import "HeBookServiceVC.h"
#import "HYPageView.h"

#define LBBannerTag 100
#define HeadTag  200


@interface FirstViewController ()<LBBannerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger addStatusBarHeight;
    NSMutableArray *bannerDataSource;
    NSInteger pageNum;
    UIButton *locationButton;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation FirstViewController
@synthesize tableview;
@synthesize dataSource;
@synthesize imageCache;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"首页";
        [label sizeToFit];
        self.title = @"首页";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    //加载轮播
    [self loadBannerImage];
    //加载精品推荐
    [self loadRecommendService];
}

- (void)initializaiton
{
    [super initializaiton];
    bannerDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    imageCache = [[NSCache alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCitySucceed:) name:kGetCitySucceedNotification object:nil];
}

- (void)initView
{
    [super initView];
    
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIImage *menuIcon = [UIImage imageNamed:@"icon_list"];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] init];
    menuItem.image = menuIcon;
    menuItem.target = self;
    menuItem.action = @selector(menuButtonClick:);
    self.navigationItem.leftBarButtonItem = menuItem;
    
    NSString *citystring = [[NSUserDefaults standardUserDefaults] objectForKey:kPreLocationCityKey];
    if (citystring == nil || [citystring isEqualToString:@""]) {
        citystring = @"杭州市";
    }
    CGFloat addressButtonH = 25;
    CGFloat addressButtonW = 80;
    UIButton *addressButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addressButtonW, addressButtonH)];
    [addressButton addTarget:self action:@selector(addressButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    addressButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [addressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addressButton setTitle:citystring forState:UIControlStateNormal];
    UIImage *arrowImage = [UIImage imageNamed:@"icon_white_down"];
    [addressButton setImage:arrowImage forState:UIControlStateNormal];
    // 设置按钮图片偏移
    [addressButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0,-addressButton.imageView.bounds.size.width, 0.0,addressButton.imageView.bounds.size.width)];
    [addressButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, addressButton.titleLabel.bounds.size.width, 0.0, -addressButton.titleLabel.bounds.size.width)];
    
    locationButton = addressButton;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addressButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGFloat headerHeight = 300;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    headerView.tag = HeadTag;
    headerView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    
    
    CGFloat bannerHeight = 180;
    NSArray * imageNames = @[@"index1", @"index2"];
    LBBanner * banner = [[LBBanner alloc] initWithImageNames:imageNames andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
    banner.tag = LBBannerTag;
    banner.delegate = self;
    
    [headerView addSubview:banner];
    
    CGFloat buttonBGHeight = 110;
    UIView *buttonBG = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(banner.frame), SCREENWIDTH, buttonBGHeight)];
    NSArray *iconArray = @[@[@"icon_nurse_door",@"icon_personal"]];
    NSArray *titleArray = @[@[@"护士上门",@"私人定制"]];
    
    buttonBG.backgroundColor = [UIColor whiteColor];
    [self addButtonToView:buttonBG withImage:iconArray andTitle:titleArray imageWidth:60];
    [headerView addSubview:buttonBG];
    
    CGFloat sepLineX = SCREENWIDTH / 2.0 - 0.5;
    CGFloat sepLineW = 2;
    CGFloat sepLineH = 40;
    CGFloat sepLineY = (buttonBGHeight - sepLineH) / 2.0;
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    sepLine.backgroundColor = [UIColor blackColor];
    [buttonBG addSubview:sepLine];
    
    self.tableview.tableHeaderView = headerView;
    
    __weak FirstViewController *weakSelf = self;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
        [weakSelf loadBannerImage];
        [weakSelf loadRecommendService];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
        [weakSelf loadRecommendService];
        
    }];
}

- (void)endRefreshing
{
    [self.tableview.footer endRefreshing];
    self.tableview.footer.hidden = YES;
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
    NSLog(@"endRefreshing");
}

- (void)getCitySucceed:(NSNotification *)notification
{
    NSString *city = notification.object;
    [locationButton setTitle:city forState:UIControlStateNormal];    // 设置按钮图片偏移
    [locationButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0,-locationButton.imageView.bounds.size.width, 0.0,locationButton.imageView.bounds.size.width)];
    [locationButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, locationButton.titleLabel.bounds.size.width, 0.0, -locationButton.titleLabel.bounds.size.width)];
}

//加载轮播图
- (void)loadBannerImage
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/khdManage/rollPicList.action",BASEURL];
    NSDictionary * params  = @{@"1": @"1"};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        if (pageNum == 0) {
            [dataSource removeAllObjects];
        }
        NSMutableDictionary *respondDict = [NSMutableDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = respondDict[@"json"];
            NSMutableArray *imageUrlArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSDictionary *dict in jsonArray) {
                [bannerDataSource addObject:dict];
                NSString *rollPicUrl = dict[@"rollPicUrl"];
                if ([rollPicUrl isMemberOfClass:[NSNull class]] || rollPicUrl == nil) {
                    rollPicUrl = @"";
                }
                rollPicUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,rollPicUrl];
                [imageUrlArray addObject:rollPicUrl];
                
            }
            CGFloat bannerHeight = 180;
            LBBanner *banner1 = [tableview.tableHeaderView viewWithTag:LBBannerTag];
            LBBanner *banner = [[LBBanner alloc] initWithImageURLArray:imageUrlArray andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
            banner.tag = LBBannerTag;
            banner.delegate = self;
            [tableview.tableHeaderView addSubview:banner];
            [banner1 removeFromSuperview];
            
            
        }
    } failure:^(NSError* err){
        
    }];
}

//加载精品推荐
- (void)loadRecommendService
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/khdManage/goodServiceRecommendList.action",BASEURL];
    NSString *pageNumString = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary * params  = @{@"pageNum": pageNumString};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = respondDict[@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                if (pageNum > 0) {
                    //因为无法加载更多，所以回复到原来的页数
                    pageNum--;
                }
                return;
            }
            if (pageNum == 0) {
                //如果刷新，先清除数据
                [dataSource removeAllObjects];
            }
            for (id dict in jsonArray) {
                [dataSource addObject:dict];
            }
            [tableview reloadData];
        }
    } failure:^(NSError* err){
        
    }];
}

//添加按钮
- (void)addButtonToView:(UIView *)buttonBG withImage:(NSArray *)imagearray andTitle:(NSArray *)nameArray imageWidth:(CGFloat)myimageWidth
{
    CGFloat viewW = buttonBG.frame.size.width;
    CGFloat viewH = buttonBG.frame.size.height;
    NSInteger buttonCountRow = [[imagearray objectAtIndex:0] count];
    NSInteger buttonCountColumn = [imagearray count];
    CGFloat buttonX = 0;
    
    CGFloat buttonVDistance = 1;
    
    CGFloat buttonW = 80;
    CGFloat buttonH = 70;
    CGFloat buttonHDistance = 80;
    
    buttonX = (SCREENWIDTH - (buttonCountRow - 1) * buttonHDistance - buttonCountRow * buttonW) / 2.0;
    CGFloat buttonY = 20;
    
    for (int i = 0; i < [imagearray count]; i++) {
        for (int j = 0; j < [[imagearray objectAtIndex:i] count]; j++) {
            
            NSString *imageName = [[imagearray objectAtIndex:i] objectAtIndex:j];
            UIImage *orignalImage = [UIImage imageNamed:imageName];
            CGFloat imageWidth = myimageWidth;
            CGFloat imageHeight = imageWidth / orignalImage.size.width * orignalImage.size.height;
            CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
            NSString *buttonTitle = [[nameArray objectAtIndex:i] objectAtIndex:j];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(buttonX + j * buttonHDistance + j * buttonW, buttonY + i * buttonVDistance + i * buttonH, buttonW, buttonH);
            button.tag = i * [[imagearray objectAtIndex:i] count] + j + buttonBG.tag;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[orignalImage scaleToSize:CGSizeMake(imageWidth, imageHeight)] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [buttonBG addSubview:button];
            [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
            
            // 按钮图片和标题总高度
            CGFloat totalHeight = (button.imageView.frame.size.height + button.titleLabel.frame.size.height);
            // 设置按钮图片偏移
            // 设置按钮标题偏移
            [button setTitleEdgeInsets:UIEdgeInsetsMake(10.0, -button.imageView.frame.size.width, -(totalHeight - button.titleLabel.frame.size.height),0.0)];
            
            [button setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - button.imageView.frame.size.height), 0.0, 0.0, -button.titleLabel.frame.size.width)];
            
            
        }
        
    }
}

- (void)buttonClick:(UIButton *)button
{
    if (button.tag == 0) {
        NSLog(@"护士上门");
        //展示左边菜单
        RESideMenu *resideMenuVC = (RESideMenu *)((AppDelegate *)[UIApplication sharedApplication].delegate).viewController;
        [resideMenuVC presentLeftMenuViewController];
    }
    else{
        NSLog(@"私人定制");
    }
}
- (void)menuButtonClick:(id)sender
{
    //展示左边菜单
    RESideMenu *resideMenuVC = (RESideMenu *)((AppDelegate *)[UIApplication sharedApplication].delegate).viewController;
    [resideMenuVC presentLeftMenuViewController];
}

- (void)addressButtonClick:(UIButton *)button
{
    NSLog(@"addressButtonClick");
}

-(void)chooseCity{
    NSLog(@"chooseCity");
    
}

#pragma mark LBBannerDelegate
- (void)banner:(LBBanner *)banner didClickViewWithIndex:(NSInteger)index {
    NSLog(@"didClickViewWithIndex:%ld", index);
    NSDictionary *dict = nil;
    @try {
        dict = bannerDataSource[index];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSString *rollPicId = dict[@"rollPicAddress"];
    if ([rollPicId isMemberOfClass:[NSNull class]] || rollPicId == nil) {
        rollPicId = @"";
    }
    NSDictionary *myDict = @{@"contentId":rollPicId};
    [self bookServiceWithDict:myDict];
}

- (void)banner:(LBBanner *)banner didChangeViewWithIndex:(NSInteger)index {
    NSLog(@"didChangeViewWithIndex:%ld", index);
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HomePageTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    
    HomePageTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HomePageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSString *goodServiceRecommendContentPic = dict[@"goodServiceRecommendContentPic"];
    if ([goodServiceRecommendContentPic isMemberOfClass:[NSNull class]] || goodServiceRecommendContentPic == nil) {
        goodServiceRecommendContentPic = @"";
    }
    goodServiceRecommendContentPic = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,goodServiceRecommendContentPic];
    NSString *imageKey = [NSString stringWithFormat:@"%@_%ld",goodServiceRecommendContentPic,row];
    UIImageView *imageview = [imageCache objectForKey:imageKey];
    if (!imageview) {
        [cell.bgImage sd_setImageWithURL:[NSURL URLWithString:goodServiceRecommendContentPic] placeholderImage:[UIImage imageNamed:@"index2"]];
        imageview = cell.bgImage;
    }
    cell.bgImage = imageview;
    [cell addSubview:cell.bgImage];
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"section = %ld, row = %ld",section,row);
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSLog(@"dict = %@",dict);
    NSString *goodServiceRecommendContentId = dict[@"goodServiceRecommendContentId"];
    if ([goodServiceRecommendContentId isMemberOfClass:[NSNull class]] || goodServiceRecommendContentId == nil) {
        goodServiceRecommendContentId = @"";
    }
    NSDictionary *myDict = @{@"contentId":goodServiceRecommendContentId};
    [self bookServiceWithDict:myDict];
}

- (void)bookServiceWithDict:(NSDictionary *)dict
{
    //总控制器，控制商品、详情、评论三个子控制器
    HeBookServiceVC *serviceDetailVC = [[HeBookServiceVC alloc] init];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [serviceDetailVC.view addSubview:[self getPageViewWithParam:dict]];
    [self showViewController:serviceDetailVC sender:nil];
}

- (HYPageView *)getPageViewWithParam:(NSDictionary *)dict
{
    NSString *contentid = dict[@"contentId"];
    if (!contentid) {
        contentid = @"";
    }
    NSDictionary *myDict = @{@"contentId":contentid};
    
    NSDictionary *paramDict = @{@"service":myDict};
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH) withTitles:@[@"商品",@"详情",@"评论"] withViewControllers:@[@"HeServiceDetailVC",@"HeServiceInfoVC",@"HeCommentVC"] withParameters:@[paramDict,myDict,myDict]];
    pageView.isTranslucent = NO;
    pageView.topTabBottomLineColor = [UIColor whiteColor];
    pageView.selectedColor = [UIColor whiteColor];
    pageView.unselectedColor = [UIColor whiteColor];
    UIButton *backImage = [[UIButton alloc] init];
    [backImage setBackgroundImage:[UIImage imageNamed:@"navigationBar_back_icon"] forState:UIControlStateNormal];
    [backImage addTarget:self action:@selector(backItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    backImage.frame = CGRectMake(0, 0, 25, 25);
    
    pageView.leftButton = backImage;
    
    return pageView;
}

- (void)backItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.text = @"精品推荐";
    [headerView addSubview:titleLabel];
    
    CGSize size = [MLLabel getViewSizeByString:titleLabel.text maxWidth:titleLabel.frame.size.width font:titleLabel.font lineHeight:1.2f lines:0];
    
    //两条横线的间距
    CGFloat lineDistance = 20 + size.width;
    CGFloat sepLineX = 20;
    CGFloat sepLineW = (SCREENWIDTH - lineDistance - 2 * sepLineX) / 2.0;
    CGFloat sepLineH = 1;
    CGFloat sepLineY = (50 - sepLineH) / 2.0 - 0.5;
    UIView *leftSepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    leftSepLine.backgroundColor = [UIColor grayColor];
    [headerView addSubview:leftSepLine];

    sepLineX = CGRectGetMaxX(leftSepLine.frame) + lineDistance;
    UIView *rightSepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    rightSepLine.backgroundColor = [UIColor grayColor];
    [headerView addSubview:rightSepLine];
    
    return headerView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetCitySucceedNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
