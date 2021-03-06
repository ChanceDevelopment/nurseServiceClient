//
//  MyViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//  用户个人中心视图控制器

#import "MyViewController.h"
#import "Tools.h"
#import "HeBaseIconTitleTableCell.h"
#import "HeUserPointVC.h"
#import "HeUserCouponVC.h"
#import "HeUserBalanceVC.h"
#import "HeUserInfoVC.h"
#import "HeProtectedUserInfoVC.h"
#import "HeUserOrderVC.h"
#import "HeUserFavouriteVC.h"
#import "HeUserInviteVC.h"
#import "HeAboutUsVC.h"
#import "HeReportVC.h"
#import "HePointMarketVC.h"
#import "HeMessageVC.h"
#import "HeModifyPasswordVC.h"
#import "RDVTabBarItem.h"
#import "AppDelegate.h"
#import "HeTabBarVC.h"
#import "RESideMenu.h"
#import "MJRefreshNormalHeader.h"


#define InviteLabelTag 100
#define SignButtonTag 200
#define USERIMAGETAG 300
#define USERNAMELABELTAG 400

@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray *iconArr;
    NSArray *tableItemArr;
    UIImageView *portrait;        //头像
    UILabel *userNameL;       //用户名
    NSArray *viewControllerArray;
}
@property(strong,nonatomic)IBOutlet UITableView *myTableView;
@property(strong,nonatomic)UILabel *balanceNumLabel;
@property(strong,nonatomic)UILabel *couponNumLabel;
@property(strong,nonatomic)UILabel *pointNumLabel;
@property(strong,nonatomic)User *userInfoModel;

@end

@implementation MyViewController
@synthesize myTableView;
@synthesize balanceNumLabel;
@synthesize couponNumLabel;
@synthesize pointNumLabel;
@synthesize userInfoModel;

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
        label.text = @"我的";
        [label sizeToFit];
        self.title = @"我的";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialization];
    [self initView];
    [self loadUserOtherInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //本界面导航栏隐藏
    self.navigationController.navigationBarHidden = YES;
    [self loadOrderData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    //虽然本界面导航栏隐藏，但不能影响其他界面导航栏的显示
    self.navigationController.navigationBarHidden = NO;
}

- (void)initialization
{
    [super initializaiton];
    //初始化各种资源
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserBalanceInfo:) name:kUpdateUserPayInfoNotificaiton object:nil];
    iconArr = @[@"icon_protected_person_gray",@"icon_report_gray",@"icon_favorites_gray",@"icon_myinvite_gray",@"icon_advice_gray",@"icon_aboutus_gray",@"icon_advice_gray"];
    tableItemArr = @[@"受护人信息",@"护理报告",@"收藏夹",@"我的邀请",@"修改密码",@"关于我们",@"投诉建议"];
    viewControllerArray = @[@"HeProtectedUserInfoVC",@"HeOrderReportVC",@"HeUserFavouriteVC",@"HeUserInviteVC",@"HeModifyPasswordVC",@"HeAboutUsVC",@"HeReportVC"];
    userInfoModel = [HeSysbsModel getSysModel].user;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:kUpdateUserInfoNotification object:nil];

}

//初始化视图
- (void)initView
{
    [super initView];
    self.view.backgroundColor = [UIColor whiteColor];

    myTableView.backgroundView = nil;
    myTableView.backgroundColor = [UIColor clearColor];
    [Tools setExtraCellLineHidden:myTableView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:myTableView];

    //列表的头部用户信息
    CGFloat viewHeight = 300;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, SCREENWIDTH, viewHeight);
    headerView.backgroundColor = APPDEFAULTORANGE;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgImageView.image = [UIImage imageNamed:@"img_bg.png"];
    [headerView addSubview:bgImageView];
    
    UIImage *messageImage = [UIImage imageNamed:@"icon_infromation"];
    CGFloat messageButtonW = 25;
    CGFloat messageButtonH = messageImage.size.height / messageImage.size.width * messageButtonW;
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - messageButtonW - 20, 30, messageButtonW, messageButtonH)];
    [messageButton setImage:messageImage forState:UIControlStateNormal];
    [headerView addSubview:messageButton];
    [messageButton addTarget:self action:@selector(messageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *securityImage = [UIImage imageNamed:@"icon_eye_open_white"];
    CGFloat securityButtonW = 30;
    CGFloat securityButtonH = securityImage.size.height / securityImage.size.width * securityButtonW;
    UIButton *securityButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - securityButtonW - 18, CGRectGetMaxY(messageButton.frame) + 10, securityButtonW, securityButtonH)];
    [securityButton setImage:securityImage forState:UIControlStateNormal];
    [securityButton setImage:[UIImage imageNamed:@"icon_eye_close_white"] forState:UIControlStateSelected];
    [headerView addSubview:securityButton];
    securityButton.tag = 3000;
    [securityButton addTarget:self action:@selector(securityButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    //头像
    CGFloat imageDia = 70;              //直径
    CGFloat imageX = (SCREENWIDTH - imageDia) / 2.0 ;
    CGFloat imageY = (viewHeight - imageDia) / 2.0 - 20;
    portrait = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageDia, imageDia)];
    portrait.tag = USERIMAGETAG;
    portrait.userInteractionEnabled = YES;
    portrait.image = [UIImage imageNamed:@"defalut_icon"];
    portrait.layer.borderWidth = 0.0;
    portrait.contentMode = UIViewContentModeScaleAspectFill;
    portrait.layer.cornerRadius = imageDia / 2.0;
    portrait.layer.masksToBounds = YES;
    [headerView addSubview:portrait];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserInfo:)];
    [portrait addGestureRecognizer:tap];

    NSString *userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userInfoModel.userHeader];
    [portrait sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
    
    [self.view addSubview:headerView];
//    myTableView.tableHeaderView = headerView;
    
    
    //用户名
    CGFloat labelX = 0;
    CGFloat labelY = imageY+imageDia;
    CGFloat labelH = 25;
    CGFloat labelW = SCREENWIDTH;
    
    userNameL = [[UILabel alloc] init];
    userNameL.tag = USERNAMELABELTAG;
    userNameL.textAlignment = NSTextAlignmentCenter;
    userNameL.backgroundColor = [UIColor clearColor];
    userNameL.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    userNameL.textColor = [UIColor whiteColor];
    userNameL.frame = CGRectMake(labelX, labelY, labelW, labelH);
    [headerView addSubview:userNameL];
    
    NSString *nickName = userInfoModel.userNick;
    userNameL.text = nickName;
    //积分
   
    //签到按钮
    CGFloat buttonW = 50;
    CGFloat buttonH = 20;
    CGFloat buttonX = CGRectGetMaxX(portrait.frame) + 10;
    CGFloat buttonY = CGRectGetMinY(portrait.frame) + ((CGRectGetHeight(portrait.frame) - buttonH) / 2.0);
    UIButton *signBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    signBtn.backgroundColor = [UIColor clearColor];
    signBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    signBtn.tag = SignButtonTag;
    signBtn.layer.cornerRadius = 4.0;//2.0是圆角的弧度，根据需求自己更改
    signBtn.layer.borderWidth = 1.0f;//设置边框颜色
    signBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    [signBtn setTitle:@"签到" forState:UIControlStateNormal];
    [signBtn addTarget:self action:@selector(toSignInView) forControlEvents:UIControlEventTouchUpInside];
//    [headerView addSubview:signBtn];
    
    CGFloat otherInfoLabelBGX = 0;
    CGFloat otherInfoLabelBGH = 60;
    CGFloat otherInfoLabelBGY = viewHeight - otherInfoLabelBGH;
    CGFloat otherInfoLabelBGW = SCREENWIDTH;
    UILabel *otherInfoLabelBG = [[UILabel alloc] initWithFrame:CGRectMake(otherInfoLabelBGX, otherInfoLabelBGY, otherInfoLabelBGW, otherInfoLabelBGH)];
    otherInfoLabelBG.userInteractionEnabled = YES;
    otherInfoLabelBG.backgroundColor = [UIColor clearColor];
    [headerView addSubview:otherInfoLabelBG];
    
    CGFloat commonlabelX = 0;
    CGFloat commonlabelW = SCREENWIDTH / 3.0;
    CGFloat commonlabelH = otherInfoLabelBGH;
    CGFloat commonlabelY = 0;
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonlabelX, commonlabelY, commonlabelW, commonlabelH)];
    moneyLabel.backgroundColor = [UIColor clearColor];
    moneyLabel.userInteractionEnabled = YES;
    [otherInfoLabelBG addSubview:moneyLabel];
    
    CGFloat balance = [userInfoModel.userBalance floatValue];
    balanceNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, commonlabelW, otherInfoLabelBGH / 2.0)];
    balanceNumLabel.backgroundColor = [UIColor clearColor];
    
    balanceNumLabel.text = [NSString stringWithFormat:@"%.2f元",balance];
    if (balance > 100000000) {
        balance = balance / 100000000.0;
        balanceNumLabel.text = [NSString stringWithFormat:@"%.2f亿元",balance];
    }
    else if (balance > 10000){
        balance = balance / 10000.0;
        balanceNumLabel.text = [NSString stringWithFormat:@"%.2f万元",balance];
    }
    
    balanceNumLabel.font = [UIFont systemFontOfSize:17.0];
    balanceNumLabel.textAlignment = NSTextAlignmentCenter;
    balanceNumLabel.textColor = [UIColor colorWithRed:179.0 / 255.0 green:68.0 / 255.0 blue:65.0 / 255.0 alpha:1.0];
    [moneyLabel addSubview:balanceNumLabel];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, otherInfoLabelBGH / 2.0, commonlabelW, otherInfoLabelBGH / 2.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"我的余额";
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [moneyLabel addSubview:titleLabel];
    
    UITapGestureRecognizer *moneyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserBalance:)];
    moneyTap.numberOfTapsRequired = 1;
    moneyTap.numberOfTouchesRequired = 1;
    [moneyLabel addGestureRecognizer:moneyTap];
    
    commonlabelX = CGRectGetMaxX(moneyLabel.frame);
    UILabel *couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonlabelX, commonlabelY, commonlabelW, commonlabelH)];
    couponLabel.backgroundColor = [UIColor clearColor];
    couponLabel.userInteractionEnabled = YES;
    [otherInfoLabelBG addSubview:couponLabel];
    //优惠券
    NSInteger couponNum = [userInfoModel.couponCount integerValue];
    couponNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, commonlabelW, otherInfoLabelBGH / 2.0)];
    couponNumLabel.backgroundColor = [UIColor clearColor];
    couponNumLabel.text = [NSString stringWithFormat:@"%ld张",couponNum];
    couponNumLabel.font = [UIFont systemFontOfSize:17.0];
    couponNumLabel.textAlignment = NSTextAlignmentCenter;
    couponNumLabel.textColor = [UIColor colorWithRed:133.0 / 255.0 green:144.0 / 255.0 blue:205.0 / 255.0 alpha:1.0];
    [couponLabel addSubview:couponNumLabel];
    
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, otherInfoLabelBGH / 2.0, commonlabelW, otherInfoLabelBGH / 2.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"优惠券";
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [couponLabel addSubview:titleLabel];
    
    UITapGestureRecognizer *couponTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserCoupon:)];
    couponTap.numberOfTapsRequired = 1;
    couponTap.numberOfTouchesRequired = 1;
    [couponLabel addGestureRecognizer:couponTap];
    
    commonlabelX = CGRectGetMaxX(couponLabel.frame);
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonlabelX, commonlabelY, commonlabelW, commonlabelH)];
    pointLabel.backgroundColor = [UIColor clearColor];
    pointLabel.userInteractionEnabled = YES;
    [otherInfoLabelBG addSubview:pointLabel];
    
//    NSInteger point = [userInfoModel.userMark integerValue];
    //未支付的订单
    pointNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, commonlabelW, otherInfoLabelBGH / 2.0)];
    pointNumLabel.backgroundColor = [UIColor clearColor];
//    pointNumLabel.text = [NSString stringWithFormat:@"%ld单",point];
    pointNumLabel.text = @" 单";
    pointNumLabel.font = [UIFont systemFontOfSize:17.0];
    pointNumLabel.textAlignment = NSTextAlignmentCenter;
    pointNumLabel.textColor = [UIColor colorWithRed:69.0 / 255.0 green:139.0 / 255.0 blue:84.0 / 255.0 alpha:1.0];
    [pointLabel addSubview:pointNumLabel];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, otherInfoLabelBGH / 2.0, commonlabelW, otherInfoLabelBGH / 2.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"我的待支付";
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [pointLabel addSubview:titleLabel];
    
    UITapGestureRecognizer *pointTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserPoint:)];
    pointTap.numberOfTapsRequired = 1;
    pointTap.numberOfTouchesRequired = 1;
    [pointLabel addGestureRecognizer:pointTap];
    
    CGFloat footHeight = 100;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, footHeight)];
    myTableView.tableFooterView = footerView;
    
    NSString *inviteCode = userInfoModel.userInvitationcode;
    //邀请码
    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, footHeight / 2.0)];
    inviteLabel.font = [UIFont systemFontOfSize:18.0];
    inviteLabel.tag = InviteLabelTag;
    inviteLabel.backgroundColor = [UIColor clearColor];
    inviteLabel.textColor = [UIColor blackColor];
    inviteLabel.textAlignment = NSTextAlignmentCenter;
    inviteLabel.text = [NSString stringWithFormat:@"邀请码: %@",inviteCode];
    [footerView addSubview:inviteLabel];
    
    UIButton *signOutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, footHeight / 2.0, SCREENWIDTH, footHeight / 2.0)];
    [signOutButton setBackgroundColor:APPDEFAULTORANGE];
    [signOutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    signOutButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOutButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:signOutButton];
    
    //上拉刷新回调
    __weak MyViewController *weakSelf = self;
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.myTableView.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        
        [weakSelf getUserInfoWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY]];
        [weakSelf getUserPayInfo];
    }];
    
    
}

//更新用户的资源通知
- (void)updateUserInfo:(NSNotification *)notification
{
    //获取用户最新的资料
    [self getUserInfoWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY]];
}

//更新用户的余额信息通知
- (void)updateUserBalanceInfo:(NSNotification *)notification
{
    //获取用户的余额信息
    [self getUserPayInfo];
}

//获取用户的余额信息
- (void)getUserPayInfo
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    //userId：用户的ID
    NSDictionary * params  = @{@"userId":userId};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectUserThreeInfo.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSDictionary *payInfo = respondDict[@"json"];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:payInfo];
            NSArray *keyArray = dict.allKeys;
            for (NSString *key in keyArray) {
                id obj = dict[key];
                if ([obj isMemberOfClass:[NSNull class]] || obj == nil) {
                    obj = @"";
                }
                [dict setObject:obj forKey:key];
            }
            payInfo = [[NSDictionary alloc] initWithDictionary:dict];
            NSString *balance = [payInfo objectForKey:kPayBalance];
            if ([balance isMemberOfClass:[NSNull class]]) {
                balance = @"";
            }
            //刷新余额区域的显示
            CGFloat balanceMoney = [balance floatValue];
//            _balanceLabel.text = [NSString stringWithFormat:@"%@元",balance];
            [[NSUserDefaults standardUserDefaults] setObject:payInfo forKey:kUserPayInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIButton *securityButton = [self.view viewWithTag:3000];
            
            if (securityButton.selected) {
                balanceNumLabel.text = @"***元";
                couponNumLabel.text = @"***张";
                pointNumLabel.text = @"***单";
            }
            else{
                CGFloat balance = [userInfoModel.userBalance floatValue];
                NSInteger couponNum = [userInfoModel.couponCount integerValue];
                NSInteger point = [userInfoModel.userMark integerValue];
                
                balanceNumLabel.text = [NSString stringWithFormat:@"%.2f元",balance];
                if (balance > 100000000) {
                    balance = balance / 100000000.0;
                    balanceNumLabel.text = [NSString stringWithFormat:@"%.2f亿元",balance];
                }
                else if (balance > 10000){
                    balance = balance / 10000.0;
                    balanceNumLabel.text = [NSString stringWithFormat:@"%.2f万元",balance];
                }
                
                couponNumLabel.text = [NSString stringWithFormat:@"%ld张",couponNum];
                NSLog(@"%ld",(long)point);
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *PointNumLabel = [user objectForKey:@"pointNumLabel"];
                pointNumLabel.text = [NSString stringWithFormat:@"%@",PointNumLabel];
                
            }
        }
        
    } failure:^(NSError* err){
        
    }];
}


/*
 @brief 获取用户的信息
 @param userid 用户的ID
 */
- (void)getUserInfoWithUserID:(NSString *)userid
{
    if (!userid) {
        userid = @"";
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectuserinfobyid.action",BASEURL];
    NSDictionary * params  = @{@"userid":userid};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSDictionary *userDetailInfoDict = respondDict[@"json"];
            if ([userDetailInfoDict isMemberOfClass:[NSNull class]]) {
                return;
            }
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithCapacity:0];
            
            for (NSString *key in [userDetailInfoDict allKeys]) {
                id obj = [userDetailInfoDict objectForKey:key];
                if ([obj isMemberOfClass:[NSNull class]] || obj == nil) {
                    obj = @"";
                }
                [infoDict setObject:obj forKey:key];
            }
            //保存用户的详细信息
            [[NSUserDefaults standardUserDefaults] setObject:infoDict forKey:kUserDetailDataKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //对用户的数据进行异常处理
            User *userModel = [[User alloc] init];
            for (NSString *keyString in infoDict.allKeys) {
                NSString *firstString = [keyString substringWithRange:NSMakeRange(0, 1)];
                firstString = [firstString uppercaseString];
                NSString *secondString = nil;
                @try {
                    secondString = [keyString substringFromIndex:1];
                } @catch (NSException *exception) {
                    secondString = @"";
                } @finally {
                    
                }
                NSString *methodString = [NSString stringWithFormat:@"set%@%@:",firstString,secondString];
                SEL selector = NSSelectorFromString(methodString);
                if ([userModel respondsToSelector:selector]) {
                    id object = infoDict[keyString];
                    if ([object isMemberOfClass:[NSNull class]]) {
                        object = @"";
                    }
                    [userModel performSelector:selector withObject:object];
                }
            }
//            [userModel setValuesForKeysWithDictionary:infoDict];
            NSLog(@"userModel = %@",userModel);
            //保存到用户信息
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailDataKey];
            [HeSysbsModel getSysModel].user = userModel;
            //刷新视图
            userInfoModel = [HeSysbsModel getSysModel].user;
            NSString *userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userInfoModel.userHeader];
            [portrait sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
            NSString *nickName = userInfoModel.userNick;
            userNameL.text = nickName;
            [myTableView reloadData];
            
            //刷新数据
            UIButton *securityButton = [self.view viewWithTag:3000];
            
            if (securityButton.selected) {
                balanceNumLabel.text = @"***元";
                couponNumLabel.text = @"***张";
                pointNumLabel.text = @"***单";
            }
            else{
                CGFloat balance = [userInfoModel.userBalance floatValue];
                NSInteger couponNum = [userInfoModel.couponCount integerValue];
                NSInteger point = [userInfoModel.userMark integerValue];
                
                balanceNumLabel.text = [NSString stringWithFormat:@"%.2f元",balance];
                if (balance > 100000000) {
                    balance = balance / 100000000.0;
                    balanceNumLabel.text = [NSString stringWithFormat:@"%.2f亿元",balance];
                }
                else if (balance > 10000){
                    balance = balance / 10000.0;
                    balanceNumLabel.text = [NSString stringWithFormat:@"%.2f万元",balance];
                }
                
                couponNumLabel.text = [NSString stringWithFormat:@"%ld张",couponNum];
                NSLog(@"%ld",(long)point);
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *PointNumLabel = [user objectForKey:@"pointNumLabel"];
                pointNumLabel.text = [NSString stringWithFormat:@"%@",PointNumLabel];
                [self.myTableView reloadData];
            }
            [self.myTableView reloadData];
        }
        [self.myTableView reloadData];
    } failure:^(NSError* err){
        
    }];
}

//加载用户的其他信息。比如用户是否签到
- (void)loadUserOtherInfo
{
    //判断用户是否已经签到
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    UIButton *signButton = [myTableView.tableHeaderView viewWithTag:SignButtonTag];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectUserIsSignined.action",BASEURL];
    NSDictionary *params = @{@"userId":userId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        signButton.hidden = NO;
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"respondString:%@",respondString);
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSString *sign = respondDict[@"json"];
        if ([sign compare:@"no" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            //还没签到
            signButton.hidden = NO;
        }
        else{
            [signButton setTitle:@"已签到" forState:UIControlStateNormal];
            [signButton setTitle:@"已签到" forState:UIControlStateSelected];
            signButton.enabled = NO;
        }
        
        
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        signButton.hidden = NO;
    }];
    
}

//查看用户的余额
- (void)scanUserBalance:(UITapGestureRecognizer *)tap
{
    HeUserBalanceVC *userBalanceVC = [[HeUserBalanceVC alloc] init];
    userBalanceVC.userInfo = userInfoModel;
    userBalanceVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userBalanceVC animated:YES];
}

//查看用户的优惠券
- (void)scanUserCoupon:(UITapGestureRecognizer *)tap
{
    HeUserCouponVC *userCouponVC = [[HeUserCouponVC alloc] init];
    userCouponVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userCouponVC animated:YES];
}

//查看用户的未支付订单
- (void)scanUserPoint:(UITapGestureRecognizer *)tap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectOrderNotification" object:@[@"index",@0]];
    NSInteger orderTabbarIndex = 2;
    //跳转到订单界面
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RESideMenu *rootVC =  (RESideMenu *)delegate.window.rootViewController;
    HeTabBarVC *tabbarVC = (HeTabBarVC *)rootVC.mainController;
    [tabbarVC setSelectedIndex:orderTabbarIndex];
}

//查看用户的信息详情
- (void)scanUserInfo:(UITapGestureRecognizer *)tap
{
    HeUserInfoVC *userInfoVC = [[HeUserInfoVC alloc] init];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

//查看站内信
- (void)messageButtonClick:(UIButton *)button
{
    HeMessageVC *messageVC = [[HeMessageVC alloc] init];
    messageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messageVC animated:YES];
}

//显示各种视图的内容的安全按钮
- (void)securityButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        balanceNumLabel.text = @"***元";
        couponNumLabel.text = @"***张";
        pointNumLabel.text = @"***单";
    }
    else{
        CGFloat balance = [userInfoModel.userBalance floatValue];
        NSInteger couponNum = [userInfoModel.couponCount integerValue];
        NSInteger point = [userInfoModel.userMark integerValue];
        
        balanceNumLabel.text = [NSString stringWithFormat:@"%.2f元",balance];
        if (balance > 100000000) {
            balance = balance / 100000000.0;
            balanceNumLabel.text = [NSString stringWithFormat:@"%.2f亿元",balance];
        }
        else if (balance > 10000){
            balance = balance / 10000.0;
            balanceNumLabel.text = [NSString stringWithFormat:@"%.2f万元",balance];
        }
        
        couponNumLabel.text = [NSString stringWithFormat:@"%ld张",couponNum];
        NSLog(@"%ld",(long)point);
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//            NSString *passWord = [ user objectForKey:@"userPassWord"];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *PointNumLabel = [user objectForKey:@"pointNumLabel"];
        pointNumLabel.text = [NSString stringWithFormat:@"%@",PointNumLabel];
        
    }
}

//注销登录点击事件
- (void)signOutButtonClick:(UIButton *)button
{
    if (ISIOS7) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定退出登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 100;
        [alertView show];
        return;
    }
    __weak MyViewController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定退出登录？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [weakSelf signAccount];
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

//注销登录
- (void)signAccount
{
    NSLog(@"signAccount");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERACCOUNTKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERIDKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDataKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDetailDataKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERIDKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERPASSWORDKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserPayInfoKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPayAccount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPayPassword];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPayBalance];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //清空用户的资料
    [HeSysbsModel getSysModel].user = nil;
    
    [Tools initPush];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

//请求接口已签到
- (void)toSignInView
{
    UIButton *signButton = [myTableView.tableHeaderView viewWithTag:SignButtonTag];
    NSLog(@"toSignInView");
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/userToSignin.action",BASEURL];
    NSDictionary *params = @{@"userId":userId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"respondString:%@",respondString);
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [respondDict[@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            //签到成功
            signButton.hidden = NO;
            [signButton setTitle:@"已签到" forState:UIControlStateNormal];
            [signButton setTitle:@"已签到" forState:UIControlStateSelected];
            signButton.enabled = NO;
            [self showHint:@"签到成功"];
        }
        else{
            [signButton setTitle:@"已签到" forState:UIControlStateNormal];
            [signButton setTitle:@"已签到" forState:UIControlStateSelected];
            signButton.enabled = NO;
            NSString *errorInfo = respondDict[@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
        }
        
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 100) {
        [self signAccount];
    }
}

#pragma mark UITableViewdDataSource UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return iconArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    HeBaseIconTitleTableCell *userCell = [tableView cellForRowAtIndexPath:indexPath];
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    if (!userCell) {
        userCell = [[HeBaseIconTitleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSString *title = tableItemArr[row];
    NSString *iconName = iconArr[row];
    
    userCell.topicLabel.text = title;
    userCell.icon.image = [UIImage imageNamed:iconName];
    
    return userCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"row = %ld , section = %ld",row,section);
    
    NSString *viewControllerClass = nil;
    @try {
        viewControllerClass = viewControllerArray[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    id myObj = [[NSClassFromString(viewControllerClass) alloc] init];
    UIViewController *myVC = nil;
    if ([myObj isKindOfClass:[UIViewController class]]) {
        myVC = myObj;
        myVC.hidesBottomBarWhenPushed = YES;
    }
    switch (row) {
        case 0:
        {
            //受护人信息
            
            break;
        }
        case 1:{
            //护理报告
            break;
        }
        case 2:{
            //收藏夹
            break;
        }
        case 3:{
            //我的邀请
            NSString *inviteCode = userInfoModel.userInvitationcode;
            HeUserInviteVC *inviteVC = (HeUserInviteVC *)myVC;
            inviteVC.invitationcode = inviteCode;
            break;
        }
        case 4:{
            //关于我们
            break;
        }
        case 5:{
            //投诉建议
            break;
        }
        default:
            break;
    }
    [self.navigationController pushViewController:myVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma  mark camera
//打开相机,获取照片
-(void)openCamera
{
    if (iOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //取消
        }];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self takePhoto];
        }];
        
        UIAlertAction *libAction = [UIAlertAction actionWithTitle:@"从手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self LocalPhoto];
        }];
        
        // Add the actions.
        [alertController addAction:cameraAction];
        [alertController addAction:libAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                        initWithTitle:nil
                                        delegate:self
                                        cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
        [myActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex){
        
        NSLog(@"取消");
    }
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self LocalPhoto];
            break;
    }
}

//开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}
//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        [picker dismissViewControllerAnimated:YES completion:nil];
        portrait.image = image;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Configuring the view’s layout behavior

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//加载订单数据信息
- (void)loadOrderData
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/OrderSendDescription.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *orderStateStr = [NSString stringWithFormat:@"%d",0];
    NSDictionary * params  = @{@"userId":userId,@"orderState":orderStateStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                jsonArray = [NSArray array];
            }
            NSLog(@"%lu",(unsigned long)jsonArray.count);
            pointNumLabel.text = [NSString stringWithFormat:@"%ld单",jsonArray.count];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:pointNumLabel.text forKey:@"pointNumLabel"];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        NSLog(@"errorInfo = %@",err);
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateUserInfoNotification object:nil];
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
