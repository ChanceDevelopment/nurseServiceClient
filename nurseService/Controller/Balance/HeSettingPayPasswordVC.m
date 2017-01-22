//
//  HeSettingPayPasswordVC.m
//  nurseService
//
//  Created by Tony on 2017/1/18.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeSettingPayPasswordVC.h"
#import "UIButton+countDown.h"

@interface HeSettingPayPasswordVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *codeField;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UIButton *nextButton;
@property(strong,nonatomic)IBOutlet UIButton *resetButton;
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
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

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    NSString *phone = [HeSysbsModel getSysModel].user.userPhone;
    self.tipLabel.text = [NSString stringWithFormat:@"请将手机号 %@ 收到的验证码填写到下面的输入框中",phone];
    
    getCodeButton.layer.cornerRadius = 3.0;
    getCodeButton.layer.borderColor = APPDEFAULTORANGE.CGColor;
    getCodeButton.layer.borderWidth = 0.5;
    getCodeButton.layer.masksToBounds = YES;
}

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
    NSDictionary * params  = @{@"drawcode":drawcode};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
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
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/sendSmsByUserBindPassword.action",BASEURL];
    [self showHudInView:self.view hint:@"修改中..."];
    NSDictionary * params  = @{@"userId": userId,@"alipayPassword":alipayPassword,@"drawcode":drawcode};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self showHint:@"修改成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserInfoNotification object:nil];
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
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}

//获取验证码
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
