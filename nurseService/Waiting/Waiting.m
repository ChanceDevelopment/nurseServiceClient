//
//  Waiting.m
//  单耳兔
//
//  Created by yang on 15/6/11.
//  Copyright (c) 2015年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import "Waiting.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

static UIWindow *_window;
static MBProgressHUD *HUD;
static NSTimer *timer;
static UIImageView *_imageView;

@implementation Waiting

//导航条以下的遮罩
+ (void)showLoadingView{
    int y = TOPNAVIHEIGHT;
    if (ISIOS7) {
        y = TOPNAVIHEIGHT+20;
    }
    //确保加载过程中,用户可以返回到上一级页面
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, y, SCREENWIDTH, SCREENHEIGH-y)];
    _window.backgroundColor = [UIColor clearColor];
    [_window makeKeyAndVisible];
    
    HUD = [[MBProgressHUD alloc] initWithWindow:_window];
    HUD.labelText = @"加载中...";
    [_window insertSubview:HUD atIndex:1000];
    
    _window.alpha = 1.0;
    [HUD show:YES];
}

//全屏遮罩,防止请求数据的过程中,错误操作
+ (void)showWaitingView{
    int y = TOPNAVIHEIGHT;
    if (ISIOS7) {
        y = TOPNAVIHEIGHT+20;
    }
    //确保加载过程中,用户可以返回到上一级页面
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH-y)];
    _window.backgroundColor = [UIColor clearColor];
    [_window makeKeyAndVisible];

    HUD = [[MBProgressHUD alloc] initWithWindow:_window];
    [_window insertSubview:HUD atIndex:1000];
    
    _window.alpha = 1.0;
    [HUD show:YES];
}

//隐藏遮罩
+ (void)dismissWaitingView{
    [UIView animateWithDuration:0.5 animations:^{
        _window.alpha = 0.0;
        [HUD hide:YES];
    }];
}

+ (void)show{
    
    //确保加载过程中,用户可以返回到上一级页面
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH)];
    _window.backgroundColor = [UIColor clearColor];
    [_window makeKeyAndVisible];
    
    UIImage *image = [UIImage imageNamed:@"loading_anim1"];
    CGFloat imageWide = image.size.width / 2.0;
    CGFloat imageHigh = image.size.height / 2.0;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-imageWide) / 2.0, (SCREENHEIGH-imageHigh) / 2.0, imageWide, imageHigh)];
    [_imageView.layer setMasksToBounds:YES];
    [_imageView.layer setCornerRadius:8];
    [_window addSubview:_imageView];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 1; i < 3; i ++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_anim%d",i]];
        [arr addObject:image];
    }
    [_imageView setAnimationImages:arr];
    [_imageView setAnimationDuration:0.3];
    [_imageView startAnimating];
    
    //点击空白处关
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [_window addGestureRecognizer:tapGes];
    
}

+ (void)dismiss{
    [_imageView stopAnimating];
    _window.alpha = 0.0;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window makeKeyAndVisible];
}

@end
