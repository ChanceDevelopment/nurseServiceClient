//
//  HeBalanceEditVC.m
//  beautyContest
//
//  Created by Tony on 16/10/8.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBalanceEditVC.h"
#import "UIButton+Bootstrap.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#define WITHDRAWMIN 200
#define WITHDRAWMAX 2000

@interface HeBalanceEditVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *editField;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;
@property(strong,nonatomic)IBOutlet UILabel *tipLabel;

@end

@implementation HeBalanceEditVC
@synthesize banlanceType;
@synthesize editField;
@synthesize commitButton;
@synthesize maxWithDrawMoney;
@synthesize tipLabel;
@synthesize balanceDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetAlipayResult:) name:@"GetAlipayResult" object:nil];
}

- (void)initView
{
    [super initView];
    // Custom initialization
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = APPDEFAULTTITLETEXTFONT;
    label.textColor = APPDEFAULTTITLECOLOR;
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
//    editField.layer.borderColor = [UIColor grayColor].CGColor;
//    editField.layer.borderWidth = 1.0;
//    editField.layer.masksToBounds = YES;
//    editField.layer.cornerRadius = 5.0;
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [commitButton dangerStyle];
    commitButton.layer.borderWidth = 0;
    commitButton.layer.borderColor = [UIColor clearColor].CGColor;
    [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
    
    tipLabel.hidden = YES;
    
    switch (banlanceType) {
        case Balance_Edit_Recharge:
        {
            label.text = @"充值";
            [label sizeToFit];
            self.title = @"充值";
            editField.placeholder = @"建议转入100元以上";
            editField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case Balance_Edit_Withdraw:
        {
            label.text = @"提现";
            [label sizeToFit];
            self.title = @"提现";
            if (maxWithDrawMoney > 2000) {
                maxWithDrawMoney = 2000;
            }
            editField.placeholder = [NSString stringWithFormat:@"本次最多可提现%.2f元",maxWithDrawMoney];
            tipLabel.hidden = NO;
            editField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case Balance_Edit_BindAccount:
        {
            NSString *apliPayAccount = [balanceDict objectForKey:@"userAlipay"];
            if ([apliPayAccount isMemberOfClass:[NSNull class]] || apliPayAccount == nil) {
                apliPayAccount = nil;
            }
            label.text = @"绑定账号";
            [label sizeToFit];
            self.title = @"绑定账号";
            editField.placeholder = @"绑定账号";
            editField.text = apliPayAccount;
            break;
        }
        default:
            break;
    }
    
    
}

- (void)GetAlipayResult:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (![[userInfo objectForKey:@"result"] boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"支付未能成功" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)commitButtonClick:(UIButton *)sender
{
    NSLog(@"commitButtonClick");
    if ([editField isFirstResponder]) {
        [editField resignFirstResponder];
    }
    
    CGFloat money = [editField.text floatValue];
    switch (banlanceType) {
        case Balance_Edit_Recharge:
        {
            if (editField.text == nil || [editField.text isEqualToString:@""]) {
                [self showHint:@"请输入充值金额"];
                return;
            }
            
            [self rechargeMoney:money];
            break;
        }
        case Balance_Edit_Withdraw:
        {
            if (editField.text == nil || [editField.text isEqualToString:@""]) {
                [self showHint:@"请输入提现金额"];
                return;
            }
            if (money >= WITHDRAWMIN && money <= WITHDRAWMAX) {
                [self withDrawMoney:money];
            }
            else{
                if (money < WITHDRAWMIN) {
                    NSString *errorTip = [NSString stringWithFormat:@"提现金额至少%d块钱",WITHDRAWMIN];
                    [self showHint:errorTip];
                }
                else if (money > WITHDRAWMAX){
                    NSString *errorTip = [NSString stringWithFormat:@"每次提现不能超过%d块",WITHDRAWMAX];
                    [self showHint:errorTip];
                }
            }
            break;
        }
        case Balance_Edit_BindAccount:
        {
            NSString *alipayAccount = editField.text;
            if (alipayAccount == nil || [alipayAccount isEqualToString:@""]) {
                [self showHint:@"请输入支付宝账号"];
                return;
            }
            [self modifyAlipayAccount:alipayAccount];
            break;
        }
        default:
            break;
    }
    //防止充值按钮多次被点击
    sender.enabled = NO;
}

//充值
- (void)rechargeMoney:(CGFloat)money
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/alipay/signProve.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f",money];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"money":moneyStr,@"Type":@"1",@"orderId":@"",@"couponId":@""};
    [self showHudInView:self.view hint:@"充值中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (statueCode == REQUESTCODE_SUCCEED) {
            
            NSString *appScheme = @"AlipaySdkNurseServiceClient";//-----回调id,返回应用
            NSString *orderString = respondDict[@"json"];
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"resultDic: %@",resultDic);
                /*
                 *
                 *
                 *此处不返回支付结果
                 *
                 *
                 ***/
            }];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

//提现
- (void)withDrawMoney:(CGFloat)money
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/nurseAnduser/drawMoney.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f",money];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"money":moneyStr,@"identity":@"0"};
    [self showHudInView:self.view hint:@"提现中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (statueCode == REQUESTCODE_SUCCEED) {
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:1.0];
            [self showHint:@"提现申请成功，等待客服人员审核"];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

//绑定支付宝账号
- (void)modifyAlipayAccount:(NSString *)account
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/money/bindingAlipay.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    
    NSDictionary *requestMessageParams = @{@"userId":userId,@"userAlipay":account};
    [self showHudInView:self.view hint:@"正在绑定..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        NSString *data = [respondDict objectForKey:@"data"];
        if ([data isMemberOfClass:[NSNull class]] || data == nil) {
            data = ERRORREQUESTTIP;
        }
        [self showHint:data];
        if (statueCode == REQUESTCODE_SUCCEED){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyAlipayAccountSucceed" object:nil];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.2];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetAlipayResult" object:nil];
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
