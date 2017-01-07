//
//  OrderViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "OrderViewController.h"
#import "DLNavigationTabBar.h"

@interface OrderViewController ()
{
    NSInteger addStatusBarHeight;
}
@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;

@end

@implementation OrderViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"预约框",@"已预约",@"进行中",@"已完成"]];
        self.navigationTabBar.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        self.navigationTabBar.frame = CGRectMake(0, TOPNAVIHEIGHT+addStatusBarHeight, SCREENWIDTH, 44);
        self.navigationTabBar.sliderBackgroundColor = APPDEFAULTORANGE;
        self.navigationTabBar.buttonNormalTitleColor = [UIColor grayColor];
        self.navigationTabBar.buttonSelectedTileColor = APPDEFAULTORANGE;
        __weak typeof(self) weakSelf = self;
        [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
            [weakSelf navigationDidSelectedControllerIndex:index];
        }];
    }
    return _navigationTabBar;
}

- (void)viewDidLoad {
    addStatusBarHeight = STATUSBAR_HEIGHT;
    //--ios7 or later  添加 bar
    if (iOS7) {
        
    }else{
        UILabel *addStatusBar = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, SCREENWIDTH, 20)];
        addStatusBar.backgroundColor = TOPNAVIBGCOLOR;
        [self.view addSubview:addStatusBar];
    }
    [super viewDidLoad];
    [self initView];
    
    
}

- (void)initView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navigationTabBar];

    //top
    UIView *topNaviView_topClass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, TOPNAVIHEIGHT + addStatusBarHeight)];
    [self.view addSubview:topNaviView_topClass];
    topNaviView_topClass.userInteractionEnabled = YES;//这样才可以点击
    topNaviView_topClass.backgroundColor = [UIColor purpleColor];
    
    //文字
    UILabel *topNaviText = [[UILabel alloc] initWithFrame:CGRectMake(60, 0+ addStatusBarHeight, SCREENWIDTH-120, TOPNAVIHEIGHT)];
    topNaviText.textAlignment = NSTextAlignmentCenter;
    topNaviText.text = @"订单"; //60, 0, 250, TOPNAVIHEIGHT
    topNaviText.font = [UIFont systemFontOfSize:18];
    topNaviText.textColor = [UIColor whiteColor];
    topNaviText.userInteractionEnabled = YES;//这样才可以点击
    topNaviText.backgroundColor = [UIColor clearColor];
    [topNaviView_topClass addSubview:topNaviText];
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

#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    
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
