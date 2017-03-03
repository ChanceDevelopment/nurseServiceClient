//
//  EnrollTipVC.m
//  nurseService
//
//  Created by 梅阳阳 on 17/2/24.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "EnrollTipVC.h"

@interface EnrollTipVC ()
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation EnrollTipVC
@synthesize webview;

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
        label.text = @"安心护用户服务协议";
        [label sizeToFit];
        self.title = @"安心护用户服务协议";
        
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
    
    [webview setScalesPageToFit:YES];
    webview.userInteractionEnabled = YES;
    webview.scrollView.bounces = NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@agreement/userExemptionAgreement.html",BASEURL];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];

}

#pragma mark webViewdelegate

-(void)webViewDidFinishLoad:(UIWebView *)webViewTmp{
    
}

- (BOOL)webView:(UIWebView *)webViewTmp shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    static BOOL isRequestWeb = YES;
    
    if (isRequestWeb) {
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (response.statusCode == 404 || response.statusCode == 403 || error) {
            // code for 404 or 403
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noData"]];
            imageView.frame = CGRectMake((SCREENWIDTH - 100)/2.0, 200, 100, 100);
            imageView.center = self.view.center;
            [self.view addSubview:imageView];
            [webview stopLoading];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"亲，目前页面有点问题，请稍后再试" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            alert.tag = 404;
            [alert show];
            return NO;
        }
        
        [webview loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[request URL]];
        isRequestWeb = NO;
        return NO;
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
