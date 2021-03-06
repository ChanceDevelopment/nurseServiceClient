//
//  HeServiceInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//  服务信息视图控制器

#import "HeServiceInfoVC.h"

@interface HeServiceInfoVC ()<UIWebViewDelegate>
@property(strong,nonatomic)IBOutlet UIWebView *webView;
@property(strong,nonatomic)UIActivityIndicatorView *indicatorView;
@property(strong,nonatomic)NSString *website;
@property(strong,nonatomic)NSURL *webURL;

@property(strong,nonatomic)id parameter;
@property(strong,nonatomic)NSDictionary *serviceInfoDict;

@end

@implementation HeServiceInfoVC
@synthesize website;
@synthesize webView;
@synthesize indicatorView;
@synthesize webURL;

@synthesize parameter;
@synthesize serviceInfoDict;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initializaiton];
    [self initView];
    //加载服务详情，网页
    [self loadWebview];
    //    [self setOffset];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [indicatorView removeFromSuperview];
}

//资源的初始化
- (void)initializaiton
{
    [super initializaiton];
    serviceInfoDict = parameter;
}

//初始化视图
- (void)initView
{
    [super initView];
}

//加载服务详情，网页
-(void)loadWebview
{
//    webView.scalesPageToFit = YES;
    
    webView.frame = self.view.bounds;
    webView.delegate = self;
//    http://118.178.186.59:8080/nurseDoor/nurseAnduser/contentDetails.action?contentId=2a64345c6f4e48358d198f7d01cf0b97
    //contentId：服务的ID
    NSString *contentId = serviceInfoDict[@"manageNursingContentId"];
    if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
        contentId = serviceInfoDict[@"contentId"];
    }
    NSString *detailStr = [NSString stringWithFormat:@"%@nurseAnduser/contentDetails.action?contentId=%@",BASEURL,contentId];
    webURL = [NSURL URLWithString:detailStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:webURL];
    [webView loadRequest:request];
}

//开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    indicatorView.hidden = NO;
    [indicatorView startAnimating];
}

//加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    indicatorView.hidden = YES;
    [indicatorView stopAnimating];
}

//加载出错
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"很抱歉无法加载页面" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    //    [alertView show];
}

- (void)didReceiveMemoryWarning
{
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
