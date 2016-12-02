//
//  Waiting.h
//  单耳兔
//
//  Created by yang on 15/6/11.
//  Copyright (c) 2015年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Waiting : NSObject
+ (void)showWaitingView;
+ (void)showLoadingView;
+ (void)dismissWaitingView;
+ (void)show;
+ (void)dismiss;
@end
