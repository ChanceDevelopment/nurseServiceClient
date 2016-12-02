//
//  HeSysbsModel.m
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeSysbsModel.h"

@implementation HeSysbsModel

+ (HeSysbsModel *)getSysModel
{
    __strong static HeSysbsModel* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.user = [[User alloc] init];
        instance.albumArray = [[NSArray alloc] init];
    });
    return instance;
}

@end
