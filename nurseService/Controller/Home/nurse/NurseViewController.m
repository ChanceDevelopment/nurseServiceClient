//
//  NurseViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "NurseViewController.h"

@interface NurseViewController ()
{
    NSInteger addStatusBarHeight;
}
@end

@implementation NurseViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    addStatusBarHeight = STATUSBAR_HEIGHT;
    //--ios7 or later  添加 bar
    if (iOS7) {
        
    }else{
        UILabel *addStatusBar = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, MAINSCREEN_WIDTH, 20)];
        addStatusBar.backgroundColor = TOPNAVIBGCOLOR;
        [self.view addSubview:addStatusBar];
    }
    [super viewDidLoad];
    [self initView];
    
    
    
}

- (void)initView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //top
    UIView *topNaviView_topClass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINSCREEN_WIDTH, TOPNAVIHEIGHT + addStatusBarHeight)];
    [self.view addSubview:topNaviView_topClass];
    topNaviView_topClass.userInteractionEnabled = YES;//这样才可以点击
    topNaviView_topClass.backgroundColor = [UIColor purpleColor];
    
    //----返回----
    UIButton *goBack = [[UIButton alloc] initWithFrame:CGRectMake(10, (TOPNAVIHEIGHT-19)/2+ addStatusBarHeight, 24, 19)];
    [topNaviView_topClass addSubview:goBack];
    [goBack setBackgroundImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [goBack addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //文字
    UILabel *topNaviText = [[UILabel alloc] initWithFrame:CGRectMake(60, 0+ addStatusBarHeight, MAINSCREEN_WIDTH-120, TOPNAVIHEIGHT)];
    topNaviText.textAlignment = NSTextAlignmentCenter;
    topNaviText.text = @"护士"; //60, 0, 250, TOPNAVIHEIGHT
    topNaviText.font = [UIFont systemFontOfSize:18];
    topNaviText.textColor = [UIColor whiteColor];
    topNaviText.userInteractionEnabled = YES;//这样才可以点击
    topNaviText.backgroundColor = [UIColor clearColor];
    [topNaviView_topClass addSubview:topNaviText];
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCity)];
//    [cityText addGestureRecognizer:tap];
//    
    [self.view addSubview:topNaviView_topClass];
}
#pragma mark - Configuring the view’s layout behavior

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
