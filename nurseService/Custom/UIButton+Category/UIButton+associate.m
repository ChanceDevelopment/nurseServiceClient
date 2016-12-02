//
//  UIButton+associate.m
//  SYSBS_EMBA_IPAD_CLIENT
//
//  Created by yaodd on 13-10-13.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "UIButton+associate.h"
#import <objc/runtime.h>
static void *myKey = (void *)@"myKey";
@implementation UIButton (associate)

- (NSDictionary *)myDict{
    return objc_getAssociatedObject(self, myKey);
}

- (void) setMyDict:(NSDictionary *)myDict{
    objc_setAssociatedObject(self, myKey, myDict, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
