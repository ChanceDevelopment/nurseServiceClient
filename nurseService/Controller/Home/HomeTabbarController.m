//
//  Left
//
//  Created by apple on 15/12/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "HomeTabbarController.h"
#import "FirstViewController.h"
#import "NurseViewController.h"
#import "OrderViewController.h"
#import "MyViewController.h"
@interface HomeTabbarController ()<UITabBarControllerDelegate>

@property(nonatomic, strong) UIButton *openDrawerButton;
@end

@implementation HomeTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.selectedIndex = 0;
   
    FirstViewController *firstVC = [[FirstViewController alloc] init];
    [self addChildVc:firstVC title:@"首页" image:@"main_home_unselector" selectedImage:@"main_home_selector"];
    NurseViewController *nurseVC = [[NurseViewController alloc] init];
    [self addChildVc:nurseVC title:@"护士" image:@"main_nurse_unselector" selectedImage:@"main_nurse_selector"];
    OrderViewController *orderVC = [[OrderViewController alloc] init];
    [self addChildVc:orderVC title:@"订单" image:@"main_order_unselector" selectedImage:@"main_order_selector"];
    MyViewController *myVC = [[MyViewController alloc] init];
    [self addChildVc:myVC title:@"我的" image:@"main_mine_unselector" selectedImage:@"main_mine_selector"];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectedIndex = self.selectVCIndex;
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    childVc.title = title;
//    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:28],NSFontAttributeName, nil];
//    
//    [childVc.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = APPDEFAULTORANGE;
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    [self addChildViewController:childVc];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
//    [nav.navigationBar setBarTintColor:[UIColor purpleColor]];
//    [self addChildViewController:nav];
}


#pragma mark - Configuring the view’s layout behavior

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
