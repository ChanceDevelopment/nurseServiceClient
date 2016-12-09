//
//  CustomNavigationController.h
//  单耳兔
//
//  Created by 何栋明 on 15/7/2.
//  Copyright (c) 2015年 珠海单耳兔电子商务有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController
{
    NSMutableSet *_viewControllersWithHiddenBottomBar;
}

@end
