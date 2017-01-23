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
#import "HeNurseDetailVC.h"
#import "HeCommentNurseVC.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"

@interface OrderViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
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
@property(strong,nonatomic)NSDictionary *currentHandleOrderInfo;

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
        self.navigationTabBar.backgroundColor = [UIColor whiteColor];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        self.navigationTabBar.sliderBackgroundColor = APPDEFAULTORANGE;
        self.navigationTabBar.buttonNormalTitleColor = [UIColor blackColor];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrder:) name:@"updateOrder" object:nil];
}

- (void)initView
{
    [super initView];
    [self.view addSubview:self.navigationTabBar];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
        [self loadOrderDataWithOrderState:currentOrderType];
        
    }];
    
//    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        self.tableview.footer.automaticallyHidden = YES;
//        self.tableview.footer.hidden = NO;
//        // 进入刷新状态后会自动调用这个block，加载更多
//        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
//        
//    }];
}

- (void)endRefreshing
{
    [self.tableview.footer endRefreshing];
    self.tableview.footer.hidden = YES;
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        [self loadOrderDataWithOrderState:currentOrderType];
    }];
    NSLog(@"endRefreshing");
}

- (void)updateOrder:(NSNotification *)notification
{
    //更新所有订单的状态
    [self loadOrderDataWithOrderState:0];
    [self loadOrderDataWithOrderState:1];
    [self loadOrderDataWithOrderState:2];
    [self loadOrderDataWithOrderState:3];
}

#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    currentOrderType = index;
    [self loadOrderDataWithOrderState:currentOrderType];
//    [tableview reloadData];
}

- (void)loadOrderDataWithOrderState:(NSInteger)orderState
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/OrderSendDescription.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *orderStateStr = [NSString stringWithFormat:@"%ld",orderState];
    NSDictionary * params  = @{@"userId":userId,@"orderState":orderStateStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                jsonArray = [NSArray array];
            }
            NSMutableArray *orderArray = dataSource[orderState];
            [orderArray removeAllObjects];
            [orderArray addObjectsFromArray:jsonArray];
            
            if (orderState == currentOrderType) {
                if ([jsonArray count] == 0) {
                    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                    UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                    CGFloat scale = noImage.size.height / noImage.size.width;
                    CGFloat imageW = 120;
                    CGFloat imageH = imageW * scale;
                    CGFloat imageX = (SCREENWIDTH - imageW) / 2.0;
                    CGFloat imageY = SCREENHEIGH - imageH - 100;
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                    imageview.frame = CGRectMake(imageX, imageY, imageW, imageH);
                    imageview.center = bgView.center;
                    [bgView addSubview:imageview];
                    tableview.backgroundView = bgView;
                }
                else{
                    tableview.backgroundView = nil;
                }
                [tableview reloadData];
            }
            
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        NSLog(@"errorInfo = %@",err);
    }];
}

- (void)showPaitentInfoWith:(NSDictionary *)dict
{
    NSString *orderSendUsername = dict[@"orderSendUsername"];
    NSArray *orderSendUsernameArray = [orderSendUsername componentsSeparatedByString:@","];
    @try {
        orderSendUsername = orderSendUsernameArray[0];
    } @catch (NSException *exception) {
        orderSendUsername = @"";
    } @finally {
        
    }
    NSString *personId = orderSendUsername;
    NSDictionary *paitentInfoDict = @{@"personId":personId};
    HePaitentInfoVC *paitentInfoVC = [[HePaitentInfoVC alloc] init];
    paitentInfoVC.userInfoDict = [[NSDictionary alloc] initWithDictionary:paitentInfoDict];
    paitentInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:paitentInfoVC animated:YES];
}

- (void)showNurseDetailWithOrder:(NSDictionary *)orderDict
{
    NSString *nurseId = orderDict[@"nurseId"];
    if ([nurseId isMemberOfClass:[NSNull class]] || nurseId == nil) {
        nurseId = @"";
    }
    NSDictionary *infoDict = @{@"nurseId":nurseId};
    HeNurseDetailVC *nurseDetailVC = [[HeNurseDetailVC alloc] init];
    nurseDetailVC.nurseDictInfo = [[NSDictionary alloc] initWithDictionary:infoDict];
    nurseDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nurseDetailVC animated:YES];
}

- (void)showOrderDetailWithOrder:(NSDictionary *)orderDict
{
    if (currentOrderType == 0) {
        //预约框，跳订单确认界面
        NSString *orderSendId = orderDict[@"orderSendId"];
        if ([orderSendId isMemberOfClass:[NSNull class]]) {
            orderSendId = @"";
        }
        HeOrderCommitVC *orderCommitVC = [[HeOrderCommitVC alloc] init];
        orderCommitVC.orderId = orderSendId;
        orderCommitVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:orderCommitVC animated:YES];
        return;
    }
    else{
        NSString *orderSendId = orderDict[@"orderSendId"];
        if ([orderSendId isMemberOfClass:[NSNull class]]) {
            orderSendId = @"";
        }
        id isEvaluate = orderDict[@"isEvaluate"];
        if ([isEvaluate isMemberOfClass:[NSNull class]] || isEvaluate == nil) {
            isEvaluate = @"";
        }
        HeOrderDetailVC *orderDetailVC = [[HeOrderDetailVC alloc] init];
        orderDetailVC.isEvaluate = [isEvaluate boolValue];
        orderDetailVC.orderId = orderSendId;
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
    _currentHandleOrderInfo = orderInfo;
    if (ISIOS7) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除服务" message:@"确定删除这笔订单吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 100;
        [alertView show];
        return;
    }
    else{
        __weak OrderViewController *weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除服务" message:@"确定删除这笔订单吗？"  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            _currentHandleOrderInfo = nil;
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [weakSelf requestDeleteOrder:orderInfo];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1) {
        //删除订单
        [self requestDeleteOrder:_currentHandleOrderInfo];
    }
    else if (alertView.tag == 200 && buttonIndex == 1){
        //取消订单
        [self requestCancelOrder:_currentHandleOrderInfo];
    }
    else if (buttonIndex == 0){
        _currentHandleOrderInfo = nil;
    }
    
}

- (void)requestDeleteOrder:(NSDictionary *)orderInfo
{
    NSLog(@"cancelService");
    NSString *orderSendId = orderInfo[@"orderSendId"];
    if ([orderSendId isMemberOfClass:[NSNull class]] || orderSendId == nil) {
        orderSendId = @"";
    }
    NSDictionary * params  = @{@"orderSendId":orderSendId};
    [self showHudInView:tableview hint:@"删除中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/delOrderSend.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            [self showHint:@"成功删除服务"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateOrder" object:nil];
            
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        [self hideHud];
        NSLog(@"errorInfo = %@",err);
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)requestCancelOrder:(NSDictionary *)orderInfo
{
    NSLog(@"cancelService");
    NSString *orderSendId = orderInfo[@"orderSendId"];
    if ([orderSendId isMemberOfClass:[NSNull class]] || orderSendId == nil) {
        orderSendId = @"";
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    //0用户 1护士
    NSString *identity = @"0";
    [self showHudInView:tableview hint:@"取消中..."];
    NSDictionary * params  = @{@"orderSendId":orderSendId,@"userId":userId,@"identity":identity};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/cancelOrder.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            [self showHint:@"成功取消服务"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateOrder" object:nil];
            
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
        NSLog(@"errorInfo = %@",err);
    }];
}

//立即付款
- (void)payMoneyWithDict:(NSDictionary *)orderInfo
{
    //预约框，跳订单确认界面
    NSString *orderSendId = orderInfo[@"orderSendId"];
    if ([orderSendId isMemberOfClass:[NSNull class]]) {
        orderSendId = @"";
    }
    HeOrderCommitVC *orderCommitVC = [[HeOrderCommitVC alloc] init];
    orderCommitVC.orderId = orderSendId;
    orderCommitVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderCommitVC animated:YES];
}

//已预约，进行中
//取消服务
- (void)cancelServiceWithDict:(NSDictionary *)orderInfo
{
    _currentHandleOrderInfo = orderInfo;
    if (ISIOS7) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求取消" message:@"若取消这笔订单，您支付的费用将于一周内全额退还至您的余额中，确定要取消这笔订单吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 200;
        [alertView show];
        return;
    }
    else{
        __weak OrderViewController *weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求取消" message:@"若取消这笔订单，您支付的费用将于一周内全额退还至您的余额中，确定要取消这笔订单吗？"  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            _currentHandleOrderInfo = nil;
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [weakSelf requestCancelOrder:orderInfo];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
//    NSLog(@"cancelService");
//    NSDictionary * params  = nil;
//    NSString *requestUrl = [NSString stringWithFormat:@"%@",BASEURL];
//    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
//        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
//        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
//            
//            
//        }
//        else{
//            NSString *data = respondDict[@"data"];
//            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
//                data = ERRORREQUESTTIP;
//            }
//            [self showHint:data];
//        }
//    } failure:^(NSError* err){
//        NSLog(@"errorInfo = %@",err);
//    }];
}

//进行中
- (void)contactNurseWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"contactNurse");
    NSString *nursePhone = orderInfo[@"nursePhone"];
    if ([nursePhone isMemberOfClass:[NSNull class]] || nursePhone == nil) {
        [self showHint:@"暂无护士的联系方式"];
    }
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",nursePhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
//    NSDictionary * params  = nil;
//    NSString *requestUrl = [NSString stringWithFormat:@"%@",BASEURL];
//    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
//        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
//        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
//            
//            
//        }
//        else{
//            NSString *data = respondDict[@"data"];
//            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
//                data = ERRORREQUESTTIP;
//            }
//            [self showHint:data];
//        }
//    } failure:^(NSError* err){
//        NSLog(@"errorInfo = %@",err);
//    }];
}

//已完成
//再来一单
- (void)reCreateOrderWithDict:(NSDictionary *)orderInfo
{
    return;
    NSString *nurseId = orderInfo[@"nurseId"];
    if ([nurseId isMemberOfClass:[NSNull class]] || nurseId == nil) {
        nurseId = @"";
    }
    NSDictionary *infoDict = @{@"nurseId":nurseId};
    HeNurseDetailVC *nurseDetailVC = [[HeNurseDetailVC alloc] init];
    nurseDetailVC.nurseDictInfo = [[NSDictionary alloc] initWithDictionary:infoDict];
    nurseDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nurseDetailVC animated:YES];
    
//    NSLog(@"reCreateOrder");
//    NSDictionary * params  = nil;
//    NSString *requestUrl = [NSString stringWithFormat:@"%@",BASEURL];
//    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
//        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
//        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
//            
//            
//        }
//        else{
//            NSString *data = respondDict[@"data"];
//            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
//                data = ERRORREQUESTTIP;
//            }
//            [self showHint:data];
//        }
//    } failure:^(NSError* err){
//        NSLog(@"errorInfo = %@",err);
//    }];
}
//前往评价
- (void)commentOrderWithDict:(NSDictionary *)orderInfo
{
    NSLog(@"commentOrder");
    HeCommentNurseVC *commentNurseVC = [[HeCommentNurseVC alloc] init];
    commentNurseVC.nurseDict = [[NSDictionary alloc] initWithDictionary:orderInfo];
    commentNurseVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentNurseVC animated:YES];
//    NSDictionary * params  = nil;
//    NSString *requestUrl = [NSString stringWithFormat:@"%@",BASEURL];
//    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
//        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
//        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
//            
//            
//        }
//        else{
//            NSString *data = respondDict[@"data"];
//            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
//                data = ERRORREQUESTTIP;
//            }
//            [self showHint:data];
//        }
//    } failure:^(NSError* err){
//        NSLog(@"errorInfo = %@",err);
//    }];
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
                [weakSelf showOrderDetailWithOrder:dict];
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
                NSString *orderSendAddree = dict[@"orderSendAddree"];
                if ([orderSendAddree isMemberOfClass:[NSNull class]]) {
                    orderSendAddree = @"";
                }
                NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                NSString *zoneLocationY = nil;
                NSString *zoneLocationX = nil;
                @try {
                    zoneLocationX= orderSendAddreeArray[0];
                    zoneLocationY = orderSendAddreeArray[1];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                NSDictionary *userLocationDic = @{@"zoneLocationY":zoneLocationY,@"zoneLocationX":zoneLocationX};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            NSString *serviceName = dict[@"orderSendServicecontent"];
            if ([serviceName isMemberOfClass:[NSNull class]] || serviceName == nil) {
                serviceName = @"";
            }
            NSArray *serviceArray = [serviceName componentsSeparatedByString:@":"];
            @try {
                serviceName = serviceArray[0];
            } @catch (NSException *exception) {
                
            } @finally {
                
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
            NSArray *userArray = [username componentsSeparatedByString:@","];
            NSString *nickname = nil;
            @try {
                nickname = userArray[1];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            id orderSendSex = dict[@"orderSendSex"];
            NSString *sexStr = @"女";
            if ([orderSendSex isMemberOfClass:[NSNull class]]) {
                orderSendSex = @"";
            }
            if ([orderSendSex integerValue] == ENUM_SEX_Boy) {
                sexStr = @"男";
            }
            
            id orderSendAge = dict[@"orderSendAge"];
            if ([orderSendAge isMemberOfClass:[NSNull class]]) {
                orderSendAge = @"";
            }
            NSString *ageStr = [NSString stringWithFormat:@"%@",orderSendAge];
            
            cell.userInfoL.text = [NSString stringWithFormat:@"%@  %@  %@",nickname,sexStr,ageStr];
            
            id orderSendTotalmoney = dict[@"orderSendTotalmoney"];
            if ([orderSendTotalmoney isMemberOfClass:[NSNull class]] || orderSendTotalmoney == nil) {
                orderSendTotalmoney = @"";
            }
            cell.orderMoney.text = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
            
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
                [weakSelf showOrderDetailWithOrder:dict];
            };
            cell.cancleServiceBlock = ^(){
                NSLog(@"取消服务");
                [weakSelf cancelServiceWithDict:dict];
            };
            cell.locationBlock = ^(){
                NSLog(@"locationBlock");
                NSString *orderSendAddree = dict[@"orderSendAddree"];
                if ([orderSendAddree isMemberOfClass:[NSNull class]]) {
                    orderSendAddree = @"";
                }
                NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                NSString *zoneLocationY = nil;
                NSString *zoneLocationX = nil;
                @try {
                    zoneLocationX= orderSendAddreeArray[0];
                    zoneLocationY = orderSendAddreeArray[1];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                NSDictionary *userLocationDic = @{@"zoneLocationY":zoneLocationY,@"zoneLocationX":zoneLocationX};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            
            NSString *serviceName = dict[@"orderSendServicecontent"];
            if ([serviceName isMemberOfClass:[NSNull class]] || serviceName == nil) {
                serviceName = @"";
            }
            NSArray *serviceArray = [serviceName componentsSeparatedByString:@":"];
            @try {
                serviceName = serviceArray[0];
            } @catch (NSException *exception) {
                
            } @finally {
                
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
            NSArray *userArray = [username componentsSeparatedByString:@","];
            NSString *nickname = nil;
            @try {
                nickname = userArray[1];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            id orderSendSex = dict[@"orderSendSex"];
            NSString *sexStr = @"女";
            if ([orderSendSex isMemberOfClass:[NSNull class]]) {
                orderSendSex = @"";
            }
            if ([orderSendSex integerValue] == ENUM_SEX_Boy) {
                sexStr = @"男";
            }
            
            id orderSendAge = dict[@"orderSendAge"];
            if ([orderSendAge isMemberOfClass:[NSNull class]]) {
                orderSendAge = @"";
            }
            NSString *ageStr = [NSString stringWithFormat:@"%@",orderSendAge];
            
            cell.userInfoL.text = [NSString stringWithFormat:@"%@  %@  %@",nickname,sexStr,ageStr];
            
            id orderSendTotalmoney = dict[@"orderSendTotalmoney"];
            if ([orderSendTotalmoney isMemberOfClass:[NSNull class]] || orderSendTotalmoney == nil) {
                orderSendTotalmoney = @"";
            }
            cell.orderMoney.text = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
            
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
                [weakSelf showOrderDetailWithOrder:dict];
            };
            cell.showNurseInfoBlock = ^(){
                NSLog(@"showOrderDetail");
                [weakSelf showNurseDetailWithOrder:dict];
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
                NSString *orderSendAddree = dict[@"orderSendAddree"];
                if ([orderSendAddree isMemberOfClass:[NSNull class]]) {
                    orderSendAddree = @"";
                }
                NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                NSString *zoneLocationY = nil;
                NSString *zoneLocationX = nil;
                @try {
                    zoneLocationX= orderSendAddreeArray[0];
                    zoneLocationY = orderSendAddreeArray[1];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                NSDictionary *userLocationDic = @{@"zoneLocationY":zoneLocationY,@"zoneLocationX":zoneLocationX};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            
            NSString *serviceName = dict[@"orderSendServicecontent"];
            if ([serviceName isMemberOfClass:[NSNull class]] || serviceName == nil) {
                serviceName = @"";
            }
            NSArray *serviceArray = [serviceName componentsSeparatedByString:@":"];
            @try {
                serviceName = serviceArray[0];
            } @catch (NSException *exception) {
                
            } @finally {
                
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
            NSArray *userArray = [username componentsSeparatedByString:@","];
            NSString *nickname = nil;
            @try {
                nickname = userArray[1];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            id orderSendSex = dict[@"orderSendSex"];
            NSString *sexStr = @"女";
            if ([orderSendSex isMemberOfClass:[NSNull class]]) {
                orderSendSex = @"";
            }
            if ([orderSendSex integerValue] == ENUM_SEX_Boy) {
                sexStr = @"男";
            }
            
            id orderSendAge = dict[@"orderSendAge"];
            if ([orderSendAge isMemberOfClass:[NSNull class]]) {
                orderSendAge = @"";
            }
            NSString *ageStr = [NSString stringWithFormat:@"%@",orderSendAge];
            
            cell.userInfoL.text = [NSString stringWithFormat:@"%@  %@  %@",nickname,sexStr,ageStr];
            
            id orderSendTotalmoney = dict[@"orderSendTotalmoney"];
            if ([orderSendTotalmoney isMemberOfClass:[NSNull class]] || orderSendTotalmoney == nil) {
                orderSendTotalmoney = @"";
            }
            cell.orderMoney.text = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
            
            NSString *nurseNick = dict[@"nurseNick"];
            if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
                nurseNick = @"小明";
            }
            id nurseSex = dict[@"nurseSex"];
            if ([nurseSex isMemberOfClass:[NSNull class]] || nurseSex == nil) {
                nurseSex = @"";
            }
            NSString *nurseStr = @"女";
            if ([nurseSex integerValue] == ENUM_SEX_Boy) {
                nurseStr = @"男";
            }
            
            id nurseAge = dict[@"nurseAge"];
            if ([nurseAge isMemberOfClass:[NSNull class]] || nurseAge == nil) {
                nurseAge = @"24";
            }
            cell.nurseInfoL.text = [NSString stringWithFormat:@"%@  %@  %@",nurseNick,nurseStr,nurseAge];
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
                [weakSelf showOrderDetailWithOrder:dict];
            };
            cell.showNurseInfoBlock = ^(){
                NSLog(@"showOrderDetail");
                [weakSelf showNurseDetailWithOrder:dict];
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
                NSString *orderSendAddree = dict[@"orderSendAddree"];
                if ([orderSendAddree isMemberOfClass:[NSNull class]]) {
                    orderSendAddree = @"";
                }
                NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                NSString *zoneLocationY = nil;
                NSString *zoneLocationX = nil;
                @try {
                    zoneLocationX= orderSendAddreeArray[0];
                    zoneLocationY = orderSendAddreeArray[1];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                NSDictionary *userLocationDic = @{@"zoneLocationY":zoneLocationY,@"zoneLocationX":zoneLocationX};
                [weakSelf goLocationWithLocation:userLocationDic];
            };
            cell.showUserInfoBlock = ^(){
                NSLog(@"showUserInfoBlock");
                [weakSelf showPaitentInfoWith:dict];
            };
            
            NSString *serviceName = dict[@"orderSendServicecontent"];
            if ([serviceName isMemberOfClass:[NSNull class]] || serviceName == nil) {
                serviceName = @"";
            }
            NSArray *serviceArray = [serviceName componentsSeparatedByString:@":"];
            @try {
                serviceName = serviceArray[0];
            } @catch (NSException *exception) {
                
            } @finally {
                
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
            NSArray *userArray = [username componentsSeparatedByString:@","];
            NSString *nickname = nil;
            @try {
                nickname = userArray[1];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            id orderSendSex = dict[@"orderSendSex"];
            NSString *sexStr = @"女";
            if ([orderSendSex isMemberOfClass:[NSNull class]]) {
                orderSendSex = @"";
            }
            if ([orderSendSex integerValue] == ENUM_SEX_Boy) {
                sexStr = @"男";
            }
            
            id orderSendAge = dict[@"orderSendAge"];
            if ([orderSendAge isMemberOfClass:[NSNull class]]) {
                orderSendAge = @"";
            }
            NSString *ageStr = [NSString stringWithFormat:@"%@",orderSendAge];
            
            cell.userInfoL.text = [NSString stringWithFormat:@"%@  %@  %@",nickname,sexStr,ageStr];
            
            id orderSendTotalmoney = dict[@"orderSendTotalmoney"];
            if ([orderSendTotalmoney isMemberOfClass:[NSNull class]] || orderSendTotalmoney == nil) {
                orderSendTotalmoney = @"";
            }
            cell.orderMoney.text = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
            
            NSString *nurseNick = dict[@"nurseNick"];
            if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
                nurseNick = @"小明";
            }
            id nurseSex = dict[@"nurseSex"];
            if ([nurseSex isMemberOfClass:[NSNull class]] || nurseSex == nil) {
                nurseSex = @"";
            }
            NSString *nurseStr = @"女";
            if ([nurseSex integerValue] == ENUM_SEX_Boy) {
                nurseStr = @"男";
            }
            
            id nurseAge = dict[@"nurseAge"];
            if ([nurseAge isMemberOfClass:[NSNull class]] || nurseAge == nil) {
                nurseAge = @"24";
            }
            cell.nurseInfoL.text = [NSString stringWithFormat:@"%@  %@  %@",nurseNick,nurseStr,nurseAge];
            
            id isEvaluate = dict[@"isEvaluate"];
            if ([isEvaluate isMemberOfClass:[NSNull class]]) {
                isEvaluate = @"";
            }
            if ([isEvaluate boolValue]) {
                cell.commentNurseBlock = nil;
                [cell setRightLabelWithText:@"已评价"];
            }
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
        return 240;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateOrder" object:nil];
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
