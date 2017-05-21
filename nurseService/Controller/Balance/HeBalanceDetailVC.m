//
//  HeBalanceDetailVC.m
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//  资金明细视图控制器

#import "HeBalanceDetailVC.h"
#import "HeBalanceDetailCell.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"

@interface HeBalanceDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    //当前的页码数
    NSInteger pageNum;
}
//视图的列表
@property(strong,nonatomic)IBOutlet UITableView *tableview;
//视图标题的配置
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeBalanceDetailVC
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
        label.text = @"明细";
        [label sizeToFit];
        
        self.title = @"明细";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadDetail];
}

//资源变量的初始化
- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNum = 0;
}

//初始化视图
- (void)initView
{
    [super initView];
    //设置列表视图的背景色
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    //下拉刷新方法
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
    }];
    
    //上拉加载更多的方法
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
    }];
}

//停止加载的回调方法
- (void)endRefreshing
{
    [self.tableview.footer endRefreshing];
    self.tableview.footer.hidden = YES;
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        [self loadDetail];
    }];
    NSLog(@"endRefreshing");
}


//加载资金明细
- (void)loadDetail
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/nurseAnduser/selectCapitalUserPoolInfo.action",BASEURL];
    //userId：用户的ID
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    //pageNum：页码数
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"pageNum":pageNumStr};
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
            //如果是刷新，先清除当前的数据
            if (pageNum == 0) {
                [dataSource removeAllObjects];
            }
            //如果加载更多的情况下没有数据，参数回复到原来状态
            if (pageNum != 0 && [resultArray count] == 0) {
                pageNum--;
            }
            //对请求回来的数据进行处理保存到容器里面
            for (NSDictionary *zoneDict in resultArray) {
                [dataSource addObject:zoneDict];
            }
            //刷新列表属兔
            [self.tableview reloadData];
        }
        else{
            
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
    
    static NSString *cellIndentifier = @"HeNearbyTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    //配置资金明细的视图模板
    HeBalanceDetailCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBalanceDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    //获取资金产生变化的时候时间
    id receiveTimeObj = [dict objectForKey:@"capitalUserPoolCreatetime"];
    if ([receiveTimeObj isMemberOfClass:[NSNull class]] || receiveTimeObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        receiveTimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long timestamp = [receiveTimeObj longLongValue];
    NSString *receiveTime = [NSString stringWithFormat:@"%lld",timestamp];
    if ([receiveTime length] > 3) {
        //时间戳
        receiveTime = [receiveTime substringToIndex:[receiveTime length] - 3];
    }
    
    NSString *receiveTimeStr = [Tool convertTimespToString:[receiveTime longLongValue] dateFormate:@"yyyy-MM-dd HH:mm"];
    cell.timeLabel.text = receiveTimeStr;
    
    //资金变化的内容
    cell.contentLabel.text = [NSString stringWithFormat:@"%@",dict[@"capitalUserPoolSpeak"]];
    id receiveMoney = dict[@"capitalUserPoolMoney"];
    if ([receiveMoney isMemberOfClass:[NSNull class]]) {
        receiveMoney = @"";
    }
    //资金变化的标记 0：发布  1：领取
    id capitalUserPoolPeopleIdentity = dict[@"capitalUserPoolPeopleIdentity"];
    if ([capitalUserPoolPeopleIdentity isMemberOfClass:[NSNull class]] || capitalUserPoolPeopleIdentity == nil) {
        capitalUserPoolPeopleIdentity = @"";
    }
    if ([capitalUserPoolPeopleIdentity integerValue] == 0) {
        //发布
        cell.moneyLabel.text = [NSString stringWithFormat:@"-%.2f元", [receiveMoney floatValue]];
    }
    else{
        //领取
        cell.moneyLabel.textColor = [UIColor greenColor];
        cell.moneyLabel.text = [NSString stringWithFormat:@"+%.2f元", [receiveMoney floatValue]];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
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
