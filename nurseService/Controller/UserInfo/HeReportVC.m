//
//  HeReportVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//  投诉建议视图控制器

#import "HeReportVC.h"

@interface HeReportVC ()
@property(strong,nonatomic)IBOutlet UIButton *commitButton;

@end

@implementation HeReportVC
@synthesize orderSendId;
@synthesize commitButton;

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
        label.text = @"投诉建议";
        [label sizeToFit];
        self.title = @"投诉建议";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}
- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    commitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREENHEIGH - 50 - 64, SCREENWIDTH, 50)];
    [commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commitButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:commitButton];
}

//投诉提交按钮
- (void)commitButtonClick:(id)sender
{
    if ([self.distributeTF isFirstResponder]) {
        [self.distributeTF resignFirstResponder];
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    
    NSString *content = self.distributeTF.text;
    if ([content isEqualToString:@""] || content == nil) {
        [self showHint:@"请输入投诉内容"];
        return;
    }
    [self showHudInView:self.view hint:@"正在发送..."];
    NSString *identity = @"0";
    if (!orderSendId) {
        orderSendId = @"";
    }
    NSMutableString *complaintPic = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < self.pictureArray.count; index++) {
        AsynImageView *imageview = self.pictureArray[index];
        
        UIImage *imageData = imageview.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        if (index == 0) {
            [complaintPic appendString:base64String];
        }
        else {
            [complaintPic appendFormat:@",%@",base64String];
        }
    }
    NSString *requestRecommendDataPath = [NSString stringWithFormat:@"%@/nurseAnduser/complaintAdd.action",BASEURL];
    //userId：用户ID  content：投诉内容  identity：0：护士 1：用户 complaintPic：上传的图片  orderSendId：订单的ID
    NSDictionary *params = @{@"userId":userId,@"content":content,@"identity":identity,@"complaintPic":complaintPic,@"orderSendId":orderSendId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSString *data = @"发送成功!";
            [self showHint:data];
            [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.2];
        
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
    
}

- (void)backLastView
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
