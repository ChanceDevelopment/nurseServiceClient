//
//  HeUserLocatiVC.h
//  beautyContest
//
//  Created by Danertu on 16/10/29.
//  Copyright © 2016年 iMac. All rights reserved.
//  用户定位视图控制器

#import "HeBaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@protocol GetUserLocationInfoDelegate <NSObject>

//获取用户位置信息协议
- (void)getUserInfoWithDict:(NSDictionary *)addressDict;

@end

@interface HeUserLocatiVC : HeBaseViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}
//用户的位置信息
@property(strong,nonatomic)NSDictionary *userLocationDict;
//是否可以编辑用户的位置
@property(assign,nonatomic)BOOL editLocation;
//获取用户位置信息的代理
@property(assign,nonatomic)id<GetUserLocationInfoDelegate>addressDelegate;

@end
