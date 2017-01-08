//
//  HeUserLocatiVC.h
//  beautyContest
//
//  Created by Danertu on 16/10/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@protocol GetUserLocationInfoDelegate <NSObject>

- (void)getUserInfoWithDict:(NSDictionary *)addressDict;

@end

@interface HeUserLocatiVC : HeBaseViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}
@property(strong,nonatomic)NSDictionary *userLocationDict;
@property(assign,nonatomic)BOOL editLocation;
@property(assign,nonatomic)id<GetUserLocationInfoDelegate>addressDelegate;

@end
