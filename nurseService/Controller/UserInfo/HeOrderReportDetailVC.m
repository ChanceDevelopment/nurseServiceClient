//
//  HeOrderReportDetailVC.m
//  nurseService
//
//  Created by Tony on 2017/1/18.
//  Copyright © 2017年 iMac. All rights reserved.
//  护理报告详情视图控制器

#import "HeOrderReportDetailVC.h"
#import "HeBaseTableViewCell.h"
#import "ReportCell.h"
#import "BrowserView.h"

@interface HeOrderReportDetailVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIScrollView *footerScrollview;
@property(strong,nonatomic)NSArray *datasSource;
@property(strong,nonatomic)NSMutableArray *reportArray;

@end

@implementation HeOrderReportDetailVC
@synthesize orderDict;
@synthesize tableview;
@synthesize footerScrollview;
@synthesize datasSource;
@synthesize reportArray;

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
        label.text = @"护理报告详情";
        [label sizeToFit];
        self.title = @"护理报告详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getReportDetail];
}

- (void)initializaiton
{
    [super initializaiton];
    reportArray = [[NSMutableArray alloc] initWithCapacity:0];
    datasSource = @[@"姓名",@"性别",@"身份证"];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Tool setExtraCellLineHidden:tableview];
    
   
}

//添加底部视图
- (void)addFooterView
{
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    
    footerScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH)];
    footerScrollview.showsVerticalScrollIndicator = NO;
    footerScrollview.showsHorizontalScrollIndicator = NO;
    tableview.tableFooterView = footerScrollview;
    
    CGFloat headerViewX = 0;
    CGFloat headerViewY = 0;
    CGFloat headerViewW = SCREENWIDTH;
    CGFloat headerViewH = 40;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(headerViewX, headerViewY, headerViewW, headerViewH)];
    headerView.backgroundColor = APPDEFAULTORANGE;
    [footerScrollview addSubview:headerView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 2, 20)];
    line.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:line];
    
    CGFloat titleLabelX = CGRectGetMaxX(line.frame) + 10;
    CGFloat titleLabelY = 0;
    CGFloat titleLabelW = headerViewW - 10 - titleLabelX;
    CGFloat titleLabelH = headerViewH;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.text = @"生命周期健康管理记录";
    titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    
    UIImageView *arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_white_down_gray"]];
    arrowIcon.frame = CGRectMake(87, 6, 25, 18);
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 10 - 120, 60, 120, 30)];
    tipView.backgroundColor = [UIColor whiteColor];
    [tipView addSubview:arrowIcon];
    tipView.layer.borderWidth = 0.5;
    tipView.layer.borderColor = APPDEFAULTORANGE.CGColor;
    UILabel *mytitleLabel = [[UILabel alloc] initWithFrame:tipView.bounds];
    mytitleLabel.backgroundColor = [UIColor clearColor];
    mytitleLabel.font = [UIFont systemFontOfSize:13.0];
    mytitleLabel.textColor = [UIColor grayColor];
    mytitleLabel.text = [NSString stringWithFormat:@" 全部报告(%ld)",[reportArray count]];
    [tipView addSubview:mytitleLabel];
    
    UIView *sepline = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(arrowIcon.frame) - 3, 0, 0.5, 30)];
    sepline.backgroundColor = APPDEFAULTORANGE;
    [tipView addSubview:sepline];
    
    [footerScrollview addSubview:tipView];
    
    CGFloat cellX = 0;
    CGFloat cellY = 100;
    CGFloat cellH = 150;
    CGFloat cellW = SCREENWIDTH;
    
    NSMutableArray *arrowImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    [arrowImageArray addObject:@"icon_left_arrow"];
    [arrowImageArray addObject:@"icon_left_arrow_two"];
    [arrowImageArray addObject:@"icon_left_arrow_three"];
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithCapacity:0];
    [colorArray addObject:APPDEFAULTORANGE];
    [colorArray addObject:RGB(71, 100, 160, 1)];
    [colorArray addObject:RGB(73, 161, 118, 1)];
    
    //创建每个报告的子视图
    for (NSInteger index = 0; index < [reportArray count]; index++) {
        NSDictionary *reportDict = reportArray[index];
        //报告创建时间
        id zoneCreatetimeObj = [reportDict objectForKey:@"nursingReportCreatetime"];
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
        
        NSString *orderSendServicecontent = reportDict[@"orderSendServicecontent"];
        if ([orderSendServicecontent isMemberOfClass:[NSNull class]] || orderSendServicecontent == nil) {
            orderSendServicecontent = @"";
        }
        NSArray *orderSendServicecontentArray = [orderSendServicecontent componentsSeparatedByString:@":"];
        orderSendServicecontent = orderSendServicecontentArray[0];
        
        //护士名称
        NSString *nurseNick = reportDict[@"nurseNick"];
        if ([nurseNick isMemberOfClass:[NSNull class]]) {
            nurseNick = @"";
        }
        //护士所属科室
        NSString *nurseOffice = reportDict[@"nurseOffice"];
        if ([nurseOffice isMemberOfClass:[NSNull class]]) {
            nurseOffice = @"";
        }
        nurseOffice = [NSString stringWithFormat:@"科室: %@",nurseOffice];
        //订单的地址
        NSString *orderSendAddree = reportDict[@"orderSendAddree"];
        if ([orderSendAddree isMemberOfClass:[NSNull class]]) {
            orderSendAddree = @"";
        }
        UIImage *arrow = [UIImage imageNamed:arrowImageArray[0]];
        UIColor *color = colorArray[0];
        
        //护理报告列表视图的模板
        ReportCell *reportView = [[ReportCell alloc] initViewWithColor:color frame:CGRectMake(cellX, cellY, cellW, cellH)];
        reportView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        reportView.timeLabel.text = time;
        reportView.serviceLabel.text = [NSString stringWithFormat:@"  %@",orderSendServicecontent];
        reportView.nameLabel.text = nurseNick;
        reportView.officeLabel.text = nurseOffice;
        reportView.addressLabel.text = orderSendAddree;
        [reportView updateFrame];
        [reportView setArrowImageWithImage:arrow];
        
        id obj = arrowImageArray[0];
        [arrowImageArray removeObjectAtIndex:0];
        [arrowImageArray addObject:obj];
        obj = colorArray[0];
        [colorArray removeObjectAtIndex:0];
        [colorArray addObject:obj];
        
        __weak HeOrderReportDetailVC *weakSelf = self;
        //查看护理报告详情的回调方法
        reportView.showReportDetailBlock = ^{
            NSString *nursingReportOrderid = reportDict[@"nursingReportOrderid"];
            if ([nursingReportOrderid isMemberOfClass:[NSNull class]]) {
                nursingReportOrderid = @"";
            }
            NSString *protectedPersonId = reportDict[@"protectedPersonId"];
            if ([protectedPersonId isMemberOfClass:[NSNull class]]) {
                protectedPersonId = @"";
            }
            //护理报告详情是个页面
            NSString *url = [NSString stringWithFormat:@"%@selectReportdetails.action?orderSendId=%@&protectedPersonId=%@",BASEURL,nursingReportOrderid,protectedPersonId];
            NSString *title = @"护理报告";
            BrowserView *scanReportDetailVC = [[BrowserView alloc] initWithURL:url title:title];
            scanReportDetailVC.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:scanReportDetailVC animated:YES];
        };
        
        [footerScrollview addSubview:reportView];
        
        cellY = cellY + cellH;
        
        footerScrollview.contentSize = CGSizeMake(0, cellY + 10);
    }
   
}

//获取护理报告详情
- (void)getReportDetail
{
    [self showHudInView:self.view hint:@"获取中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/report/selectReportByUserIdAndPersonCard.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *personCard = orderDict[@"protectedPersonCard"];
    if ([personCard isMemberOfClass:[NSNull class]] || personCard == nil) {
        personCard = @"";
    }
    //userId:用户的ID  personCard：受护人身份证
    NSDictionary *params = @{@"userId":userId,@"personCard":personCard};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            id jsonArray = respondDict[@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil) {
                return;
            }
            //保存数据
            [reportArray addObjectsFromArray:jsonArray];
            //添加底部视图
            [self addFooterView];
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
    }];
}

#pragma mark UITableViewdDataSource UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return datasSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    HeBaseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    CGFloat contentLabelX = 10;
    CGFloat contentLabelY = 0;
    CGFloat contentLabelW = SCREENWIDTH - 2 * contentLabelX;
    CGFloat contentLabelH = cellSize.height;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
    contentLabel.font = [UIFont systemFontOfSize:17.0];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor blackColor];
    [cell addSubview:contentLabel];
    NSString *content = @"";
    switch (row) {
        case 0:
        {
            //用户名字
            content = [NSString stringWithFormat:@"%@：%@",datasSource[row],orderDict[@"protectedPersonName"]];
            break;
        }
        case 1:
        {
            //年龄，性别
            id protectedPersonSex = orderDict[@"protectedPersonSex"];
            id protectedPersonAge = orderDict[@"protectedPersonAge"];
            if ([protectedPersonSex isMemberOfClass:[NSNull class]]) {
                protectedPersonSex = @"";
            }
            if ([protectedPersonAge isMemberOfClass:[NSNull class]]) {
                protectedPersonAge = @"";
            }
            NSString *sexStr = @"女";
            if ([protectedPersonSex integerValue] == ENUM_SEX_Boy) {
                sexStr = @"男";
            }
            content = [NSString stringWithFormat:@"%@：%@        年龄：%@",datasSource[row],sexStr,protectedPersonAge];
            
            break;
        }
        case 2:
        {
            //用户身份证卡号
            NSString *protectedPersonCard = orderDict[@"protectedPersonCard"];
            if ([protectedPersonCard isMemberOfClass:[NSNull class]] || protectedPersonCard == nil) {
                protectedPersonCard = @"";
            }
            NSMutableString *string = [[NSMutableString alloc] initWithString:protectedPersonCard];
            if ([protectedPersonCard length] >= 8) {
                [string replaceCharactersInRange:NSMakeRange(string.length - 8, 7) withString:@"*******"];
            }
            content = [NSString stringWithFormat:@"%@：%@",datasSource[row],string];
            break;
        }
            
        default:
            break;
    }
    contentLabel.text = content;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
