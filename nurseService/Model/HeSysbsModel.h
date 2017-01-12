//
//  HeSysbsModel.h
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface HeSysbsModel : NSObject
@property(strong,nonatomic)NSString *seesionid; //本次登录的sessionid
@property(strong,nonatomic)User *user;//用户
@property(strong,nonatomic)NSArray *albumArray;//当前用户相册的可操作权限

@property(strong,nonatomic)NSArray *menuArray;
@property(strong,nonatomic)NSArray *hospitalArray;
@property(strong,nonatomic)NSArray *majorArray;
@property(strong,nonatomic)NSDictionary *userLocationDict;
@property(strong,nonatomic)NSString *userCity;
@property(strong,nonatomic)BMKReverseGeoCodeResult *addressResult;

+ (HeSysbsModel *)getSysModel;

@end
