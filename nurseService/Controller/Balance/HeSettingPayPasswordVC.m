//
//  HeSettingPayPasswordVC.m
//  nurseService
//
//  Created by Tony on 2017/1/18.
//  Copyright © 2017年 iMac. All rights reserved.
//  设置密码的视图控制器

#import "HeSettingPayPasswordVC.h"
#import "UIButton+countDown.h"

@interface HeSettingPayPasswordVC ()<UITextFieldDelegate>
//验证码输入框
@property(strong,nonatomic)IBOutlet UITextField *codeField;
//密码输入框
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
//下一步的按钮
@property(strong,nonatomic)IBOutlet UIButton *nextButton;
//重置按钮
@property(strong,nonatomic)IBOutlet UIButton *resetButton;
//获取验证码按钮
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
//提示的标签
@property(strong,nonatomic)IBOutlet UILabel *tipLabel;

@end

@implementation HeSettingPayPasswordVC
@synthesize codeField;
@synthesize passwordField;
@synthesize nextButton;
@synthesize resetButton;
@synthesize tipLabel;
@synthesize getCodeButton;

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
        label.text = @"设置支付密码";
        [label sizeToFit];
        self.title = @"设置支付密码";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

//资源的初始化
- (void)initializaiton
{
    [super initializaiton];
}

//视图的初始化
- (void)initView
{
    [super initView];
    //获取用户的手机号
    NSString *phone = [HeSysbsModel getSysModel].user.userPhone;
    self.tipLabel.text = [NSString stringWithFormat:@"请将手机号 %@ 收到的验证码填写到下面的输入框中",phone];
    
    getCodeButton.layer.cornerRadius = 3.0;
    getCodeButton.layer.borderColor = APPDEFAULTORANGE.CGColor;
    getCodeButton.layer.borderWidth = 0.5;
    getCodeButton.layer.masksToBounds = YES;
}

//下一步按钮的点击事件
- (IBAction)nextButtonClick:(id)sender
{
    NSString *drawcode = codeField.text;
    if (drawcode == nil || [drawcode isEqualToString:@""]) {
        [self showHint:@"请输入验证码"];
        return;
    }
    if ([codeField isFirstResponder]) {
        [codeField resignFirstResponder];
    }
    //验证验证码是否正确
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/SMSVerification.action",BASEURL];
    [self showHudInView:self.view hint:@"验证中..."];
    //drawcode：验证码
    NSDictionary * params  = @{@"drawcode":drawcode};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            //获取验证码成功，更新视图
            [self hideHud];
            tipLabel.hidden = YES;
            codeField.hidden = YES;
            getCodeButton.hidden = YES;
            nextButton.hidden = YES;
            
            passwordField.hidden = NO;
            resetButton.hidden = NO;
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

//重置密码按钮的点击事件
- (IBAction)resetPassword:(id)sender
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *alipayPassword = passwordField.text;
    if ([alipayPassword isEqualToString:@""] || alipayPassword == nil) {
        [self showHint:@"请输入支付密码"];
        return;
    }
    NSString *drawcode = codeField.text;
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/AlipayPassword.action",BASEURL];
    [self showHudInView:self.view hint:@"修改中..."];
    //userId：用户的ID  alipayPassword：支付密码  drawcode：验证码
    NSDictionary * params  = @{@"userId": userId,@"alipayPassword":alipayPassword,@"drawcode":drawcode};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            //设置成功，更新用户的支付信息
            [self updateUserPayInfo];
            //发出通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserPayInfoNotificaiton object:nil];
            
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}

//更新用户的支付信息
- (void)updateUserPayInfo
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
            //保存用户的支付信息
            [[NSUserDefaults standardUserDefaults] setObject:payInfo forKey:kUserPayInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self showHint:@"修改成功"];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.8];
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError* err){
        
    }];
}


//获取验证码的点击事件
- (IBAction)getCodeButtonClick:(UIButton *)sender
{
    if ([codeField isFirstResponder]) {
        [codeField resignFirstResponder];
    }
    
    [sender startWithTime:60 title:@"获取验证码" countDownTitle:@"s" mainColor:[UIColor whiteColor] countColor:[UIColor whiteColor]];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/sendSmsByUserBindPassword.action",BASEURL];
    //userId：用户的ID
    NSDictionary * params  = @{@"userId": userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self showHint:@"验证码已发送"];
//            [getCodeButton setTitle:@"重发验证码" forState:UIControlStateNormal];
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)backToLastView
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
