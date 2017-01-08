//
//  HeUserLocatiVC.m
//  beautyContest
//
//  Created by Danertu on 16/10/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserLocatiVC.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface HeUserLocatiVC ()
{
    bool isGeoSearch;
    BMKGeoCodeSearch* _geocodesearch;
    BOOL updateLocationSucceed;
}

@end

@implementation HeUserLocatiVC
@synthesize userLocationDict;
@synthesize editLocation;
@synthesize addressDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"位置";
        [label sizeToFit];
        
        self.title = @"位置";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    [self updateAnnotion];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_mapView removeAnnotations:_mapView.annotations];
    [BMKMapView enableCustomMapStyle:NO];//关闭个性化地图
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)initializaiton
{
    [super initializaiton];
    updateLocationSucceed = NO;
    _locService = [[BMKLocationService alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
}

- (void)initView
{
    [super initView];
    _mapView.showsUserLocation = YES;
    if (editLocation) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
        rightItem.title = @"确定";
        rightItem.target = self;
        rightItem.action = @selector(commitAddress:);
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)commitAddress:(id)sender
{
    if ([self.addressDelegate respondsToSelector:@selector(getUserInfoWithDict:)]) {
        [self.addressDelegate getUserInfoWithDict:userLocationDict];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)updateAnnotion
{
    if (!userLocationDict) {
        return;
    }
    NSString *zoneLocationX = userLocationDict[@"zoneLocationX"];
    if ([zoneLocationX isMemberOfClass:[NSNull class]] || zoneLocationX == nil) {
        zoneLocationX = @"";
    }
    NSString *zoneLocationY = userLocationDict[@"zoneLocationY"];
    if ([zoneLocationY isMemberOfClass:[NSNull class]] || zoneLocationY == nil) {
        zoneLocationY = @"";
    }
    [_mapView removeAnnotations:_mapView.annotations];
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc] init];
    CLLocationCoordinate2D coor;
    coor.latitude = [zoneLocationY floatValue];
    coor.longitude = [zoneLocationX floatValue];;
    annotation.coordinate = coor;
    annotation.title = @"赛区位置";
    [_mapView addAnnotation:annotation];
    
    BMKCoordinateSpan span = BMKCoordinateSpanMake(0.003142, 0.001678);
    BMKCoordinateRegion region = BMKCoordinateRegionMake(coor, span);
    [_mapView setRegion:region animated:YES];
    [_mapView setCenterCoordinate:coor animated:YES];
}
// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if (editLocation) {
        [annotation setCoordinate:_mapView.centerCoordinate];
    }
    
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated");
    if (updateLocationSucceed) {
        if (editLocation) {
            CLLocationCoordinate2D coordinate = _mapView.centerCoordinate;
            [self reverseGeocodeWithCLLocationCoordinate:coordinate];
        }
    }
}

-(void)reverseGeocodeWithCLLocationCoordinate:(CLLocationCoordinate2D)pt
{
    isGeoSearch = false;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    label.text = result.address;
    [label sizeToFit];
    NSString *zoneLocationX = [NSString stringWithFormat:@"%f",result.location.longitude];
    NSString *zoneLocationY = [NSString stringWithFormat:@"%f",result.location.latitude];
    userLocationDict = @{@"zoneLocationX":zoneLocationX,@"zoneLocationY":zoneLocationY,@"address":result.address};
    NSLog(@"address = %@",result.address);
}
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"address = %@",result.address);
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    [_mapView updateLocationData:userLocation];
//    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
//    BMKCoordinateSpan span = BMKCoordinateSpanMake(0.013142, 0.011678);
//    BMKCoordinateRegion region = BMKCoordinateRegionMake(userLocation.location.coordinate, span);
//    [_mapView setRegion:region animated:YES];

    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
//    [_mapView updateLocationData:userLocation];
    //    zoneLocationX
    //    zoneLocationY
    NSString *zoneLocationX = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    NSString *zoneLocationY = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    if (!updateLocationSucceed && editLocation) {
        updateLocationSucceed = YES;
        userLocationDict = @{@"zoneLocationX":zoneLocationX,@"zoneLocationY":zoneLocationY};
        [self updateAnnotion];
    }
    
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"BMKMapView控件初始化完成" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    //    [alert show];
    //    alert = nil;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: click blank");
}

- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: double click");
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
