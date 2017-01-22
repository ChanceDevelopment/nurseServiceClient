//
//  HeMessageVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserCouponVC.h"
#import "HeBaseTableViewCell.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "HeUserCouponCell.h"

@interface HeUserCouponVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger pageNum;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeUserCouponVC
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
        label.text = @"我的优惠券";
        [label sizeToFit];
        self.title = @"我的优惠券";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self loadCoupon];
}

- (void)initializaiton
{
    [super initializaiton];
    pageNum = 0;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Tool setExtraCellLineHidden:tableview];
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    
    __weak HeUserCouponVC *weakSelf = self;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
        [weakSelf loadCoupon];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
        [weakSelf loadCoupon];
        
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
    }];
    NSLog(@"endRefreshing");
}

- (void)loadCoupon
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/nurseAnduser/selectAllUserCouponInfo.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *state = @"0";
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"pageNum":pageNumStr,@"state":state};
    [self showHudInView:self.view hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                resultArray = [NSArray array];
            }
            if (pageNum == 0) {
                [dataSource removeAllObjects];
            }
            if (pageNum != 0 && [resultArray count] == 0) {
                pageNum--;
            }
            [dataSource addObjectsFromArray:resultArray];
            
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
            
            [self.tableview reloadData];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"";
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeUserCouponCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeUserCouponCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeUserCouponCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    NSString *couponUserSperak = dict[@"couponUserSperak"];
    if ([couponUserSperak isMemberOfClass:[NSNull class]]) {
        couponUserSperak = @"";
    }
    cell.contentLabel.text = couponUserSperak;
    
    
    id zoneCreatetimeObj = [dict objectForKey:@"standInnerLetterCreatetime"];
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
    
    NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"YYYY-MM-dd"];
    cell.timeLabel.text = [NSString stringWithFormat:@"有效期至: %@",time];
    
    id couponUserMoneyObj = dict[@"couponUserMoney"];
    if ([couponUserMoneyObj isMemberOfClass:[NSNull class]] || couponUserMoneyObj == nil) {
        couponUserMoneyObj = @"";
    }
    CGFloat couponUserMoney = [couponUserMoneyObj floatValue];
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",couponUserMoney];
    
    id couponUserFullGiveObj = dict[@"couponUserFullGive"];
    if ([couponUserFullGiveObj isMemberOfClass:[NSNull class]] || couponUserFullGiveObj == nil) {
        couponUserFullGiveObj = @"";
    }
    CGFloat couponUserFullGive = [couponUserFullGiveObj floatValue];
    cell.conditionLabel.text = [NSString stringWithFormat:@"满%.0f可用",couponUserFullGive];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    id couponUserFullGiveObj = dict[@"couponUserFullGive"];

    id orderSendCostmoney = _orderDict[@"orderSendCostmoney"];
    if ([orderSendCostmoney floatValue] < [couponUserFullGiveObj floatValue]) {
        [self showHint:@"优惠券不可用"];
        return;
    }
    id couponUserMoneyObj = dict[@"couponUserMoney"];
    if ([couponUserMoneyObj isMemberOfClass:[NSNull class]] || couponUserMoneyObj == nil) {
        couponUserMoneyObj = @"";
    }
    CGFloat realGive = [orderSendCostmoney floatValue] - [couponUserMoneyObj floatValue];
    if (realGive < 0.001) {
        realGive = 0;
    }
    NSString *orderSendCostmoneyStr = [NSString stringWithFormat:@"%.2f",realGive];
    
    id orderSendTrafficmoney = _orderDict[@"orderSendTrafficmoney"];
    if ([orderSendTrafficmoney isMemberOfClass:[NSNull class]] || orderSendTrafficmoney == nil) {
        orderSendTrafficmoney = @"";
    }
    realGive = realGive + [orderSendTrafficmoney floatValue];
    NSString *realGiveStr = [NSString stringWithFormat:@"%.2f",realGive];
    
    NSMutableDictionary *m_Dict = [[NSMutableDictionary alloc] initWithDictionary:_orderDict];
    [m_Dict setObject:couponUserMoneyObj forKey:@"orderSendCoupon"];
    [m_Dict setObject:realGiveStr forKey:@"orderSendTotalmoney"];
//    [m_Dict setObject:orderSendCostmoneyStr forKey:@"orderSendCostmoney"];
    
    _orderDict = [[NSDictionary alloc] initWithDictionary:m_Dict];
    
    
    [self.selectDelegate selectCouponWithOrder:_orderDict];
    [self.navigationController popViewControllerAnimated:YES];
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
