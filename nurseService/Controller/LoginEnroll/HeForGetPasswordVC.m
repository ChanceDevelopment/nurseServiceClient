//
//  HeForGetPasswordVC.m
//  nurseService
//
//  Created by Tony on 2017/1/24.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeForGetPasswordVC.h"
#import "UIButton+countDown.h"

@interface HeForGetPasswordVC ()<UITextFieldDelegate,UIAlertViewDelegate>
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
@property(strong,nonatomic)IBOutlet UIButton *resetButton;
@property(strong,nonatomic)IBOutlet UITextField *accountField;
@property(strong,nonatomic)IBOutlet UITextField *codeField;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UIView *secondLine;

@end

@implementation HeForGetPasswordVC
@synthesize getCodeButton;
@synthesize resetButton;
@synthesize accountField;
@synthesize codeField;
@synthesize commitButton;
@synthesize passwordField;
@synthesize secondLine;


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
        label.text = @"忘记密码";
        [label sizeToFit];
        self.title = @"忘记密码";
        
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
    getCodeButton.layer.masksToBounds = YES;
    getCodeButton.layer.cornerRadius = 5.0;
    getCodeButton.layer.borderWidth = 0.5;
    getCodeButton.layer.borderColor = APPDEFAULTORANGE.CGColor;
}

- (IBAction)getCodeButtonClick:(UIButton *)sender
{
    if ([accountField isFirstResponder]) {
        [accountField resignFirstResponder];
    }
    if ([codeField isFirstResponder]) {
        [codeField resignFirstResponder];
    }
    NSString *account = accountField.text;
    if ([account isEqualToString:@""] || account == nil) {
        [self showHint:@"请输入手机号"];
        return;
    }
    if (![Tool isMobileNumber:account]) {
        [self showHint:@"请输入正确手机号"];
        return;
    }
    
    [sender startWithTime:60 title:@"获取验证码" countDownTitle:@"s" mainColor:[UIColor whiteColor] countColor:[UIColor whiteColor]];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *Identify = @"0";
    NSString *Phone = accountField.text;
    NSDictionary * params  = @{@"userId":userId,@"Identify":Identify,@"Phone":Phone};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/ResetPasswordSMSVerification.action",BASEURL];
    [self showHudInView:self.view hint:@"发送中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self showHint:@"验证码发送成功"];
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
}

- (IBAction)resetButtonClick:(UIButton *)sender
{
    if ([accountField isFirstResponder]) {
        [accountField resignFirstResponder];
    }
    if ([codeField isFirstResponder]) {
        [codeField resignFirstResponder];
    }
    NSString *account = accountField.text;
    if ([account isEqualToString:@""] || account == nil) {
        [self showHint:@"请输入手机号"];
        return;
    }
    if (![Tool isMobileNumber:account]) {
        [self showHint:@"请输入正确手机号"];
        return;
    }
    NSString *code = codeField.text;
    if ([code isEqualToString:@""] || code == nil) {
        [self showHint:@"请输入验证码"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *Identify = @"0";
    NSString *Passwordcode = code;
    NSDictionary * params  = @{@"userId":userId,@"Identify":Identify,@"Passwordcode":Passwordcode};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/ResetPasswordComparison.action",BASEURL];
    [self showHudInView:self.view hint:@"验证中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            accountField.hidden = YES;
            codeField.hidden = YES;
            resetButton.hidden = YES;
            getCodeButton.hidden = YES;
            secondLine.hidden = YES;
            
            passwordField.hidden = NO;
            commitButton.hidden = NO;
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
}

- (IBAction)commitButtonClick:(id)sender
{
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    NSString *passWord = passwordField.text;
    BOOL ok= [RegularTool isIncludeSpecialCharact:passWord];
    if (ok == YES) {
        [self showHint:@"不能加入特殊符号"];
        return;
    }
    
    if ([passWord isEqualToString:@""] || passWord == nil || passWord.length < 6) {
        [self showHint:@"请输入密码"];
        return;
    }

    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *phone = accountField.text;
    NSString *Identify = @"0";
    NSDictionary * params  = @{@"phone":phone,@"Identify":Identify,@"passWord":passWord};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/ResetPasswordUpdate.action",BASEURL];
    [self showHudInView:self.view hint:@"重置中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"密码重置成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
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
