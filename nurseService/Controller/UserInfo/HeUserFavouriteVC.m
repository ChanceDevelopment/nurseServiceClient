//
//  HeUserFavouriteVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//  我的收藏视图控制器

#import "HeUserFavouriteVC.h"
#import "DLNavigationTabBar.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "HeSearchInfoVC.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "MLLabel+Size.h"
#import "MLLabel.h"
#import "HeServiceTableCell.h"
#import "HeCommentVC.h"
#import "HeServiceDetailVC.h"
#import "BrowserView.h"
#import "HeBookServiceVC.h"
#import "HYPageView.h"
#import "HeNurseTableViewCell.h"
#import "HeNurseDetailVC.h"
#import "HeSearchNurseTableCell.h"

@interface HeUserFavouriteVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger pageNum;
    NSInteger servicePageNum;
    NSInteger currentIndex;
}
@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *serviceItemArray;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeUserFavouriteVC
@synthesize tableview;
@synthesize dataSource;

-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"护士",@"服务"]];
        self.navigationTabBar.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        self.navigationTabBar.sliderBackgroundColor = APPDEFAULTORANGE;
        self.navigationTabBar.buttonNormalTitleColor = [UIColor grayColor];
        self.navigationTabBar.buttonSelectedTileColor = APPDEFAULTORANGE;
        __weak typeof(self) weakSelf = self;
        [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
            [weakSelf navigationDidSelectedControllerIndex:index];
        }];
    }
    return _navigationTabBar;
}

#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    currentIndex = index;
    if (currentIndex == 0 && [dataSource count] == 0) {
        [self loadNurseData];
        return;
    }
    else if (currentIndex == 1 && [_serviceItemArray count] == 0){
        [self loadServiceData];
        return;
    }
    [tableview reloadData];
}

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
        label.text = @"我的收藏";
        [label sizeToFit];
        self.title = @"我的收藏";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self loadNurseData];
}

//资源初始化
- (void)initializaiton
{
    [super initializaiton];
    
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _imageCache = [[NSCache alloc] init];
    _serviceItemArray = [[NSMutableArray alloc] initWithCapacity:0];
    servicePageNum = 0;
    currentIndex = 0;
    pageNum = 0;
}

//视图初始化
- (void)initView
{
    [super initView];
    [self.view addSubview:self.navigationTabBar];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    __weak HeUserFavouriteVC *weakSelf = self;
    //下拉刷新的回调
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
        [weakSelf loadNurseData];
    }];
    //上拉加载更多回调
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
        [weakSelf loadNurseData];
        
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

//加载用户关注的数据
- (void)loadNurseData
{
    [self showHudInView:tableview hint:@"加载中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/follow/selectfollowbyfollowid.action",BASEURL];
    NSMutableString *followId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    //followId：关注人的ID pageNum：当前的页码
    NSDictionary * params  = @{@"followId":followId,@"pageNum":pageNumStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                jsonArray = [NSArray array];
            }
            if (pageNum == 0) {
                [dataSource removeAllObjects];
            }
            if (pageNum > 0 && [jsonArray count] == 0) {
                pageNum--;
            }
            [dataSource addObjectsFromArray:jsonArray];
            
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                imageview.frame = CGRectMake(100, 100, imageW, imageH);
                imageview.center = bgView.center;
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
            }
            else{
                tableview.backgroundView = nil;
            }
            
            [tableview reloadData];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
            [tableview reloadData];
        }
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

//加载关注的服务
- (void)loadServiceData
{
    [self showHudInView:tableview hint:@"加载中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/follow/selectcollects.action",BASEURL];
    NSMutableString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",servicePageNum];
    //userId：用户的ID pageNum：当前页码
    NSDictionary * params  = @{@"userId":userId,@"pageNum":pageNumStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                jsonArray = [NSArray array];
            }
            if (servicePageNum == 0) {
                [_serviceItemArray removeAllObjects];
            }
            if (servicePageNum > 0 && [jsonArray count] == 0) {
                servicePageNum--;
            }
            [_serviceItemArray addObjectsFromArray:jsonArray];
            
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                imageview.frame = CGRectMake(100, 100, imageW, imageH);
                imageview.center = bgView.center;
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
            }
            else{
                tableview.backgroundView = nil;
            }
            
            [tableview reloadData];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
            [tableview reloadData];
        }
    } failure:^(NSError* err){
        [tableview reloadData];
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentIndex == 1) {
        return [_serviceItemArray count];
    }
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
    
    if (currentIndex == 1) {
        //收藏服务的模板
        CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
        static NSString *cellIndentifier = @"HeServiceTableCell";
        HeServiceTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[HeServiceTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
        }
        NSDictionary *dict = nil;
        @try {
            dict = _serviceItemArray[row];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        __weak HeUserFavouriteVC *weakSelf = self;
        cell.booklBlock = ^{
            [weakSelf bookServiceWithDict:dict];
        };
        
        
        NSString *contentImgurl = dict[@"imgUrl"];
        if ([contentImgurl isMemberOfClass:[NSNull class]] || contentImgurl == nil) {
            contentImgurl = @"";
        }
        NSRange range = [contentImgurl rangeOfString:@","];
        NSString *str = [contentImgurl substringToIndex:range.location];
        contentImgurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,str];
        NSString *imageKey = [NSString stringWithFormat:@"%ld%ld_%@_service",section,row,contentImgurl];
        UIImageView *imageview = [_imageCache objectForKey:imageKey];
        if (!imageview) {
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:contentImgurl] placeholderImage:[UIImage imageNamed:@"index2"]];
            imageview = cell.userImage;
            [_imageCache setObject:imageview forKey:imageKey];
        }
        [cell.userImage removeFromSuperview];
        cell.userImage = imageview;
        [cell addSubview:cell.userImage];
        
        NSString *manageNursingContentName = dict[@"contentName"];
        if ([manageNursingContentName isMemberOfClass:[NSNull class]] || manageNursingContentName == nil) {
            manageNursingContentName = @"";
        }
        cell.serviceTitleLabel.text = manageNursingContentName;
        
        NSString *manageNursingContentContent = dict[@"content"];
        if ([manageNursingContentContent isMemberOfClass:[NSNull class]] || manageNursingContentContent == nil) {
            manageNursingContentContent = @"";
        }
        cell.peopleLabel.text = manageNursingContentContent;
        
        id contentRequired = dict[@"contentRequired"];
        if ([contentRequired isMemberOfClass:[NSNull class]]) {
            contentRequired = @"";
        }
        cell.numberLabel.hidden = YES;
        cell.numberLabel.text = [NSString stringWithFormat:@"已服务:  %ld次",[contentRequired integerValue]];
        
        id minMoney = dict[@"minMoney"];
        if ([minMoney isMemberOfClass:[NSNull class]]) {
            minMoney = @"";
        }
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[minMoney floatValue]];
        
        
        
        return cell;
    }
    static NSString *cellIndentifier = @"HeInfoTableViewCell";
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    //关注护士的模板
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    HeSearchNurseTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeSearchNurseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    NSString *nurseHeader = dict[@"nurseHeader"];
    if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
        nurseHeader = @"";
    }
    nurseHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,nurseHeader];
    NSString *nurseHeaderKey = [NSString stringWithFormat:@"%ld%ld_%@_nurse",section,row,nurseHeader];
    UIImageView *imageview = [_imageCache objectForKey:nurseHeaderKey];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:nurseHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
        imageview = cell.userImage;
    }
    cell.userImage = imageview;
    [cell insertSubview:cell.userImage atIndex:0];
    
    NSString *nurseNick = dict[@"nurseNick"];
    if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
        nurseNick = @"";
    }
    cell.nameLabel.text = nurseNick;
    
    NSString *nurseWorkUnit = dict[@"nurseWorkUnit"];
    if ([nurseWorkUnit isMemberOfClass:[NSNull class]] || nurseWorkUnit == nil) {
        nurseWorkUnit = @"";
    }
    cell.hospitalLabel.text = nurseWorkUnit;
    
    NSString *nurseNote = dict[@"nurseNote"];
    if ([nurseNote isMemberOfClass:[NSNull class]] || nurseNote == nil) {
        nurseNote = @"";
    }
    cell.addresssLabel.text = nurseNote;
    
    CGFloat distance = [dict[@"distance"] floatValue] / 1000.0;
    NSString *distanceStr = [NSString stringWithFormat:@"%.2fkm",distance];
    CGSize distanceSize = [MLLabel getViewSizeByString:distanceStr maxWidth:cell.addresssLabel.frame.size.width font:cell.distanceLabel.font lineHeight:1.2f lines:0];
    
    CGRect distanceFrame = cell.distanceLabel.frame;
    
    
    distanceFrame.size.width = distanceSize.width + 30;
    CGFloat distanceLabelX = SCREENWIDTH - distanceFrame.size.width - 10;
    distanceFrame.origin.x = distanceLabelX;
    cell.distanceLabel.frame = distanceFrame;
    cell.distanceLabel.text = distanceStr;
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    return 100;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (currentIndex == 1) {
        //如果是收藏的是服务，不用跳转
        return;
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSString *nurseId = dict[@"followBefollowid"];
    if ([nurseId isMemberOfClass:[NSNull class]]) {
        nurseId = @"";
    }
    //护士详情
    NSMutableDictionary *nurseDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [nurseDict setObject:nurseId forKey:@"nurseId"];
    HeNurseDetailVC *nurseDetailVC = [[HeNurseDetailVC alloc] init];
    nurseDetailVC.nurseDictInfo = [[NSDictionary alloc] initWithDictionary:nurseDict];
    nurseDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nurseDetailVC animated:YES];
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
    NSMutableDictionary *serviceDict = [[NSMutableDictionary alloc] initWithCapacity:0];
//    manageNursingContentId
    NSString *collectionContentid = dict[@"collectionContentid"];
    if ([collectionContentid isMemberOfClass:[NSNull class]] || collectionContentid == nil) {
        collectionContentid = @"";
    }
    [serviceDict setObject:collectionContentid forKey:@"contentId"];
    
//    manageNursingContentCreatetime
    NSString *collectionCreatime = dict[@"collectionCreatime"];
    if ([collectionCreatime isMemberOfClass:[NSNull class]] || collectionCreatime == nil) {
        collectionCreatime = @"";
    }
    [serviceDict setObject:collectionCreatime forKey:@"manageNursingContentCreatetime"];
    
//    manageNursingContentContent
    NSString *content = dict[@"content"];
    if ([content isMemberOfClass:[NSNull class]] || content == nil) {
        content = @"";
    }
    [serviceDict setObject:content forKey:@"manageNursingContentContent"];
    
//    manageNursingContentName
    NSString *contentName = dict[@"contentName"];
    if ([contentName isMemberOfClass:[NSNull class]] || contentName == nil) {
        contentName = @"";
    }
    [serviceDict setObject:contentName forKey:@"manageNursingContentName"];
    
//    contentImgurl
    NSString *imgUrl = dict[@"imgUrl"];
    if ([imgUrl isMemberOfClass:[NSNull class]] || imgUrl == nil) {
        imgUrl = @"";
    }
    [serviceDict setObject:imgUrl forKey:@"contentImgurl"];
    
    NSString *minMoney = dict[@"minMoney"];
    if ([minMoney isMemberOfClass:[NSNull class]] || minMoney == nil) {
        minMoney = @"";
    }
    [serviceDict setObject:minMoney forKey:@"minMoney"];
    
    NSString *nurseId = @"";
    NSDictionary *nurseDict = @{@"nurseId":nurseId};
    NSDictionary *paramDict = @{@"service":serviceDict,@"nurse":nurseDict};
    
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH) withTitles:@[@"商品",@"详情",@"评论"] withViewControllers:@[@"HeServiceDetailVC",@"HeServiceInfoVC",@"HeCommentVC"] withParameters:@[paramDict,serviceDict,serviceDict]];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return TRUE;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return UITableViewCellEditingStyleDelete;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        
        if (currentIndex == 0) {
            UIAlertController *alertContrller = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否取消对该护士的关注？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
            }];
            UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                NSDictionary *dict = dataSource[indexPath.row];
                [self showHudInView:tableview hint:@"取消中..."];
                NSString *requestUrl = [NSString stringWithFormat:@"%@/follow/delectfollowbyid.action",BASEURL];
                NSString *followId = dict[@"followId"];
                if ([followId isMemberOfClass:[NSNull class]] || followId == nil) {
                    followId = @"";
                }
                NSDictionary * params  = @{@"followId":followId};
                [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
                    [self hideHud];
                    NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
                    NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
                    if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
//                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
                        [dataSource removeObjectAtIndex:indexPath.row];
                        [tableView reloadData];
                    }
                    else{
                        NSString *data = respondDict[@"data"];
                        if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                            data = ERRORREQUESTTIP;
                        }
                        [self showHint:data];
                    }
                } failure:^(NSError* err){
                    [self hideHud];
                    [self showHint:ERRORREQUESTTIP];
                }];
                
                
            }];
            [alertContrller addAction:cancelAction];
            [alertContrller addAction:commitAction];
            [self presentViewController:alertContrller animated:YES completion:nil];
            return;
        }
        else{
            UIAlertController *alertContrller = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否取消对该服务的收藏？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                
            }];
            UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                [self showHudInView:tableview hint:@"取消中..."];
                NSString *requestUrl = [NSString stringWithFormat:@"%@/follow/delectcollectsbyid.action",BASEURL];
                NSDictionary *dict = _serviceItemArray[indexPath.row];
                
                NSString *collectionId = dict[@"collectionId"];
                if ([collectionId isMemberOfClass:[NSNull class]] || collectionId == nil) {
                    collectionId = @"";
                }
                NSDictionary * params  = @{@"collectId":collectionId};
                [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
                    [self hideHud];
                    NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
                    NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
                    if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
//                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
                        [_serviceItemArray removeObjectAtIndex:indexPath.row];
                        [tableView reloadData];
                    }
                    else{
                        NSString *data = respondDict[@"data"];
                        if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                            data = ERRORREQUESTTIP;
                        }
                        [self showHint:data];
                    }
                } failure:^(NSError* err){
                    [self hideHud];
                    [self showHint:ERRORREQUESTTIP];
                }];
                
                
            }];
            [alertContrller addAction:cancelAction];
            [alertContrller addAction:commitAction];
            [self presentViewController:alertContrller animated:YES completion:nil];
        }
        
    }
    
}

- (void)backItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
