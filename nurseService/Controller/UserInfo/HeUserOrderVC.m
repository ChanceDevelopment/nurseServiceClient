//
//  HeUserOrderVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserOrderVC.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "HeUserOrderCell.h"
#import "HeOrderCommitVC.h"
#import "HeOrderDetailVC.h"

@interface HeUserOrderVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger pageNum;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeUserOrderVC
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
        label.text = @"订单中心";
        [label sizeToFit];
        self.title = @"订单中心";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self loadOrderData];
}

- (void)initializaiton
{
    [super initializaiton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrder:) name:@"updateOrder" object:nil];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNum = 0;
}

- (void)initView
{
    [super initView];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
        pageNum = 0;
        
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
        pageNum++;
    }];
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
        [self loadOrderData];
    }];
    NSLog(@"endRefreshing");
}

- (void)updateOrder:(NSNotification *)notification
{
    //重新刷新订单数据
    pageNum = 0;
    [self loadOrderData];
}

- (void)loadOrderData
{
    [self showHudInView:tableview hint:@"加载中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/OrderSendHostory.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary * params  = @{@"userId":userId,@"pageNum":pageNumStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                jsonArray = [NSArray array];
                if (pageNum != 0) {
                    pageNum--;
                }
            }
            if (pageNum == 0) {
                [dataSource removeAllObjects];
            }
            
            [dataSource addObjectsFromArray:jsonArray];
            
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
    }];
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"HeOrderTableViewCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[section];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    id orderSendTypeObj = dict[@"orderSendType"];
    if ([orderSendTypeObj isMemberOfClass:[NSNull class]]) {
        orderSendTypeObj = @"";
    }
    id orderSendStateObj = dict[@"orderSendState"];
    if ([orderSendStateObj isMemberOfClass:[NSNull class]]) {
        orderSendStateObj = @"";
    }
    
    HeUserOrderCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeUserOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize orderType:[orderSendTypeObj integerValue] orderState:[orderSendStateObj integerValue]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    __weak typeof(self) weakSelf = self;
    
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
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    return 160;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *orderDict = nil;
    @try {
        orderDict = dataSource[section];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    id currentOrderTypeObj = orderDict[@"orderSendType"];
    if ([currentOrderTypeObj isMemberOfClass:[NSNull class]]) {
        currentOrderTypeObj = @"";
    }
    NSInteger currentOrderType = [currentOrderTypeObj integerValue];
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
        HeOrderDetailVC *orderDetailVC = [[HeOrderDetailVC alloc] init];
        orderDetailVC.orderId = orderSendId;
        orderDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:orderDetailVC animated:YES];
    }
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
