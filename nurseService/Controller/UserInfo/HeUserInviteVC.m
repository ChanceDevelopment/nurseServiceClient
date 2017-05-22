//
//  HeMessageVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//  邀请用户的视图控制器

#import "HeUserInviteVC.h"
#import "HeBaseTableViewCell.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "HeUserCouponCell.h"
#import "HeUserInviteCell.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

@interface HeUserInviteVC ()<UITableViewDelegate,UITableViewDataSource>
{
    //当前的页码
    NSInteger pageNum;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeUserInviteVC
@synthesize tableview;
@synthesize dataSource;

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
        label.text = @"我的邀请";
        [label sizeToFit];
        self.title = @"我的邀请";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self loadInvite];
}

//初始化资源
- (void)initializaiton
{
    [super initializaiton];
    pageNum = 0;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _imageCache = [[NSCache alloc] init];
}

//初始化视图
- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Tool setExtraCellLineHidden:tableview];
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] init];
    shareItem.title = @"邀好友";
    shareItem.target = self;
    shareItem.action = @selector(inviteFriend);
    self.navigationItem.rightBarButtonItem = shareItem;
    
    __weak HeUserInviteVC *weakSelf = self;
    //下拉刷新回调
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
        [weakSelf loadInvite];
    }];
    //上拉加载更多回调
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
        //加载邀请人数据
        [weakSelf loadInvite];
        
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

//加载邀请人数据
- (void)loadInvite
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/nurseAnduser/selectMyInvitationUserInfo.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    //userId：用户的ID  pageNum：当前页码
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"pageNum":pageNumStr};
    [self showHudInView:self.view hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                resultArray = [NSArray array];
            }
            //如果刷新，清除缓存数据
            if (pageNum == 0) {
                [dataSource removeAllObjects];
            }
            //上拉加载更多如果没数据，恢复参数
            if (pageNum != 0 && [resultArray count] == 0) {
                pageNum--;
            }
            [dataSource addObjectsFromArray:resultArray];
            //如果没有数据，显示没有数据的图片
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
            
            [self.tableview reloadData];
        }
        else{
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
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"";
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

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
    
    static NSString *cellIndentifier = @"HeUserInviteCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    //配置邀请人列表的布局
    HeUserInviteCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeUserInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSString *userHeader = dict[@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]]) {
        userHeader = @"";
    }
    userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    NSString *imagekey = [NSString stringWithFormat:@"%ld_%ld_%@",section,row,userHeader];
    UIImageView *imageview = [_imageCache objectForKey:imagekey];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
        imageview = cell.userImage;
        [_imageCache setObject:imageview forKey:imagekey];
    }
    cell.userImage = imageview;
    [cell.nameLabel.superview addSubview:cell.userImage];
    
    NSString *userNick = dict[@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.nameLabel.text = userNick;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

//邀请朋友
- (void)inviteFriend
{
    //商品的分享
    NSString *titleStr = @"专业护士上门";
    NSString *imagePath = [NSString stringWithFormat:@"%@nurseDoor/img/index2.png",PIC_URL]; //图片的链接地址
    NSString *url = [NSString stringWithFormat:@"%@nurseDoor/fenxiang_user.jsp?invitationcode=%@",PIC_URL,_invitationcode];
    NSString *content = @"我在这里邀请你的加入";
    //构造分享内容
    /***新版分享***/
    //1、创建分享参数（必要）2/6/22/23/24/37
    //    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSArray* imageArray = @[[NSURL URLWithString:imagePath]];
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:content
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:titleStr
                                           type:SSDKContentTypeAuto];
        
        [ShareSDK showShareActionSheet:nil
                                 items:@[
                                         @(SSDKPlatformSubTypeQZone),
                                         @(SSDKPlatformSubTypeWechatSession),
                                         @(SSDKPlatformSubTypeWechatTimeline),
                                         @(SSDKPlatformSubTypeQQFriend),
                                         @(SSDKPlatformSubTypeWechatFav)]
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       NSLog(@"error:%@",error.userInfo);
                       switch (state) {
                               
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateCancel:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           default:
                               break;
                       }
                       
                       if (state != SSDKResponseStateBegin)
                       {
                           
                       }
                       
                   }];
    }
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
