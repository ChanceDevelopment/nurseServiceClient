//
//  HeSysbsModel.h
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeSysbsModel : NSObject
@property(strong,nonatomic)NSString *seesionid; //本次登录的sessionid
@property(strong,nonatomic)User *user;//用户
@property(strong,nonatomic)NSArray *albumArray;//当前用户相册的可操作权限

+ (HeSysbsModel *)getSysModel;

@end
