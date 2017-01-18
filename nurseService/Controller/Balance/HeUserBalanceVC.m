//
//  HeUserBalanceVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserBalanceVC.h"
#import "HeBaseTableViewCell.h"
#import "HeBalanceDetailVC.h"
#import "HeSettingPayPasswordVC.h"
#import "HeBalanceEditVC.h"

#define ALERTTAG 500

@interface HeUserBalanceVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UILabel *balanceLabel;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)NSDictionary *userPayInfo;

@property(strong,nonatomic)UIView *dismissView;

@end

@implementation HeUserBalanceVC
@synthesize balanceLabel;
@synthesize tableview;
@synthesize dataSource;
@synthesize iconDataSource;
@synthesize userInfo;
@synthesize userPayInfo;
@synthesize dismissView;

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
        label.text = @"我的资金";
        [label sizeToFit];
        self.title = @"我的资金";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getUserPayInfo];
}

- (void)initializaiton
{
    [super initializaiton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserPayInfo) name:kUpdateUserPayInfoNotificaiton object:nil];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    dataSource = @[@[@"提现",@"充值",@"绑定支付宝",@"设置支付密码",@"交易明细"]];
    iconDataSource = @[@[@"icon_recharge",@"icon_withdrawals",@"icon_bind_alipay",@"icon_set_paypwd",@"icon_financial_details"]];
    userPayInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPayInfoKey];
}

- (void)initView
{
    [super initView];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    
    CGFloat balanceNum = [userInfo.userBalance floatValue];
    balanceLabel.text = [NSString stringWithFormat:@"%.2f元",balanceNum];
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
}

- (void)getUserPayInfo
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary * params  = @{@"userId":userId};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectUserThreeInfo.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hidesBottomBarWhenPushed];
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
            balanceLabel.text = [NSString stringWithFormat:@"%@元",balance];
            [[NSUserDefaults standardUserDefaults] setObject:payInfo forKey:kUserPayInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    } failure:^(NSError* err){
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeUserCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGFloat iconH = 25;
    CGFloat iconW = 25;
    CGFloat iconX = 10;
    CGFloat iconY = (cellSize.height - iconH) / 2.0;
    NSString *image = iconDataSource[section][row];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [cell.contentView addSubview:icon];
    
    NSString *title = dataSource[section][row];
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = iconX + iconW + 10;
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    CGFloat titleW = 200;
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textAlignment = NSTextAlignmentLeft;
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.text = title;
    topicLabel.numberOfLines = 0;
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = textFont;
    topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [cell.contentView addSubview:topicLabel];
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSLog(@"row = %ld, section = %ld",row,section);
    NSString *alipayAccountInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserPayInfoKey] objectForKey:kPayAccount];
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0:
                {
                    //提现
                    if ([alipayAccountInfo isMemberOfClass:[NSNull class]] || alipayAccountInfo == nil || [alipayAccountInfo isEqualToString:@""]) {
                        alipayAccountInfo = @"";
                        [self alertBindAccount];
                    }
                    CGFloat maxWithDrawMoney = [[userPayInfo objectForKey:kPayBalance] doubleValue];
                    HeBalanceEditVC *recharegeVC = [[HeBalanceEditVC alloc] init];
                    recharegeVC.banlanceType = Balance_Edit_Withdraw;
                    recharegeVC.maxWithDrawMoney = maxWithDrawMoney;
                    recharegeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:recharegeVC animated:YES];
                    break;
                }
                case 1:
                {
                    //充值
                    if ([alipayAccountInfo isMemberOfClass:[NSNull class]] || alipayAccountInfo == nil || [alipayAccountInfo isEqualToString:@""]) {
                        alipayAccountInfo = @"";
                        [self alertBindAccount];
                    }
                    //充值
                    HeBalanceEditVC *recharegeVC = [[HeBalanceEditVC alloc] init];
                    recharegeVC.banlanceType = Balance_Edit_Recharge;
                    recharegeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:recharegeVC animated:YES];
                    break;
                }
                case 2:
                {
                    //绑定支付宝
                    if ([alipayAccountInfo isMemberOfClass:[NSNull class]] || alipayAccountInfo == nil || [alipayAccountInfo isEqualToString:@""]) {
                        alipayAccountInfo = @"";
                        [self alertBindAccount];
                    }
                    break;
                }
                case 3:
                {
                    //设置支付宝密码
                    HeSettingPayPasswordVC *settingPayPasswordVC = [[HeSettingPayPasswordVC alloc] init];
                    settingPayPasswordVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:settingPayPasswordVC animated:YES];
                    break;
                }
                case 4:
                {
                    //设置明细
                    HeBalanceDetailVC *balanceDetailVC = [[HeBalanceDetailVC alloc] init];
                    balanceDetailVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:balanceDetailVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    
}

- (void)dismissViewGes:(UITapGestureRecognizer *)ges
{
    
    UIView *mydismissView = ges.view;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    [alertview removeFromSuperview];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)alertBindAccount
{
    [self.view addSubview:dismissView];
    dismissView.hidden = NO;
    
    CGFloat viewX = 10;
    CGFloat viewY = 100;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = 150;
    UIView *shareAlert = [[UIView alloc] init];
    shareAlert.frame = CGRectMake(viewX, viewY, viewW, viewH);
    shareAlert.backgroundColor = [UIColor whiteColor];
    shareAlert.layer.cornerRadius = 5.0;
    shareAlert.layer.borderWidth = 0;
    shareAlert.layer.masksToBounds = YES;
    shareAlert.tag = ALERTTAG;
    shareAlert.layer.borderColor = [UIColor clearColor].CGColor;
    shareAlert.userInteractionEnabled = YES;
    
    CGFloat labelH = 40;
    CGFloat labelY = 0;
    
    UIFont *shareFont = [UIFont systemFontOfSize:13.0];
    
    UILabel *messageTitleLabel = [[UILabel alloc] init];
    messageTitleLabel.font = shareFont;
    messageTitleLabel.textColor = [UIColor blackColor];
    messageTitleLabel.textAlignment = NSTextAlignmentCenter;
    messageTitleLabel.backgroundColor = [UIColor clearColor];
    messageTitleLabel.text = @"绑定支付宝";
    messageTitleLabel.frame = CGRectMake(0, 0, viewW, labelH);
    [shareAlert addSubview:messageTitleLabel];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logoImage"]];
    logoImage.frame = CGRectMake(20, 5, 30, 30);
    [shareAlert addSubview:logoImage];
    
    
    labelY = labelY + labelH + 10;
    UITextField *textview = [[UITextField alloc] init];
    textview.tag = 10;
    textview.backgroundColor = [UIColor whiteColor];
    textview.placeholder = @"请输入支付宝账号";
    textview.font = shareFont;
    textview.delegate = self;
    textview.frame = CGRectMake(10, labelY, shareAlert.frame.size.width - 20, labelH);
    textview.layer.borderWidth = 1.0;
    textview.layer.cornerRadius = 5.0;
    textview.layer.masksToBounds = YES;
    textview.layer.borderColor = [UIColor colorWithWhite:0xcc / 255.0 alpha:1.0].CGColor;
    [shareAlert addSubview:textview];
    
    CGFloat buttonDis = 10;
    CGFloat buttonW = (viewW - 3 * buttonDis) / 2.0;
    CGFloat buttonH = 40;
    CGFloat buttonY = labelY = labelY + labelH + 10;
    CGFloat buttonX = 10;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [shareButton setTitle:@"确定" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tag = 1;
    [shareButton.titleLabel setFont:shareFont];
    //    [shareButton setBackgroundColor:APPDEFAULTORANGE];
    //    [shareButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:shareButton.frame.size] forState:UIControlStateHighlighted];
    [shareButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [shareAlert addSubview:shareButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX + buttonDis + buttonW, buttonY, buttonW, buttonH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 0;
    [cancelButton.titleLabel setFont:shareFont];
    //    [cancelButton setBackgroundColor:APPDEFAULTORANGE];
    //    [cancelButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:cancelButton.frame.size] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [shareAlert addSubview:cancelButton];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [shareAlert.layer addAnimation:popAnimation forKey:nil];
    [self.view addSubview:shareAlert];
}

- (void)alertbuttonClick:(UIButton *)button
{
    UIView *mydismissView = dismissView;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    UIView *subview = [alertview viewWithTag:10];
    if (button.tag == 0) {
        [alertview removeFromSuperview];
        return;
    }
    UITextField *textview = nil;
    if ([subview isMemberOfClass:[UITextField class]]) {
        textview = (UITextField *)subview;
    }
    NSString *password = textview.text;
    [alertview removeFromSuperview];
    if (password == nil || [password isEqualToString:@""]) {
        
        [self showHint:@"请输入支付宝账号"];
        return;
    }
    [self requestBindAccount:password];
}

- (void)requestBindAccount:(NSString *)alipayaccount
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    [self showHudInView:tableview hint:@"绑定中..."];
    NSDictionary * params  = @{@"userId":userId,@"alipayaccount":alipayaccount};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/bindingAlipay.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            [self hideHud];
            [self showHint:@"绑定成功"];
            [self getUserPayInfo];
        }
        else{
            [self hideHud];
            NSString *errorInfo = respondDict[@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
        }
        
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateUserPayInfoNotificaiton object:nil];
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
