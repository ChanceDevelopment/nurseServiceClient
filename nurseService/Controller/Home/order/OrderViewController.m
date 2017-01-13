//
//  OrderViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "OrderViewController.h"
#import "DLNavigationTabBar.h"
#import "HeOrderTableViewCell.h"
#import "HeBookOrderTableCell.h"
#import "HeNowOrderTableCell.h"
#import "HeFinishOrderTabelCell.h"
#import "HePaitentInfoVC.h"
#import "HeOrderDetailVC.h"
#import "HeUserLocatiVC.h"
#import "HeOrderCommitVC.h"
#import "HeProtectedUserInfoVC.h"

@interface OrderViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger currentOrderType;
    //预约框
    NSMutableArray *noBookOrderArray;
    //已预约
    NSMutableArray *hadBookOrderArray;
    //进行中
    NSMutableArray *nowOrderArray;
    //已完成
    NSMutableArray *finishOrderArray;
}
@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation OrderViewController
@synthesize tableview;
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
        label.text = @"订单";
        [label sizeToFit];
        self.title = @"订单";
    }
    return self;
}

-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"预约框",@"已预约",@"进行中",@"已完成"]];
        self.navigationTabBar.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        self.navigationTabBar.sliderBackgroundColor = APPDEFAULTORANGE;
        self.navigationTabBar.buttonNormalTitleColor = [UIColor grayColor];
        self.navigationTabBar.buttonSelectedTileColor = APPDEFAULTORANGE;
        __weak typeof(self) weakSelf = self;
        [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
            [weakSelf navigationDidSelectedControllerIndex:index];
        }];
    }
    return _navigationTabBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadOrderDataWithOrderState:0];
    [self loadOrderDataWithOrderState:1];
    [self loadOrderDataWithOrderState:2];
    [self loadOrderDataWithOrderState:3];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    currentOrderType = 0;
    noBookOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    hadBookOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    nowOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    finishOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    [dataSource addObject:noBookOrderArray];
    [dataSource addObject:hadBookOrderArray];
    [dataSource addObject:nowOrderArray];
    [dataSource addObject:finishOrderArray];
}

- (void)initView
{
    [super initView];
    [self.view addSubview:self.navigationTabBar];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    
}


#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    currentOrderType = index;
    [tableview reloadData];
}

- (void)loadOrderDataWithOrderState:(NSInteger)orderState
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@r/orderSend/OrderSendDescription.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *orderStateStr = [NSString stringWithFormat:@"%ld",orderState];
    NSDictionary * params  = @{@"userId":userId,@"orderState":orderStateStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                
                return;
            }
            NSMutableArray *orderArray = dataSource[orderState];
            orderArray = [[NSMutableArray alloc] initWithArray:jsonArray];
            
            [tableview reloadData];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        
    }];
}

- (void)showPaitentInfoWith:(NSDictionary *)paitentInfoDict
{
    HePaitentInfoVC *paitentInfoVC = [[HePaitentInfoVC alloc] init];
    paitentInfoVC.userInfoDict = [[NSDictionary alloc] initWithDictionary:paitentInfoDict];
    paitentInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:paitentInfoVC animated:YES];
}

- (void)showOrderDetailWithOrder:(NSDictionary *)orderDict
{
    if (currentOrderType == 0) {
        //预约框，跳订单确认界面
        HeOrderCommitVC *orderCommitVC = [[HeOrderCommitVC alloc] init];
        orderCommitVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:orderCommitVC animated:YES];
        return;
    }
    else{
        HeOrderDetailVC *orderDetailVC = [[HeOrderDetailVC alloc] init];
        orderDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:orderDetailVC animated:YES];
    }
    
}

- (void)goLocationWithLocation:(NSDictionary *)locationDict
{
    HeUserLocatiVC *userLocationVC = [[HeUserLocatiVC alloc] init];
    userLocationVC.userLocationDict = [[NSDictionary alloc] initWithDictionary:locationDict];
    userLocationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userLocationVC animated:YES];
}
//预约框
//删除服务
- (void)deleteServiceWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"deleteService");
}

//立即付款
- (void)payMoneyWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"payMoney");
}
//已预约，进行中
//取消服务
- (void)cancelServiceWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"cancelService");
}

//进行中
- (void)contactNurseWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"contactNurse");
}

//已完成
//再来一单
- (void)reCreateOrderWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"reCreateOrder");
}
//前往评价
- (void)commentOrderWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"commentOrder");
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *orderArray = dataSource[currentOrderType];
    return [orderArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"HeOrderTableViewCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray *orderArray = dataSource[currentOrderType];
    
    NSDictionary *dict = nil;
    @try {
        dict = orderArray[section];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    switch (currentOrderType) {
        case 0:
        {
            HeOrderTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[HeOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize orderType:currentOrderType];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
            
            __weak typeof(self) weakSelf = self;
            
            cell.showOrderDetailBlock = ^(){
                NSLog(@"showOrderDetail");
                [weakSelf showOrderDetailWithOrder:nil];
            };
            cell.cancleOrderBlock = ^(){
                NSLog(@"删除服务");
                [weakSelf deleteServiceWithDict:dict];
            };
            cell.payMoneyBlock = ^(){
                NSLog(@"立即付款");
                [weakSelf payMoneyWithDict:dict];
            };
            cell.locationBlock = ^(){
                NSLog(@"locationBlock");
                NSDictionary *userLocationDic = @{@"zoneLocationY":@"23",@"zoneLocationX":@"113"};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            NSString *serviceName = dict[@"serviceName"];
            if ([serviceName isMemberOfClass:[NSNull class]] || serviceName == nil) {
                serviceName = @"";
            }
            cell.serviceContentL.text = serviceName;
            
            id zoneCreatetimeObj = [dict objectForKey:@"orderSendBegintime"];
            if ([zoneCreatetimeObj isMemberOfClass:[NSNull class]] || zoneCreatetimeObj == nil) {
                NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
                zoneCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
            }
            long long timestamp = [zoneCreatetimeObj longLongValue];
            NSString *zoneCreatetime = [NSString stringWithFormat:@"%lld",timestamp];
            if ([zoneCreatetime length] > 3) {
                //时间戳
                zoneCreatetime = [zoneCreatetime substringToIndex:[zoneCreatetime length] - 3];
            }
            
            NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"MM-dd HH:mm"];
            cell.stopTimeL.text = time;

            NSString *addresStr = dict[@"orderSendAddree"];
            if ([addresStr isMemberOfClass:[NSNull class]]) {
                addresStr = @"";
            }
            NSArray *addressArray = [addresStr componentsSeparatedByString:@","];
            NSString *addressDetail = nil;
            @try {
                addressDetail = addressArray[2];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            cell.addressL.text = addressDetail;
            
            NSString *username = dict[@"orderSendUsername"];
            return cell;
            break;
        }
        case 1:
        {
            HeBookOrderTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[HeBookOrderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize orderType:currentOrderType];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
            __weak typeof(self) weakSelf = self;
            
            cell.showOrderDetailBlock = ^(){
                NSLog(@"showOrderDetail");
                [weakSelf showOrderDetailWithOrder:nil];
            };
            cell.cancleServiceBlock = ^(){
                NSLog(@"取消服务");
                [weakSelf cancelServiceWithDict:dict];
            };
            cell.locationBlock = ^(){
                NSLog(@"locationBlock");
                NSDictionary *userLocationDic = @{@"zoneLocationY":@"23",@"zoneLocationX":@"113"};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            
            return cell;
            break;
        }
        case 2:
        {
            HeNowOrderTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[HeNowOrderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize orderType:currentOrderType];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
            __weak typeof(self) weakSelf = self;
            
            cell.showOrderDetailBlock = ^(){
                NSLog(@"showOrderDetail");
                [weakSelf showOrderDetailWithOrder:nil];
            };
            cell.cancleServiceBlock = ^(){
                NSLog(@"取消服务");
                [weakSelf cancelServiceWithDict:dict];
            };
            cell.contactNurseBlock = ^(){
                NSLog(@"联系护士");
                [weakSelf contactNurseWithDict:dict];
            };
            cell.locationBlock = ^(){
                NSLog(@"locationBlock");
                NSDictionary *userLocationDic = @{@"zoneLocationY":@"23",@"zoneLocationX":@"113"};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            
            return cell;
            break;
        }
        case 3:
        {
            HeFinishOrderTabelCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[HeFinishOrderTabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize orderType:currentOrderType];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
            
            __weak typeof(self) weakSelf = self;
            
            cell.showOrderDetailBlock = ^(){
                NSLog(@"showOrderDetail");
                [weakSelf showOrderDetailWithOrder:nil];
            };
            cell.reCreateOrderBlock = ^(){
                NSLog(@"再来一单");
                [weakSelf reCreateOrderWithDict:dict];
            };
            cell.commentNurseBlock = ^(){
                NSLog(@"联系护士");
                [weakSelf commentOrderWithDict:dict];
            };
            cell.locationBlock = ^(){
                NSLog(@"locationBlock");
                NSDictionary *userLocationDic = @{@"zoneLocationY":@"23",@"zoneLocationX":@"113"};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            
            return cell;
            break;
        }
        default:
            break;
    }
    
    
//    cell.serviceContentL.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"orderSendServicecontent"]];
//
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"MM/dd HH:MM"];
//    [NSString stringWithFormat:@"%@",[dict valueForKey:@"orderSendGetOrderTime"]];
//    NSDate *stopTimeData = [NSDate dateWithTimeIntervalSince1970:[[dict valueForKey:@"orderSendGetOrderTime"] longLongValue]];
//    NSString *stopTimeStr = [formatter stringFromDate:stopTimeData];
//    cell.stopTimeL.text = stopTimeStr;
//    cell.orderMoney.text = [NSString stringWithFormat:@"￥%@",[dict valueForKey:@"orderSendTotalmoney"]];
//    NSString *address = [NSString stringWithFormat:@"%@",[dict valueForKey:@"orderSendAddree"]];
//    NSArray *addArr = [address componentsSeparatedByString:@","];
//    NSString *addressStr = nil;
//    //经度
//    NSString *zoneLocationX = nil;
//    //纬度
//    NSString *zoneLocationY = nil;
//    @try {
//        zoneLocationX = addArr[0];
//        zoneLocationY = addArr[1];
//        addressStr = [addArr objectAtIndex:2];
//    } @catch (NSException *exception) {
//        
//    } @finally {
//        
//    }
//    cell.addressL.text = [NSString stringWithFormat:@"%@",addressStr];
//    NSString *sex = [[dict valueForKey:@"orderSendSex"] integerValue]==1 ? @"男" : @"女";
//    cell.userInfoL.text = [NSString stringWithFormat:@"%@ %@ %@岁",[dict valueForKey:@"orderSendUsername"],sex,[dict valueForKey:@"orderSendAge"]];
    
    
    
    return  nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (currentOrderType == 2 || currentOrderType == 3) {
        return 230;
    }
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray *orderArray = dataSource[currentOrderType];
    
    NSDictionary *dict = nil;
    @try {
        dict = orderArray[section];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSLog(@"order = %@",dict);
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
