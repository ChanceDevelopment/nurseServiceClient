//
//  HeServiceInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeServiceInfoVC.h"

@interface HeServiceInfoVC ()<UIWebViewDelegate>
@property(strong,nonatomic)IBOutlet UIWebView *webView;
@property(strong,nonatomic)UIActivityIndicatorView *indicatorView;
@property(strong,nonatomic)NSString *website;
@property(strong,nonatomic)NSURL *webURL;

@end

@implementation HeServiceInfoVC
@synthesize website;
@synthesize webView;
@synthesize indicatorView;
@synthesize webURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initializaiton];
    [self initView];
    [self loadWebview];
    //    [self setOffset];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [indicatorView removeFromSuperview];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
}

-(void)loadWebview
{
    webView.scalesPageToFit = YES;
    
    webView.frame = self.view.bounds;
    webView.delegate = self;
    webURL = [NSURL URLWithString:@"http://118.178.186.59:8080/nurseDoor/nurseAnduser/contentDetails.action?contentId=2a64345c6f4e48358d198f7d01cf0b97"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:webURL];
    [webView loadRequest:request];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    indicatorView.hidden = NO;
    [indicatorView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    indicatorView.hidden = YES;
    [indicatorView stopAnimating];
}
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
