//
//  HeOrderReportVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeOrderReportVC.h"
#import "RPRingedPages.h"
#import "MLLabel+Size.h"
#import "MLLabel.h"
#import "HeOrderReportDetailVC.h"

@interface HeOrderReportVC ()<RPRingedPagesDelegate, RPRingedPagesDataSource>
@property (nonatomic, strong) RPRingedPages *pages;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *reportViewDataSource;

@end

@implementation HeOrderReportVC
@synthesize dataSource;
@synthesize reportViewDataSource;

- (RPRingedPages *)pages {
    if (_pages == nil) {
        
        CGFloat pagesX = 20;
        CGFloat pagesH = 320;
        CGFloat pagesY = 50;
        CGFloat pagesW = SCREENWIDTH - 2 * pagesX;
        
        CGRect pagesFrame = CGRectMake(pagesX, pagesY, pagesW, pagesH);
        
        RPRingedPages *pages = [[RPRingedPages alloc] initWithFrame:pagesFrame];
        pages.carousel.mainPageSize = CGSizeMake(pagesW, pagesH);
        pages.carousel.pageScale = 0.5;
        pages.dataSource = self;
        pages.delegate = self;
        pages.showPageControl = NO;
        
        _pages = pages;
    }
    return _pages;
}

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
        label.text = @"护理报告";
        [label sizeToFit];
        self.title = @"护理报告";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getOrderReportData];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    reportViewDataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [self.view addSubview:self.pages];
    
}

- (void)getOrderReportData
{
    [self showHudInView:self.view hint:@"获取中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/report/selectReportByUserId.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    
    NSDictionary *params = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            id jsonArray = respondDict[@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil) {
                return;
            }
//            NSInteger index = 0;
            for (NSDictionary *dict in jsonArray) {
                [dataSource addObject:dict];
                //左上角的标题
//                NSString *title = [NSString stringWithFormat:@"%ld/%ld",index,[jsonArray count]];
//                UIView *reportView = [self getReportViewWithReportInfo:dict title:title];
//                [reportViewDataSource addObject:reportView];
//                index++;
            }
            [self.pages reloadData];
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

- (UIView *)getReportViewWithReportInfo:(NSDictionary *)reportDict title:(NSString *)title
{
    UIView *reportView = [[UIView alloc] init];
    reportView.backgroundColor = APPDEFAULTORANGE;
    reportView.layer.backgroundColor = APPDEFAULTORANGE.CGColor;
    reportView.layer.masksToBounds = YES;
    reportView.layer.cornerRadius = 5.0;

    CGFloat titleLabelX = 15;
    CGFloat titleLabelY = 15;
    CGFloat titleLabelW = 100;
    CGFloat titleLabelH = 30;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    [reportView addSubview:titleLabel];
    
    CGFloat footerViewX = 0;
    CGFloat footerViewY = CGRectGetHeight(_pages.frame) / 2.0 - 20;
    CGFloat footerViewW = CGRectGetWidth(_pages.frame);
    CGFloat footerViewH = CGRectGetHeight(_pages.frame) - footerViewY;
    
    CGFloat nameLabelX = 10;
    CGFloat nameLabelY = footerViewY - 10 - 65;
    CGFloat nameLabelW = footerViewW - 2 * nameLabelX;
    CGFloat nameLabelH = 30;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
    nameLabel.textAlignment = NSTextAlignmentRight;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:18.0];
    nameLabel.text = title;
    nameLabel.textColor = [UIColor whiteColor];
    [reportView addSubview:nameLabel];
    
    NSString *protectedPersonName = reportDict[@"protectedPersonName"];
    if ([protectedPersonName isMemberOfClass:[NSNull class]] || protectedPersonName == nil) {
        protectedPersonName = @"";
    }
    protectedPersonName = [NSString stringWithFormat:@"%@的健康档案",protectedPersonName];
    nameLabel.text = protectedPersonName;
    
    CGFloat timeLabelX = 10;
    CGFloat timeLabelY = footerViewY - 10 - 30;
    CGFloat timeLabelW = nameLabelW;
    CGFloat timeLabelH = 30;
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont systemFontOfSize:18.0];
    timeLabel.text = title;
    timeLabel.textColor = [UIColor whiteColor];
    [reportView addSubview:timeLabel];
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
    timeLabel.text = [NSString stringWithFormat:@"最后更新时间：%@",time];
    timeLabel.textAlignment = NSTextAlignmentRight;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(footerViewX, footerViewY, footerViewW, footerViewH)];
    footerView.backgroundColor = [UIColor whiteColor];
    [reportView addSubview:footerView];
    
    CGFloat footerLabelX = 0;
    CGFloat footerLabelY = 10;
    CGFloat footerLabelW = 0;
    CGFloat footerLabelH = 25;
    
    id countsObj = reportDict[@"counts"];
    if ([countsObj isMemberOfClass:[NSNull class]]) {
        countsObj = @"";
    }
    NSInteger counts = [countsObj integerValue];
    NSString *titleString = [NSString stringWithFormat:@"护理报告（%ld份）",counts];
    CGSize countsSize = [MLLabel getViewSizeByString:titleString font:[UIFont systemFontOfSize:17.0]];
    footerLabelW = countsSize.width;
    
    UIImage *icon = [UIImage imageNamed:@"icon_elect_onic_report"];
    CGFloat iconX = 0;
    CGFloat iconY = 10;
    CGFloat iconH = 25;
    CGFloat iconW = icon.size.width / icon.size.height * iconH;
    
    iconX = (SCREENWIDTH - (footerLabelW + iconW) - 5) / 2.0;
    footerLabelX = iconX + iconW + 5;
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(footerLabelX, footerLabelY, footerLabelW, footerLabelH)];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont systemFontOfSize:17.0];
    footerLabel.text = titleString;
    footerLabel.textColor = APPDEFAULTORANGE;
    [footerView addSubview:footerLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconW, iconH)];
    imageView.image = icon;
    [footerView addSubview:imageView];
    
    UIImage *arrowIcon = [UIImage imageNamed:@"icon_elect_onic_report_slide"];
    
    CGFloat arrowImageX = 50;
    CGFloat arrowImageW = footerViewW - 2 * arrowImageX;
    CGFloat arrowImageH = arrowIcon.size.height / arrowIcon.size.width * arrowImageW;
    CGFloat arrowImageY = footerViewH - arrowImageH - 5;
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowImageX, arrowImageY, arrowImageW, arrowImageH)];
    arrowImageView.image = arrowIcon;
    [footerView addSubview:arrowImageView];
    
    CGFloat tipLabelX = 0;
    CGFloat tipLabelH = 30;
    CGFloat tipLabelY = CGRectGetMinY(arrowImageView.frame) - tipLabelH;
    CGFloat tipLabelW = footerViewW;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipLabelX, tipLabelY, tipLabelW, tipLabelH)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:17.0];
    tipLabel.text = @"左右滑动浏览";
    tipLabel.textColor = APPDEFAULTORANGE;
    [footerView addSubview:tipLabel];
    
    
    return reportView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemsInRingedPages:(RPRingedPages *)pages
{
    return [dataSource count];
}

- (UIView *)ringedPages:(RPRingedPages *)pages viewForItemAtIndex:(NSInteger)index
{
    NSDictionary *dict = dataSource[index];
    NSString *title = [NSString stringWithFormat:@"%ld/%ld",index + 1,[dataSource count]];
    return [self getReportViewWithReportInfo:dict title:title];
}
- (void)didSelectedCurrentPageInPages:(RPRingedPages *)pages
{
    NSLog(@"pages selected, the current index is %zd", pages.currentIndex);
    NSDictionary *orderDict = dataSource[pages.currentIndex];
    HeOrderReportDetailVC *orderReportDetailVC = [[HeOrderReportDetailVC alloc] init];
    orderReportDetailVC.orderDict = [[NSDictionary alloc] initWithDictionary:orderDict];
    orderReportDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderReportDetailVC animated:YES];
}

- (void)pages:(RPRingedPages *)pages didScrollToIndex:(NSInteger)index
{
    NSLog(@"pages scrolled to index: %zd", index);
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
