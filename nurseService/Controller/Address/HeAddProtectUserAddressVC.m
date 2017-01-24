//
//  HeAddProtectUserAddressVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeAddProtectUserAddressVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "HeBaseTableViewCell.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface HeAddProtectUserAddressVC ()<UISearchBarDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate>
{
    BMKLocationService* _locService;
    NSString  *keyWord;
    BMKPoiSearch *_searcher;
    int curPage;
    BMKUserLocation *currentLocation;
    BMKGeoCodeSearch *_geoSearch;
}
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet BMKMapView *mapView;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeAddProtectUserAddressVC
@synthesize tableview;
@synthesize searchBar;
@synthesize dataSource;

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
        label.text = @"新增受护地址";
        [label sizeToFit];
        self.title = @"新增受护地址";
        
    }
    return self;
}

- (void)viewDidLoad {
    //标注自身位置
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _locService.delegate = self;
     [_locService startUserLocationService];
    _mapView.delegate = self;
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.zoomLevel = 10;
    _mapView.showsUserLocation = YES;//显示定位图层
    _geoSearch.delegate = self;
    
    self.navigationItem.titleView = searchBar;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationItem.titleView = searchBar;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [BMKMapView enableCustomMapStyle:NO];//关闭个性化地图
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _searcher.delegate = nil;
    _geoSearch.delegate = nil;
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    _locService = [[BMKLocationService alloc]init];
    curPage = 0;
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _geoSearch.delegate = self;
    
    NSDictionary *dict = @{@"subAddress":@"[当前]",@"address":[HeSysbsModel getSysModel].addressResult.address};
    [dataSource addObject:dict];
}


- (void)initView
{
    [super initView];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGFloat searchX = 30;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = SCREENHEIGH - 2 * searchY;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"小区/写字楼/学校等";
    self.navigationItem.titleView = searchBar;
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    NSString *searchKey = searchBar.text;
    if (searchKey == nil || [searchKey isEqualToString:@""]) {
        [self showHint:@"请输入搜索关键字"];
        return;
    }
    keyWord = searchKey;
    [self searchAddressWithKey:keyWord];
    
}

- (void)searchAddressWithKey:(NSString *)searchKey
{
    [self showHudInView:self.view hint:@"搜索中..."];
    NSLog(@"searchAddress");
    //初始化检索对象
    _searcher =[[BMKPoiSearch alloc]init];
    _searcher.delegate = self;
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = curPage;
    option.pageCapacity = 20;
    option.location = currentLocation.location.coordinate;
    option.keyword = searchKey;
    BOOL flag = [_searcher poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        [self hideHud];
        [self showHint:@"周边检索发送失败"];
        NSLog(@"周边检索发送失败");
    }
}

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    [self hideHud];
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"poiResultList = %@",poiResultList);
        NSArray *poiInfoList = poiResultList.poiInfoList;
        
        [dataSource removeAllObjects];
        NSDictionary *dict = @{@"subAddress":@"[当前]",@"address":[HeSysbsModel getSysModel].addressResult.address};
        [dataSource addObject:dict];
        
        for (NSInteger index = 0; index < [poiInfoList count]; index++) {
            BMKPoiInfo *info = poiInfoList[index];
            NSString *name = info.name;
            NSString *address = info.address;
            if (!name) {
                name = @"";
            }
            if (!address) {
                address = @"";
            }
            NSDictionary *dict = @{@"subAddress":name,@"address":address};
            [dataSource addObject:dict];
        }
        if ([dataSource count] == 0) {
            UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
            UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
            CGFloat scale = noImage.size.height / noImage.size.width;
            CGFloat imageW = 120;
            CGFloat imageH = imageW * scale;
            UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
            imageview.frame = CGRectMake(100, 100, imageW, imageH);
            imageview.center = bgView.center;
            [bgView addSubview:imageview];
            tableview.backgroundView = bgView;
        }
        else{
            tableview.backgroundView = nil;
        }
        [tableview reloadData];
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
         [self showHint:@"起始点有歧义"];
    } else {
        NSLog(@"抱歉，未找到结果");
        [self showHint:@"抱歉，未找到结果"];
    }
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeProtectUserInfoTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CGFloat locationIconW = 20;
    CGFloat locationIconH = 20;
    CGFloat locationIconX = 20;
    CGFloat locationIconY = (cellSize.height / 2.0 - locationIconH) / 2.0;
    UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_gray_address"]];
    locationIcon.frame = CGRectMake(locationIconX, locationIconY, locationIconW, locationIconH);
    [cell addSubview:locationIcon];
    
    CGFloat nameLabelX = CGRectGetMaxX(locationIcon.frame) + 10;
    CGFloat nameLabelY = 0;
    CGFloat nameLabelH = cellSize.height / 2.0;
    CGFloat nameLabelW = SCREENWIDTH - nameLabelX - 10;
    
    NSString *name = dict[@"subAddress"];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = name;
    if (row == 0) {
        nameLabel.textColor = APPDEFAULTORANGE;
    }
    else{
        nameLabel.textColor = [UIColor grayColor];
    }
    [cell addSubview:nameLabel];
    
    NSString *address = dict[@"address"];
    CGFloat addressLabelX = nameLabelX;
    CGFloat addressLabelY = CGRectGetMaxY(nameLabel.frame);
    CGFloat addressLabelH = cellSize.height / 2.0;
    CGFloat addressLabelW = nameLabelW;
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressLabelX, addressLabelY, addressLabelW, addressLabelH)];
    addressLabel.numberOfLines = 2;
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = address;
    addressLabel.font = [UIFont systemFontOfSize:13.0];
    addressLabel.textColor = [UIColor grayColor];
    [cell addSubview:addressLabel];
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    [_addressDelegate addProtectUserAddressWithAddressInfo:dict];
   
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
//    BMKCoordinateSpan span = BMKCoordinateSpanMake(0.5, 0.5);
//    BMKCoordinateRegion region = BMKCoordinateRegionMake(userLocation.location.coordinate, span);
//    [_mapView setRegion:region animated:YES];
    
    //    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    _mapView.showsUserLocation = YES;
    CLLocation *newLocation = userLocation.location;
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.longitude];
    [HeSysbsModel getSysModel].userLocationDict = @{@"latitude":latitudeStr,@"longitude":longitudeStr};
    if (!currentLocation) {
        currentLocation = userLocation;
        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        BMKCoordinateSpan span = BMKCoordinateSpanMake(0.003971, 0.003971);
        BMKCoordinateRegion region = BMKCoordinateRegionMake(userLocation.location.coordinate, span);
        [_mapView setRegion:region animated:YES];
        
        BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
        
        reverseGeoCodeOption.reverseGeoPoint = coordinate;
        _geoSearch.delegate = self;
        //进行反地理编码
        [_geoSearch reverseGeoCode:reverseGeoCodeOption];
    }
    
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"地址是：%@,%@",result.address,result.addressDetail);
    NSString *cityString = result.addressDetail.city;
    //记录当前的定位城市
    [[NSUserDefaults standardUserDefaults] setObject:cityString forKey:kPreLocationCityKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"当前城市是：%@",cityString);
    [HeSysbsModel getSysModel].addressResult = result;
    if (![[HeSysbsModel getSysModel].userCity isEqualToString:cityString]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetCitySucceedNotification object:cityString];
    }
    
    
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"%@",result.address);
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
    NSLog(@"location error %@",error);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
