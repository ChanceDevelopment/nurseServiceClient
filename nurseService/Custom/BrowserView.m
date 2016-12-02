//
//  BrowserView.m
//  com.mant.iosClient
//
//  Created by 何 栋明 on 14-2-17.
//  Copyright (c) 2014年 何栋明. All rights reserved.
//

#import "BrowserView.h"

@interface BrowserView ()
@property(strong,nonatomic)IBOutlet UIWebView *webView;
@property(strong,nonatomic)UIActivityIndicatorView *indicatorView;
@property(strong,nonatomic)NSString *website;

@end

@implementation BrowserView
@synthesize website;
@synthesize webView;
@synthesize indicatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(id)initWithWebSite:(NSString*)string
{
    self = [super init];
    if (self) {
        if (string == nil || [string isMemberOfClass:[NSNull class]]) {
            string = @"";
        }
        if ([string rangeOfString:@"http"].length == 0) {
            string = [NSString stringWithFormat:@"http://%@",string];
        }
        self.website = [[NSString alloc] initWithString:string];
    }
   
    return self;
}

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
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidden = NO;
    indicatorView.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 50, (self.navigationController.navigationBar.frame.size.height - 30)/2, 30, 30);
    [self.navigationController.navigationBar addSubview:indicatorView];

    webView.scalesPageToFit = YES;
    
    webView.frame = self.view.bounds;
    webView.delegate = self;
    if (self.htmlContent) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        [self.webView loadHTMLString:self.htmlContent baseURL:baseURL];
    }
    else{
        NSURL *url = [[NSURL alloc] initWithString:website];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [webView loadRequest:request];
    }
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

@end
