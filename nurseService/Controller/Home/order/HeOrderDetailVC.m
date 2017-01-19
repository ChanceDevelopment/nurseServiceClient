//
//  HeOrderDetailVC.m
//  nurseService
//
//  Created by Tony on 2017/1/3.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeOrderDetailVC.h"
#import "HeBaseTableViewCell.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "HeUserLocatiVC.h"
#import "HePaitentInfoVC.h"
#import "HeNurseDetailVC.h"
#import "HeReportVC.h"

@interface HeOrderDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat imageScrollViewHeigh;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *statusView;
@property(strong,nonatomic)NSArray *statusArray;
@property(strong,nonatomic)UIScrollView *photoScrollView;
@property(strong,nonatomic)NSMutableArray *paperArray;
@property(strong,nonatomic)UIView *serviceBG;
@property(strong,nonatomic)UIScrollView *nurseBG;
@property(strong,nonatomic)NSMutableArray *nurseArray;
@property(strong,nonatomic)NSDictionary *orderDetailDict;
@property(strong,nonatomic)NSString *tmpDateString;

@end

@implementation HeOrderDetailVC
@synthesize tableview;
@synthesize statusArray;
@synthesize statusView;
@synthesize photoScrollView;
@synthesize paperArray;
@synthesize serviceBG;
@synthesize nurseBG;
@synthesize nurseArray;

@synthesize orderDetailDict;

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
        label.text = @"订单详情";
        [label sizeToFit];
        self.title = @"订单详情";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self loadOrderDetail];
}

- (void)initializaiton
{
    [super initializaiton];
    statusArray = @[@"已接单",@"已出发",@"已服务",@"已完成"];
    imageScrollViewHeigh = 80;
    paperArray = [[NSMutableArray alloc] initWithCapacity:0];
    nurseArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    rightItem.tintColor = [UIColor whiteColor];
    rightItem.title = @"投诉";
    rightItem.target = self;
    rightItem.action = @selector(reportAction:);
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 55)];
    tableview.tableHeaderView = statusView;
    
    id orderSendTypeObj = orderDetailDict[@"orderSendType"];
    if ([orderSendTypeObj isMemberOfClass:[NSNull class]]) {
        orderSendTypeObj = @"";
    }
    id orderSendStateObj = orderDetailDict[@"orderSendState"];
    if ([orderSendStateObj isMemberOfClass:[NSNull class]]) {
        orderSendStateObj = @"";
    }
    NSInteger orderSendType = [orderSendTypeObj integerValue];
    NSInteger orderSendState = [orderSendStateObj integerValue];
    if (orderSendType == 1 && orderSendState == 0) {
        [self addStatueViewWithStatus:0];
    }
    else{
        [self addStatueViewWithStatus:orderSendState];
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 70)];
    footerView.backgroundColor = tableview.backgroundColor;
    
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, 20)];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    tipLabel.text = @"备注";
    [footerView addSubview:tipLabel];
    
    NSString *content = @"如果护士来的比较晚，可以点击联系忽视，催促；亦可取消服务";
    CGSize size = [MLLabel getViewSizeByString:content maxWidth:SCREENWIDTH - 20 font:[UIFont systemFontOfSize:12.0] lineHeight:1.2f lines:0];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(tipLabel.frame), SCREENWIDTH - 20, size.height)];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.font = [UIFont systemFontOfSize:12.0];
    contentLabel.text = content;
    [footerView addSubview:contentLabel];
    
    CGRect footerFrame = footerView.frame;
    footerFrame.size.height = CGRectGetMaxY(contentLabel.frame) + 10;
    footerView.frame = footerFrame;
    tableview.tableFooterView = footerView;
    
    CGFloat scrollX = 5;
    CGFloat scrollY = 5;
    CGFloat scrollW = SCREENWIDTH - 2 * scrollX;
    CGFloat scrollH = imageScrollViewHeigh;
    photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollX, scrollY, scrollW, scrollH)];
    [self addPhotoScrollView];
    serviceBG = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 20, 0)];
    
    [self addServiceLabel];
    
    CGFloat receivescrollX = 5;
    CGFloat receivescrollY = 5;
    CGFloat receivescrollW = SCREENWIDTH - 2 * receivescrollX;
    CGFloat receivescrollH = 80;
    nurseBG = [[UIScrollView alloc] initWithFrame:CGRectMake(receivescrollX, receivescrollY, receivescrollW, receivescrollH)];
    [self addNurseHead];
}

- (void)reportAction:(id)sender
{
    HeReportVC *reportVC = [[HeReportVC alloc] init];
    reportVC.orderSendId = [NSString stringWithFormat:@"%@",_orderId];
    reportVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reportVC animated:YES];
}

- (void)addNurseHead
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = 60;
    CGFloat imageH = imageW;
    CGFloat imageDistance = 5;
    NSInteger imageTag = 0;
    for (NSString *url in nurseArray) {
        if ([url isEqualToString:@""]) {
            continue;
        }
        NSString *imageurl = url;
//        if (![url hasPrefix:@"http"]) {
//            imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
//        }
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        imageview.tag = imageTag;
        imageTag++;
        imageview.layer.cornerRadius = imageW / 2.0;
        imageview.layer.masksToBounds = YES;
        imageview.layer.borderWidth = 0;
        imageview.layer.borderColor = [UIColor clearColor].CGColor;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        
        [imageview sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
        [nurseBG addSubview:imageview];
        
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageX, CGRectGetMaxY(imageview.frame), imageW, 20)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:13.0];
        nameLabel.text = @"小明";
        
        imageX = imageX + imageW + imageDistance;
        
        [nurseBG addSubview:nameLabel];
    }
    if (imageX > nurseBG.frame.size.width) {
        nurseBG.contentSize = CGSizeMake(imageX, 0);
    }
}

- (void)addServiceLabel
{
    NSString *orderSendServicecontent = orderDetailDict[@"orderSendServicecontent"];
    if ([orderSendServicecontent isMemberOfClass:[NSNull class]]) {
        orderSendServicecontent = @"";
    }
    NSArray *orderSendServicecontentArray = [orderSendServicecontent componentsSeparatedByString:@":"];
    orderSendServicecontent = orderSendServicecontentArray[1];
    
    NSArray *serviceArray = [orderSendServicecontent componentsSeparatedByString:@","];
    CGFloat endLabelY = 10;
    CGFloat endLabelW = 10;
    CGFloat endLabelH = 30;
    CGFloat endLabelX = 0;
    
    CGFloat endLabelHDistance = 10;
    CGFloat endLabelVDistance = 5;
    
    UIFont *textFont = [UIFont systemFontOfSize:14.0];
    
    for (NSInteger index = 0; index < [serviceArray count]; index ++ ) {
        
        NSString *title = serviceArray[index];
        CGSize size = [MLLabel getViewSizeByString:title maxWidth:SCREENWIDTH - 20 font:textFont lineHeight:1.2f lines:0];
        endLabelW = size.width;
        if ((size.width + endLabelX) > CGRectGetWidth(serviceBG.frame)) {
            endLabelX = 0;
            endLabelY = endLabelY + endLabelVDistance + endLabelH;
        }
        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
        endLabel.font = [UIFont systemFontOfSize:14.0];
        endLabel.text = title;
        endLabel.textColor = APPDEFAULTORANGE;
        endLabel.textAlignment = NSTextAlignmentCenter;
        endLabel.backgroundColor = [UIColor clearColor];
        endLabel.layer.cornerRadius = 3.0;
        endLabel.layer.masksToBounds = YES;
        endLabel.layer.borderWidth = 0.5;
        endLabel.layer.borderColor = APPDEFAULTORANGE.CGColor;
        endLabel.textColor = APPDEFAULTORANGE;
        [serviceBG addSubview:endLabel];
        
        endLabelX = endLabelX + endLabelHDistance + endLabelW;
        
        CGRect serviceFrame = serviceBG.frame;
        serviceFrame.size.height = CGRectGetMaxY(endLabel.frame);
        serviceBG.frame = serviceFrame;
        
    }
}

- (void)addStatueViewWithStatus:(eOrderStatusType)statusType
{
    CGFloat statusLabelX = 5;
    CGFloat statusLabelY = 10;
    CGFloat statusLabelH = 20;
    CGFloat statusLabelW = (SCREENWIDTH - 2 * statusLabelX) / [statusArray count];
    
    CGFloat circleIconX = 0;
    CGFloat circleIconY = 0;
    CGFloat circleIconW = 10;
    CGFloat circleIconH = 10;
    
    CGFloat sepLineX = 0;
    CGFloat sepLineY = 0;
    CGFloat sepLineW = 0;
    CGFloat sepLineH = 1;
    
    statusView.backgroundColor = [UIColor whiteColor];
    
    for (NSInteger index = 0; index < [statusArray count]; index++) {
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusLabelX, statusLabelY, statusLabelW, statusLabelH)];
        statusLabel.tag = 1;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textColor = APPDEFAULTORANGE;
        statusLabel.font = [UIFont systemFontOfSize:13.0];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.text = statusArray[index];
        [statusView addSubview:statusLabel];
        
        circleIconX = CGRectGetMidX(statusLabel.frame) - circleIconW / 2.0;
        circleIconY = CGRectGetMaxY(statusLabel.frame) + 5;
        UIImageView *circleIcon = [[UIImageView alloc] initWithFrame:CGRectMake(circleIconX, circleIconY, circleIconW, circleIconH)];
        circleIcon.layer.masksToBounds = YES;
        circleIcon.layer.cornerRadius = circleIconH / 2.0;
        if (index < statusType) {
            circleIcon.backgroundColor = APPDEFAULTORANGE;
        }
        else{
            circleIcon.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        }
        [statusView addSubview:circleIcon];
        
        sepLineY = CGRectGetMidY(circleIcon.frame);
        sepLineW = CGRectGetMinX(circleIcon.frame) - sepLineX - 2;
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
        sepLine.backgroundColor = circleIcon.backgroundColor;
        [statusView addSubview:sepLine];
        
        statusLabelX = CGRectGetMaxX(statusLabel.frame);
        sepLineX = CGRectGetMaxX(circleIcon.frame) + 2;
    }
    
    sepLineW = SCREENWIDTH - sepLineX;
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    sepLine.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [statusView addSubview:sepLine];
    
}

- (void)addPhotoScrollView
{
    CGFloat imageX = 0;
    CGFloat imageY = 5;
    CGFloat imageH = photoScrollView.frame.size.height - 2 * imageY;
    CGFloat imageW = imageH;
    NSInteger row = 4; //一行四张图片
    CGFloat imageHDistance = (SCREENWIDTH - row * imageW) / (row + 1);
    CGFloat imageVDistance = 5;
    NSInteger index = 0;
    for (NSString *url in paperArray) {
        NSString *imageurl = url;
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        [imageview sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"index2"]];
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 5.0;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        [photoScrollView addSubview:imageview];
        imageX = imageX + imageW + imageHDistance;
        imageview.tag = index + 10000;
        index++;
        
        if (index != 0 && (index % row) == 0) {
            imageX = 0;
            imageY = imageY + imageH + imageVDistance;
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanlargeImage:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        imageview.userInteractionEnabled = YES;
        [imageview addGestureRecognizer:tap];
        
        CGRect photoFrame = photoScrollView.frame;
        photoFrame.size.height = CGRectGetMaxY(imageview.frame) + 10;
        photoScrollView.frame = photoFrame;
        
        
    }
}

- (void)scanlargeImage:(UITapGestureRecognizer *)tap
{
    NSInteger index = 0;
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *url in paperArray) {
        NSString *imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageurl];
        
        UIImageView *srcImageView = [photoScrollView viewWithTag:index + 10000];
        photo.image = srcImageView.image;
        photo.srcImageView = srcImageView;
        [photos addObject:photo];
        index++;
    }
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag - 10000;
    browser.photos = photos;
    [browser show];
}

- (void)enlargeImage:(UITapGestureRecognizer *)tap
{
    NSString *zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,paperArray[0]];
    
    UIImageView *srcImageView = (UIImageView *)tap.view;
    NSMutableArray *photos = [NSMutableArray array];
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [NSURL URLWithString:zoneCover];
    photo.image = srcImageView.image;
    photo.srcImageView = srcImageView;
    [photos addObject:photo];
    browser.photos = photos;
    [browser show];
}

- (void)buttonClick:(UIButton *)button
{
    if (button.tag == 0) {
        NSLog(@"联系护士");
        NSString *nursePhone = orderDetailDict[@"nursePhone"];
        if ([nursePhone isMemberOfClass:[NSNull class]] || nursePhone == nil) {
            
            return;
        }
        NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",nursePhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    }
    else{
        NSLog(@"联系客服");
        [self showHint:@"暂无客服"];
        return;
    }
}

- (void)loadOrderDetail
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *orderSendId = [NSString stringWithFormat:@"%@",_orderId];
    NSString *latitude = [[HeSysbsModel getSysModel].userLocationDict objectForKey:@"latitude"];
    NSString *longitude = [[HeSysbsModel getSysModel].userLocationDict objectForKey:@"longitude"];
    if (!latitude) {
        longitude = @"";
    }
    if (!longitude) {
        longitude = @"";
    }
    NSDictionary * params  = @{@"userId":userId,@"orderSendId":orderSendId,@"latitude":latitude,@"longitude":longitude};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/OrderSendDescriptionById.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            orderDetailDict = [[NSDictionary alloc] initWithDictionary:respondDict[@"json"]];
            
            id zoneCreatetimeObj = [orderDetailDict objectForKey:@"orderSendBegintime"];
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
            
            NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"yyyy/MM/dd HH:mm"];
            self.tmpDateString = time;
            
            
            
            paperArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSString *orderSendUserpic = orderDetailDict[@"orderSendUserpic"];
            if ([orderSendUserpic isMemberOfClass:[NSNull class]] || orderSendUserpic == nil) {
                orderSendUserpic = nil;
            }
            NSArray *orderSendUserpicArray = [orderSendUserpic componentsSeparatedByString:@","];
            for (NSString *url in orderSendUserpicArray) {
                NSString *myurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
                [paperArray addObject:myurl];
            }
            
            id orderSendTypeObj = orderDetailDict[@"orderSendType"];
            if ([orderSendTypeObj isMemberOfClass:[NSNull class]]) {
                orderSendTypeObj = @"";
            }
            id orderSendStateObj = orderDetailDict[@"orderSendState"];
            if ([orderSendStateObj isMemberOfClass:[NSNull class]]) {
                orderSendStateObj = @"";
            }
            NSInteger orderSendType = [orderSendTypeObj integerValue];
            NSInteger orderSendState = [orderSendStateObj integerValue];
            if (orderSendType == 1 && orderSendState == 0){
            
            }
            else{
                NSString *nurseHeader = orderDetailDict[@"nurseHeader"];
                if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
                    nurseHeader = @"";
                }
                nurseHeader = [NSString stringWithFormat:@"%@/%@",BASEURL,nurseHeader];
                [nurseArray addObject:nurseHeader];
            }
            
            
            
            [self initView];
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
        NSLog(@"errorInfo = %@",err);
    }];
}


#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 5;
            break;
        }
        case 1:
        {
            return 4;
            break;
        }
            
        default:
            break;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"OrderFinishedTableViewCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    //    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[dataArr objectAtIndex:row]];
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0:
                {
                    NSString *orderSendServicecontent = orderDetailDict[@"orderSendServicecontent"];
                    if ([orderSendServicecontent isMemberOfClass:[NSNull class]]) {
                        orderSendServicecontent = @"";
                    }
                    NSArray *orderSendServicecontentArray = [orderSendServicecontent componentsSeparatedByString:@":"];
                    orderSendServicecontent = orderSendServicecontentArray[0];
                    
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, cellSize.height)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = orderSendServicecontent;
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:titleLabel];
                    
//                    NSString *priceString = @"￥199";
//                    UIFont *priceFont = [UIFont systemFontOfSize:14.0];
//                    CGSize priceSize = [MLLabel getViewSizeByString:priceString maxWidth:200 font:priceFont lineHeight:1.2f lines:0];
//                    CGFloat priceLabelW = priceSize.width;
//                    CGFloat priceLabelY = 0;
//                    CGFloat priceLabelH = cellSize.height;
//                    CGFloat priceLabelX = cellSize.width - priceLabelW - 40;
//                    
//                    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
//                    priceLabel.text = priceString;
//                    priceLabel.backgroundColor = [UIColor clearColor];
//                    priceLabel.textColor = [UIColor redColor];
//                    priceLabel.font = priceFont;
//                    [cell addSubview:priceLabel];
                    
                    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 80 - 30, 0, 80, cellSize.height)];
                    subTitleLabel.backgroundColor = [UIColor clearColor];
                    id orderSendTypeObj = orderDetailDict[@"orderSendType"];
                    if ([orderSendTypeObj isMemberOfClass:[NSNull class]]) {
                        orderSendTypeObj = @"";
                    }
                    
                    id orderSendStateObj = orderDetailDict[@"orderSendState"];
                    if ([orderSendStateObj isMemberOfClass:[NSNull class]]) {
                        orderSendStateObj = @"";
                    }
                    
                    NSInteger orderSendType = [orderSendTypeObj integerValue];
                    NSInteger orderSendState = [orderSendStateObj integerValue];
                    if (orderSendType == 1 && orderSendState == 0){
                        subTitleLabel.text = @"未接单";
                    }
                    else if (orderSendType == 1 && orderSendState == 1){
                        subTitleLabel.text = @"已接单";
                    }
                    else if (orderSendState == 2){
                        subTitleLabel.text = @"已接单";
                    }
                    else if (orderSendState == 3){
                        subTitleLabel.text = @"已服务";
                    }
                    subTitleLabel.textAlignment = NSTextAlignmentRight;
                    subTitleLabel.font = [UIFont systemFontOfSize:14.0];
                    subTitleLabel.textColor = [UIColor grayColor];
                    [cell addSubview:subTitleLabel];
                    
                    break;
                }
                case 1:{
                    //套餐
                    [cell addSubview:serviceBG];
                    break;
                }
                case 2:
                {
                    CGFloat timeLabelX = 10;
                    CGFloat timeLabelW = SCREENWIDTH - 2 * timeLabelX;
                    CGFloat timeLabelH = cellSize.height / 2.0;
                    CGFloat timeLabelY = 0;
                    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
                    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
                    timeLabel.text = self.tmpDateString;
                    [cell addSubview:timeLabel];
                    
                    CGFloat locationIconH = 20;
                    CGFloat locationIconW = 20;
                    CGFloat locationIconX = SCREENWIDTH - locationIconW - 20;
                    CGFloat locationIconY = cellSize.height / 2.0 + (cellSize.height / 2.0 - locationIconH) / 2.0;
                    
                    UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_address"]];
                    locationIcon.frame = CGRectMake(locationIconX, locationIconY, locationIconW, locationIconH);
                    [cell addSubview:locationIcon];
                    
                    
                    CGFloat addressLabelX = 10;
                    CGFloat addressLabelW = CGRectGetMinX(locationIcon.frame) - addressLabelX - 10;
                    CGFloat addressLabelH = cellSize.height / 2.0;
                    CGFloat addressLabelY = CGRectGetMaxY(timeLabel.frame);
                    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressLabelX, addressLabelY, addressLabelW, addressLabelH)];
                    addressLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
                    
                    NSString *orderSendAddree = orderDetailDict[@"orderSendAddree"];
                    NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                    orderSendAddree = orderSendAddreeArray[2];
                    
                    addressLabel.text = orderSendAddree;
                    [cell addSubview:addressLabel];
                    
                    break;
                }
                case 3:
                {
                    //患者信息
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, cellSize.height)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = @"患者信息";
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:titleLabel];
                    
                    CGFloat subTitleLabelX = CGRectGetMaxX(titleLabel.frame) + 5;
                    CGFloat subTitleLabelY = 0;
                    CGFloat subTitleLabelH = cellSize.height;
                    CGFloat subTitleLabelW = SCREENWIDTH - subTitleLabelX - 40;
                    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(subTitleLabelX, subTitleLabelY, subTitleLabelW, subTitleLabelH)];
                    subTitleLabel.backgroundColor = [UIColor clearColor];
                    
                    NSString *orderSendUsername = orderDetailDict[@"orderSendUsername"];
                    NSArray *orderSendUsernameArray = [orderSendUsername componentsSeparatedByString:@","];
                    orderSendUsername = orderSendUsernameArray[1];
                    
                    NSString *orderSendAddree = orderDetailDict[@"orderSendAddree"];
                    NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                    orderSendAddree = orderSendAddreeArray[2];
                    
                    id orderSendSex = orderDetailDict[@"orderSendSex"];
                    if ([orderSendSex isMemberOfClass:[NSNull class]]) {
                        orderSendSex = @"";
                    }
                    NSString *orderSendSexStr = @"女";
                    if ([orderSendSex integerValue] == ENUM_SEX_Boy) {
                        orderSendSexStr = @"男";
                    }
                    id orderSendAge = orderDetailDict[@"orderSendAge"];
                    subTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@岁",orderSendUsername,orderSendSexStr,orderSendAge];
                    subTitleLabel.textAlignment = NSTextAlignmentRight;
                    subTitleLabel.font = [UIFont systemFontOfSize:15.0];
                    subTitleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:subTitleLabel];
                    
                    break;
                }
                case 4:{
                    //备注信息
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, cellSize.height)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = @"备注信息";
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:titleLabel];
                    
                    CGFloat subTitleLabelX = CGRectGetMaxX(titleLabel.frame) + 5;
                    CGFloat subTitleLabelY = 0;
                    CGFloat subTitleLabelH = cellSize.height;
                    CGFloat subTitleLabelW = SCREENWIDTH - subTitleLabelX - 10;
                    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(subTitleLabelX, subTitleLabelY, subTitleLabelW, subTitleLabelH)];
                    subTitleLabel.backgroundColor = [UIColor clearColor];
                    
                    NSString *orderSendNote = orderDetailDict[@"orderSendNote"];
                    if ([orderSendNote isMemberOfClass:[NSNull class]]) {
                        orderSendNote = @"";
                    }
                    subTitleLabel.text = orderSendNote;
                    subTitleLabel.textAlignment = NSTextAlignmentRight;
                    subTitleLabel.font = [UIFont systemFontOfSize:15.0];
                    subTitleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:subTitleLabel];
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (row) {
                case 0:
                {
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 44)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = @"图片资料";
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:titleLabel];
                    
                    CGRect photoFrame = photoScrollView.frame;
                    photoFrame.origin.y = CGRectGetMaxY(titleLabel.frame);
                    photoScrollView.frame = photoFrame;
                    [cell addSubview:photoScrollView];
                    if ([paperArray count] == 0) {
                        CGFloat endLabelY = 0;
                        CGFloat endLabelW = 150;
                        CGFloat endLabelH = cellSize.height;
                        CGFloat endLabelX = SCREENWIDTH - endLabelW - 30;
                        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
                        endLabel.font = [UIFont systemFontOfSize:15.0];
                        id orderSendCostmoney = orderDetailDict[@"orderSendCostmoney"];
                        if ([orderSendCostmoney isMemberOfClass:[NSNull class]]) {
                            orderSendCostmoney = @"";
                        }
                        endLabel.text = @"暂无图片资料";
                        
                        endLabel.textAlignment = NSTextAlignmentRight;
                        endLabel.textColor = [UIColor orangeColor];
                        [cell addSubview:endLabel];
                    }
                    break;
                }
                case 1:{
                    CGFloat orderNoLabelX = 10;
                    CGFloat orderNoLabelW = SCREENWIDTH - 2 * orderNoLabelX;
                    CGFloat orderNoLabelH = cellSize.height;
                    CGFloat orderNoLabelY = 0;
                    UILabel *orderNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderNoLabelX, orderNoLabelY, orderNoLabelW, orderNoLabelH)];
                    orderNoLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
                    id orderSendNumbers = orderDetailDict[@"orderSendNumbers"];
                    orderNoLabel.text = [NSString stringWithFormat:@"订单编号: %@",orderSendNumbers];
                    [cell addSubview:orderNoLabel];
                    
                    
                    
                    CGFloat timeLabelX = 10;
                    CGFloat timeLabelW = SCREENWIDTH - 2 * timeLabelX;
                    CGFloat timeLabelH = cellSize.height / 2.0;
                    CGFloat timeLabelY = CGRectGetMaxY(orderNoLabel.frame);
                    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
                    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    timeLabel.text = [NSString stringWithFormat:@"接单时间： %@",self.tmpDateString];
//                    [cell addSubview:timeLabel];
                    
                    break;
                }
                case 2:{
//                    [cell addSubview:nurseBG];
                    id orderSendTypeObj = orderDetailDict[@"orderSendType"];
                    if ([orderSendTypeObj isMemberOfClass:[NSNull class]]) {
                        orderSendTypeObj = @"";
                    }
                    id orderSendStateObj = orderDetailDict[@"orderSendState"];
                    if ([orderSendStateObj isMemberOfClass:[NSNull class]]) {
                        orderSendStateObj = @"";
                    }
                    NSInteger orderSendType = [orderSendTypeObj integerValue];
                    NSInteger orderSendState = [orderSendStateObj integerValue];
                    
                    if (orderSendState == 0) {
                        //还没接单
                        CGFloat endLabelY = 0;
                        CGFloat endLabelW = 150;
                        CGFloat endLabelH = cellSize.height;
                        CGFloat endLabelX = 10;
                        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
                        endLabel.font = [UIFont systemFontOfSize:17.0];
                        id orderSendCostmoney = orderDetailDict[@"orderSendCostmoney"];
                        if ([orderSendCostmoney isMemberOfClass:[NSNull class]]) {
                            orderSendCostmoney = @"";
                        }
                        endLabel.text = @"暂无护士资料";
                        
                        endLabel.textAlignment = NSTextAlignmentLeft;
                        endLabel.textColor = [UIColor orangeColor];
                        [cell addSubview:endLabel];
                    }
                    else{
                        NSString *nurseHeader = orderDetailDict[@"nurseHeader"];
                        if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
                            nurseHeader = nil;
                        }
                        if (nurseHeader != nil) {
                            nurseHeader = [NSString stringWithFormat:@"%@/%@",BASEURL,nurseHeader];
                            [nurseArray addObject:nurseHeader];
                        }
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 
                        CGFloat imageViewX = 10;
                        CGFloat imageViewY = 10;
                        CGFloat imageViewH = cellSize.height - 2 * imageViewY;
                        CGFloat imageViewW = imageViewH;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH)];
                        imageView.layer.masksToBounds = YES;
                        imageView.layer.cornerRadius = imageViewW / 2.0;
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [cell addSubview:imageView];
                        [imageView sd_setImageWithURL:[NSURL URLWithString:nurseHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
                        
                        CGFloat nurseInfoY = 10;
                        CGFloat nurseInfoW = 150;
                        CGFloat nurseInfoH = imageViewH / 3.0;
                        CGFloat nurseInfoX = CGRectGetMaxX(imageView.frame) + 5;
                        UILabel *nurseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(nurseInfoX, nurseInfoY, nurseInfoW, nurseInfoH)];
                        nurseInfoLabel.font = [UIFont systemFontOfSize:13.0];
                        id orderSendCostmoney = orderDetailDict[@"orderSendCostmoney"];
                        if ([orderSendCostmoney isMemberOfClass:[NSNull class]]) {
                            orderSendCostmoney = @"";
                        }
                        NSString *nurseNick = orderDetailDict[@"nurseNick"];
                        if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
                            nurseNick = @"";
                        }
                        NSString *nurseJob = orderDetailDict[@"nurseJob"];
                        if ([nurseJob isMemberOfClass:[NSNull class]] || nurseJob == nil) {
                            nurseJob = @"护士";
                        }
                        nurseInfoLabel.text = [NSString stringWithFormat:@"%@  %@",nurseNick,nurseJob];
                        
                        nurseInfoLabel.textAlignment = NSTextAlignmentLeft;
                        nurseInfoLabel.textColor = [UIColor blackColor];
                        [cell addSubview:nurseInfoLabel];
                        
                        NSString *nurseWorkNnit = orderDetailDict[@"nurseWorkNnit"];
                        if ([nurseWorkNnit isMemberOfClass:[NSNull class]] || nurseWorkNnit == nil) {
                            nurseWorkNnit = @"该护士未选定指定医院";
                        }
                        CGFloat hospitalLabelY = CGRectGetMaxY(nurseInfoLabel.frame);
                        CGFloat hospitalLabelW = 150;
                        CGFloat hospitalLabelH = imageViewH / 3.0;
                        CGFloat hospitalLabelX = CGRectGetMaxX(imageView.frame) + 5;
                        UILabel *hospitalLabel = [[UILabel alloc] initWithFrame:CGRectMake(hospitalLabelX, hospitalLabelY, hospitalLabelW, hospitalLabelH)];
                        hospitalLabel.font = [UIFont systemFontOfSize:13.0];
                        hospitalLabel.text = nurseWorkNnit;
                        
                        hospitalLabel.textAlignment = NSTextAlignmentLeft;
                        hospitalLabel.textColor = [UIColor blackColor];
                        [cell addSubview:hospitalLabel];
                        
                        
                        CGFloat markInfoLabelY = CGRectGetMaxY(hospitalLabel.frame);
                        CGFloat markInfoLabelW = 150;
                        CGFloat markInfoLabelH = imageViewH / 3.0;
                        CGFloat markInfoLabelX = CGRectGetMaxX(imageView.frame) + 5;
                        UILabel *markInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(markInfoLabelX, markInfoLabelY, markInfoLabelW, markInfoLabelH)];
                        markInfoLabel.font = [UIFont systemFontOfSize:13.0];
                        markInfoLabel.text = @"熟悉医务护理知识";
                        
                        markInfoLabel.textAlignment = NSTextAlignmentLeft;
                        markInfoLabel.textColor = [UIColor blackColor];
                        [cell addSubview:markInfoLabel];
                        
                        CGFloat endLabelY = nurseInfoY;
                        CGFloat endLabelW = 80;
                        CGFloat endLabelH = nurseInfoH;
                        CGFloat endLabelX = SCREENWIDTH - 30 - endLabelW;
                        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
                        endLabel.font = [UIFont systemFontOfSize:13.0];
                        
                        id nurseSex = orderDetailDict[@"nurseSex"];
                        if ([nurseSex isMemberOfClass:[NSNull class]] || nurseSex == nil) {
                            nurseSex = @"";
                        }
                        NSString *nurseSexStr = @"女";
                        if ([nurseSexStr integerValue] == ENUM_SEX_Boy) {
                            nurseSexStr = @"男";
                        }
                        
                        id nurseAge = orderDetailDict[@"nurseAge"];
                        if ([nurseAge isMemberOfClass:[NSNull class]] || nurseAge == nil) {
                            nurseAge = @"24";
                        }
                        
                        endLabel.text = [NSString stringWithFormat:@"%@  %@岁",nurseSexStr,nurseAge];
                        
                        endLabel.textAlignment = NSTextAlignmentRight;
                        endLabel.textColor = [UIColor blackColor];
                        
                        //距离
                        endLabelY = cellSize.height - 10 - nurseInfoH;
                        endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
                        endLabel.font = [UIFont systemFontOfSize:13.0];
                        endLabel.textColor = [UIColor grayColor];
                        
                        id distance = orderDetailDict[@"distance"];
                        if ([distance isMemberOfClass:[NSNull class]] || distance == nil) {
                            distance = @"";
                        }
                        NSString *distanceStr = [NSString stringWithFormat:@"%.2fm",[distance floatValue]];
                        if ([distance floatValue]>= 1000) {
                            distanceStr = [NSString stringWithFormat:@"%.2fkm",[distance floatValue] / 1000.0];
                        }
                        
                        
                        
                        
                        
                    }
                    break;
                }
                case 3:{
                    CGFloat buttonX = 0;
                    CGFloat buttonY = 0;
                    CGFloat buttonW = SCREENWIDTH / 2.0;
                    CGFloat buttonH = cellSize.height;
                    
                    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
                    [cancelButton setTitle:@"联系护士" forState:UIControlStateNormal];
                    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
                    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    cancelButton.tag = 0;
                    [cell addSubview:cancelButton];
                    
                    buttonX = CGRectGetMaxX(cancelButton.frame);
                    buttonW = SCREENWIDTH - buttonX;
                    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
                    [nextButton setTitle:@"联系客服" forState:UIControlStateNormal];
                    [nextButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
                    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [nextButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    nextButton.tag = 1;
                    [cell addSubview:nextButton];
                    
                    CGFloat sepLineX = buttonX;
                    CGFloat sepLineY = 3;
                    CGFloat sepLineH = cellSize.height - 2 * sepLineY;
                    CGFloat sepLineW = 1;
                    
                    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
                    sepLine.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
                    [cell addSubview:sepLine];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
        {
            if (row == 1) {
                return serviceBG.frame.size.height + 20;
            }
            else if (row == 2) {
                return 60;
            }
            return 50;
            break;
        }
        case 1:{
            switch (row) {
                case 0:
                    //图片资料
                    if ([paperArray count] == 0) {
                        return 44;
                    }
                    return 44 + photoScrollView.frame.size.height;
                    break;
                case 1:
                    //订单编号
                    return 50;
                    break;
                case 2:{
                    if ([nurseArray count] == 0) {
                        return 44;
                    }
                    return nurseBG.frame.size.height + 10;
                    break;
                }
                case 3:
                    
                    return 44;
                default:
                    break;
            }
        }
        
        default:
            break;
    }
    
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
    headerView.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 10.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
        {
            switch (row) {
                case 2:
                {
                    //位置
                    HeUserLocatiVC *userLocationVC = [[HeUserLocatiVC alloc] init];
                    userLocationVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:userLocationVC animated:YES];
                    break;
                }
                case 3:
                {
                    //患者信息
                    NSString *orderSendUsername = orderDetailDict[@"orderSendUsername"];
                    if ([orderSendUsername isMemberOfClass:[NSNull class]] || orderSendUsername == nil) {
                        orderSendUsername = @"";
                    }
                    NSArray *orderSendUsernameArray = [orderSendUsername componentsSeparatedByString:@","];
                    orderSendUsername = orderSendUsernameArray[0];
                    NSDictionary *dict = @{@"personId":orderSendUsername};
                    HePaitentInfoVC *paitentInfoVC = [[HePaitentInfoVC alloc] init];
                    paitentInfoVC.userInfoDict = [[NSDictionary alloc] initWithDictionary:dict];
                    paitentInfoVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:paitentInfoVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:{
            switch (row) {
                case 2:
                {
                    HeNurseDetailVC *nurseDetailVC = [[HeNurseDetailVC alloc] init];
                    nurseDetailVC.nurseDictInfo = [[NSDictionary alloc] initWithDictionary:orderDetailDict];
                    nurseDetailVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:nurseDetailVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    NSLog(@"row = %ld, section = %ld",row,section);
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
