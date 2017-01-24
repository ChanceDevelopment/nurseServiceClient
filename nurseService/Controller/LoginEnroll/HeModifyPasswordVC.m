//
//  HeModifyPasswordVC.m
//  nurseService
//
//  Created by Tony on 2017/1/24.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeModifyPasswordVC.h"

@interface HeModifyPasswordVC ()<UIAlertViewDelegate>
@property(strong,nonatomic)IBOutlet UITextField *oldPasswordField;
@property(strong,nonatomic)IBOutlet UITextField *myNewPasswordField;
@property(strong,nonatomic)IBOutlet UITextField *commitPasswordField;

@end

@implementation HeModifyPasswordVC
@synthesize oldPasswordField;
@synthesize myNewPasswordField;
@synthesize commitPasswordField;

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
        label.text = @"修改密码";
        [label sizeToFit];
        self.title = @"修改密码";
        
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
}

- (IBAction)commitButtonClick:(id)sender
{
    if ([oldPasswordField isFirstResponder]) {
        [oldPasswordField resignFirstResponder];
    }
    if ([myNewPasswordField isFirstResponder]) {
        [myNewPasswordField resignFirstResponder];
    }
    if ([commitPasswordField isFirstResponder]) {
        [commitPasswordField resignFirstResponder];
    }
    NSString *oldPassword = oldPasswordField.text;
    NSString *newPassword = myNewPasswordField.text;
    NSString *commitPassword = commitPasswordField.text;
    
     NSString *localPassword = [[NSUserDefaults standardUserDefaults] objectForKey:USERPASSWORDKEY];
    
    if ([oldPassword isEqualToString:@""] || oldPassword == nil ) {
        [self showHint:@"请输入原始密码"];
        return;
    }
    if ([newPassword isEqualToString:@""] || newPassword == nil ) {
        [self showHint:@"请输入新密码"];
        return;
    }
    if ([newPassword length] < 6) {
        [self showHint:@"请输入6位数新密码"];
        return;

    }
    
    if ([commitPassword isEqualToString:@""] || commitPassword == nil ) {
        [self showHint:@"请再次输入新密码"];
        return;
    }
    if ([commitPassword length] < 6) {
        [self showHint:@"请再次输入6位数新密码"];
        return;
        
    }
    
//    if (![localPassword isEqualToString:oldPassword]) {
//        [self showHint:@"原始密码有误"];
//        return;
//    }
    if ([oldPassword isEqualToString:newPassword]) {
        [self showHint:@"原始密码跟新密码不能一致"];
        return;
    }
    if (![newPassword isEqualToString:commitPassword]) {
        [self showHint:@"新密码两次输入不一致"];
        return;
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *Identify = @"0";
    NSDictionary * params  = @{@"userId":userId,@"passWord":oldPassword,@"Identify":Identify,@"newPassWord":newPassword};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/VerificationPasswordForNurseAndUser.action",BASEURL];
    [self showHudInView:self.view hint:@"修改中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"密码修改成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
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
    [self signAccount];
}

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
