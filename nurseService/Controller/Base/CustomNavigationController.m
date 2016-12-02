//
//  CustomNavigationController.m
//  单耳兔
//
//  Created by 何栋明 on 15/7/2.
//  Copyright (c) 2015年 珠海单耳兔电子商务有限公司. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewControllersWithHiddenBottomBar = [[NSMutableSet alloc] initWithCapacity:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController.hidesBottomBarWhenPushed)
    {
        viewController.hidesBottomBarWhenPushed = NO;
        [_viewControllersWithHiddenBottomBar addObject:viewController];
        [self rootViewController].hidesBottomBarWhenPushed = YES;
    }
    else
    {
        [self rootViewController].hidesBottomBarWhenPushed = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    NSObject *obj = nil;
//    @try {
//        obj = self.viewControllers[self.viewControllers.count - 2];
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//    
//    if([_viewControllersWithHiddenBottomBar containsObject:obj])
//    {
//        if ([viewController isKindOfClass:[ShopCatController class]]) {
//            [self rootViewController].hidesBottomBarWhenPushed = NO;
//        }
//        else{
//            [self rootViewController].hidesBottomBarWhenPushed = YES;
//        }
//    }
//    else if ([[self.viewControllers lastObject] isMemberOfClass:[GoodsDetailController class]])
//    {
//        //如果是购物车出栈，需要隐藏底部的tab，因为购物车进栈的时候需要显示底部的tab
//        [self rootViewController].hidesBottomBarWhenPushed = YES;
//    }
//    else
//    {
//        [self rootViewController].hidesBottomBarWhenPushed = NO;
//    }
    NSArray *array = [super popToViewController:viewController animated:YES];
    if (array) {
        for (UIViewController *vc in array) {
            [_viewControllersWithHiddenBottomBar removeObject:vc];
        }
    }
    
    return array;
}

//返回根控制器，必须显示底部的tabBar
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    //由于是根控制器，必须显示tabBar
    [self rootViewController].hidesBottomBarWhenPushed = NO;
    NSArray *array = [super popToRootViewControllerAnimated:YES];
    return array;
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated
{
//    NSObject *obj = nil;
//    @try {
//        obj = self.viewControllers[self.viewControllers.count - 2];
//        if([_viewControllersWithHiddenBottomBar containsObject:obj])
//        {
//            [self rootViewController].hidesBottomBarWhenPushed = YES;
//        }
//        else if ([[self.viewControllers lastObject] isMemberOfClass:[GoodsDetailController class]])
//        {
//            //如果是购物车出栈，需要隐藏底部的tab，因为购物车进栈的时候需要显示底部的tab
//            if ([self.viewControllers count] >= 2) {
//                [self rootViewController].hidesBottomBarWhenPushed = NO;
//            }
//            
//            else{
//                [self rootViewController].hidesBottomBarWhenPushed = YES;
//            }
//        }
//        else
//        {
//            [self rootViewController].hidesBottomBarWhenPushed = NO;
//        }
//        
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        UIViewController *poppedViewController = [super popViewControllerAnimated:animated];
//        if (poppedViewController) {
//            [_viewControllersWithHiddenBottomBar removeObject:poppedViewController];
//        }
//        
//        return poppedViewController;
//    }
    UIViewController *poppedViewController = [super popViewControllerAnimated:animated];
    if (poppedViewController) {
        [_viewControllersWithHiddenBottomBar removeObject:poppedViewController];
    }
    
    return poppedViewController;
    
}

- (UIViewController *) rootViewController
{
    return ((UIViewController *)self.viewControllers.firstObject);
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
