//
//  HeLoginVC.m
//  nurseService
//
//  Created by Tony on 2016/12/14.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeLoginVC.h"
#import "HeEnrollVC.h"
#import "HeForGetPasswordVC.h"

@interface HeLoginVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *accountField;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UIButton *securirtyButton;
@property(strong,nonatomic)IBOutlet UIButton *loginButton;
@property(strong,nonatomic)IBOutlet UIButton *enrollButton;

@end

@implementation HeLoginVC
@synthesize accountField;
@synthesize passwordField;
@synthesize securirtyButton;
@synthesize enrollButton;

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
        label.text = @"登录";
        [label sizeToFit];
        self.title = @"登录";
        
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
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    securirtyButton.selected = YES;
}

- (IBAction)loginButtonClick:(id)sender
{
    if ([accountField isFirstResponder]) {
        [accountField resignFirstResponder];
        
    }
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
       
    }
    
    NSString *account = [accountField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = passwordField.text;
    if (account == nil || [account isEqualToString:@""]) {
        [self showHint:@"请输入手机号码"];
        return;
    }
    if (password == nil || [password isEqualToString:@""]) {
        [self showHint:@"请输入登录密码"];
        return;
    }
    if (![Tool isMobileNumber:account]) {
        [self showHint:@"请输入正确的手机号码"];
        return;
    }
    [self showHudInView:self.view hint:@"登录中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/UserLogin.action",BASEURL];
    NSDictionary * params  = @{@"UserName": account,@"UserPwd" : password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        [self hideHud];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");

            NSDictionary *userInfoDic = [NSDictionary dictionaryWithDictionary:[respondDict valueForKey:@"json"]];
            NSMutableDictionary *nurseDic = [NSMutableDictionary dictionaryWithCapacity:0];
            
            for (NSString *key in [userInfoDic allKeys]) {
                
                if ([[NSString stringWithFormat:@"%@",[userInfoDic valueForKey:key]] isEqualToString:@"<null>"]) {
                    NSLog(@"key:%@",key);
                    [nurseDic setValue:@"" forKey:key];
                }else{
                    [nurseDic setValue:[NSString stringWithFormat:@"%@",[userInfoDic valueForKey:key]] forKey:key];
                }
            }
            NSLog(@"%@",nurseDic);
            //用户的资料
            NSString *userId = [userInfoDic valueForKey:@"userId"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:account forKey:USERACCOUNTKEY];
            [[NSUserDefaults standardUserDefaults] setObject:nurseDic forKey:kUserDataKey];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:USERIDKEY];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:USERPASSWORDKEY];
            
            [[NSUserDefaults standardUserDefaults] synchronize];//强制写入,保存数据
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        }else{
            NSString *errorInfo = [respondDict valueForKey:@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
            
            NSLog(@"faile");
        }
        
        
        
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}

- (IBAction)forgetPasswordButtonClick:(id)sender
{
    
}

- (IBAction)enrollButtonClick:(id)sender
{
    HeEnrollVC *enrollVC = [[HeEnrollVC alloc] init];
    enrollVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:enrollVC animated:YES];
}

- (IBAction)securityButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    passwordField.secureTextEntry = sender.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)forgetPassword:(id)sender
{
    HeForGetPasswordVC *forgetPasswordVC = [[HeForGetPasswordVC alloc] init];
    forgetPasswordVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:forgetPasswordVC animated:YES];
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
