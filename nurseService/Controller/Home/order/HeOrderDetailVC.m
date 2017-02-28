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
#import "HeCommentNurseVC.h"

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
    //订单状态（0正在发布/1已被接取/2已服务/3已完成/4被取消/为空为待预约
    id orderSendStateObj = orderDetailDict[@"orderSendState"];
    if ([orderSendStateObj isMemberOfClass:[NSNull class]] || orderSendStateObj == nil) {
        orderSendStateObj = @"";
    }
    NSInteger orderSendState = [orderSendStateObj integerValue];
//    if (orderSendState == 1) {
//        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
//        rightItem.tintColor = [UIColor whiteColor];
//        rightItem.title = @"投诉";
//        rightItem.target = self;
//        rightItem.action = @selector(reportAction:);
//        self.navigationItem.rightBarButtonItem = rightItem;
//    }
    
    
    
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
    
    NSInteger orderSendType = [orderSendTypeObj integerValue];
    orderSendState = [orderSendStateObj integerValue];
    if (orderSendType == 1 && orderSendState == 0) {
        [self addStatueViewWithStatus:0];
    }
    else{
        if (orderSendState >= 3) {
            if (self.isEvaluate) {
                orderSendState = orderSendState + 1;
            }
        }
        [self addStatueViewWithStatus:orderSendState];
    }
    
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 70)];
//    footerView.backgroundColor = tableview.backgroundColor;
//    
//    
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, 20)];
//    tipLabel.textAlignment = NSTextAlignmentLeft;
//    tipLabel.textColor = [UIColor grayColor];
//    tipLabel.backgroundColor = [UIColor clearColor];
//    tipLabel.font = [UIFont systemFontOfSize:12.0];
//    tipLabel.text = @"备注";
//    [footerView addSubview:tipLabel];
//    
//    NSString *content = @"如果护士来的比较晚，可以点击联系忽视，催促；亦可取消服务";
//    CGSize size = [MLLabel getViewSizeByString:content maxWidth:SCREENWIDTH - 20 font:[UIFont systemFontOfSize:12.0] lineHeight:1.2f lines:0];
//    
//    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(tipLabel.frame), SCREENWIDTH - 20, size.height)];
//    contentLabel.numberOfLines = 0;
//    contentLabel.textAlignment = NSTextAlignmentLeft;
//    contentLabel.textColor = [UIColor grayColor];
//    contentLabel.backgroundColor = [UIColor clearColor];
//    contentLabel.font = [UIFont systemFontOfSize:12.0];
//    contentLabel.text = content;
//    [footerView addSubview:contentLabel];
//    
//    CGRect footerFrame = footerView.frame;
//    footerFrame.size.height = CGRectGetMaxY(contentLabel.frame) + 10;
//    footerView.frame = footerFrame;
//    tableview.tableFooterView = footerView;
    
    CGFloat scrollX = 5;
    CGFloat scrollY = 5;
    CGFloat scrollW = SCREENWIDTH - 2 * scrollX;
    CGFloat scrollH = imageScrollViewHeigh;
    photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollX, scrollY, scrollW, scrollH)];
    [self addPhotoScrollView];
    serviceBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 20, 0)];
    
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
    @try {
        orderSendServicecontent = orderSendServicecontentArray[1];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    NSArray *serviceArray = [orderSendServicecontent componentsSeparatedByString:@","];
    CGFloat endLabelY = 10;
    CGFloat endLabelW = 10;
    CGFloat endLabelH = 30;
    CGFloat endLabelX = 10;
    
    CGFloat endLabelHDistance = 5;
    CGFloat endLabelVDistance = 5;
    
    CGFloat maxWidth = SCREENWIDTH - 2 * endLabelX - 2 * endLabelHDistance;
    
    UIFont *textFont = [UIFont systemFontOfSize:14.0];
    
    for (NSInteger index = 0; index < [serviceArray count]; index ++ ) {
        
        NSString *title = serviceArray[index];
        
        CGSize size = [MLLabel getViewSizeByString:title maxWidth:maxWidth font:textFont lineHeight:1.2f lines:0];
        if (size.width < 30) {
            size.width = 30;
        }
        else{
            if ((size.width + 10) <= maxWidth) {
                size.width = size.width + 10;
            }
        }
        endLabelW = size.width;
        
        if ((size.width + endLabelX) > maxWidth) {
            endLabelX = 0;
            endLabelY = endLabelY + endLabelVDistance + endLabelH;
        }
        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
        endLabel.font = [UIFont systemFontOfSize:14.0];
        endLabel.text = title;
        endLabel.textColor = APPDEFAULTORANGE;
        endLabel.textAlignment = NSTextAlignmentCenter;
        endLabel.backgroundColor = [UIColor clearColor];
        endLabel.layer.cornerRadius = 5.0;
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
    CGRect serviceFrame = serviceBG.frame;
    serviceFrame.size.height = serviceFrame.size.height + 10;
    serviceBG.frame = serviceFrame;
}

- (void)addStatueViewWithStatus:(NSInteger)statusType
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
    if (statusType == [statusArray count]) {
        sepLine.backgroundColor = APPDEFAULTORANGE;
    }
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
        NSLog(@"取消订单");
        [self cancelServiceWithDict:orderDetailDict];
//        NSString *nursePhone = orderDetailDict[@"nursePhone"];
//        if ([nursePhone isMemberOfClass:[NSNull class]] || nursePhone == nil) {
//            [self showHint:@"暂无护士的联系方式"];
//            return;
//        }
//        NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",nursePhone];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    }
    else if(button.tag == 1){
        NSLog(@"联系客服");
//        [self showHint:@"暂无客服"];
        [self callServicerPhone];
        return;
    }else if(button.tag == 10){
    }else if(button.tag == 11){
    }
}

- (void)callServicerPhone{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/selectUseCustomerServicePhone.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:nil success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSString *nursePhone = respondDict[@"customerServicePhone"];
            if ([nursePhone isMemberOfClass:[NSNull class]] || nursePhone == nil) {
                [self showHint:@"暂无客服的联系方式"];
                return;
            }
            NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",nursePhone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
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
            
            NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"MM/dd EEEE HH:MM"];
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
                
                NSString *nurseId = orderDetailDict[@"nurseId"];
                if ([nurseId isMemberOfClass:[NSNull class]] || nurseId == nil) {
                    nurseId = @"";
                }
                else{
                    nurseHeader = [NSString stringWithFormat:@"%@/%@",BASEURL,nurseHeader];
                    [nurseArray addObject:nurseHeader];
                }
                
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
            return 1;
            break;
        }
            
        case 2:
        {
            return 1;
            break;
        }
        case 3:
        {
            return 2;
            break;
        }
            
        default:
            break;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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
                    NSString *nurseHeader = orderDetailDict[@"nurseHeader"];
                    if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
                        nurseHeader = nil;
                    }
                    if (nurseHeader != nil) {
                        nurseHeader = [NSString stringWithFormat:@"%@/%@",BASEURL,nurseHeader];
                        [nurseArray addObject:nurseHeader];
                    }
                    
                    //30
                    CGFloat pointY = 0;
                    CGFloat pointX = 10;
                    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(pointX, pointY, 40, 40)];
                    headImageView.backgroundColor = [UIColor clearColor];
                    headImageView.layer.masksToBounds = YES;
                    headImageView.image = [UIImage imageNamed:@"defalut_icon"];
                    headImageView.contentMode = UIViewContentModeScaleAspectFill;
                    headImageView.layer.borderWidth = 0.0;
                    headImageView.layer.cornerRadius = 40 / 2.0;
                    headImageView.layer.masksToBounds = YES;
                    [cell addSubview:headImageView];
                    [headImageView sd_setImageWithURL:[NSURL URLWithString:nurseHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
                    
                    NSString *nurseNick = orderDetailDict[@"nurseNick"];
                    if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
                        nurseNick = @"";
                    }
                    NSString *nurseJob = orderDetailDict[@"nurseJob"];
                    if ([nurseJob isMemberOfClass:[NSNull class]] || nurseJob == nil) {
                        nurseJob = @"护士";
                    }
                    
                    pointX = CGRectGetMaxX(headImageView.frame)+5;
                    UILabel *nameL = [[UILabel alloc] initWithFrame:CGRectMake(pointX, pointY, 180, 20)];
                    nameL.textColor = [UIColor blackColor];
                    nameL.font = [UIFont systemFontOfSize:13.0];
                    nameL.backgroundColor = [UIColor clearColor];
                    [cell addSubview:nameL];
                    nameL.text = [NSString stringWithFormat:@"%@  %@",nurseNick,nurseJob];
                    
                    NSString *nurseWorkNnit = orderDetailDict[@"nurseWorkNnit"];
                    if ([nurseWorkNnit isMemberOfClass:[NSNull class]] || nurseWorkNnit == nil) {
                        nurseWorkNnit = @"该护士未选定指定医院";
                    }
                    
                    pointY = CGRectGetMaxY(nameL.frame);
                    UILabel *hospitalL = [[UILabel alloc] initWithFrame:CGRectMake(pointX, pointY, 180, 20)];
                    hospitalL.textColor = [UIColor blackColor];
                    hospitalL.font = [UIFont systemFontOfSize:13.0];
                    hospitalL.backgroundColor = [UIColor clearColor];
                    [cell addSubview:hospitalL];
                    hospitalL.text = nurseWorkNnit;
                    
                    pointY = 10;
                    pointX = SCREENWIDTH-35;
                    UIImageView *telephone = [[UIImageView alloc] initWithFrame:CGRectMake(pointX, pointY, 20, 20)];
                    telephone.backgroundColor = [UIColor clearColor];
                    telephone.image = [UIImage imageNamed:@"icon_phone"];
                    telephone.userInteractionEnabled = YES;
                    [cell addSubview:telephone];
                    
                    UITapGestureRecognizer *userInfoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callCustomer)];
                    [telephone addGestureRecognizer:userInfoTap];
                    break;
                }
                case 1:
                {
                    NSString *orderSendServicecontent = orderDetailDict[@"orderSendServicecontent"];
                    if ([orderSendServicecontent isMemberOfClass:[NSNull class]]) {
                        orderSendServicecontent = @"";
                    }
                    NSArray *orderSendServicecontentArray = [orderSendServicecontent componentsSeparatedByString:@":"];
                    orderSendServicecontent = orderSendServicecontentArray[0];
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, cellSize.height)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = orderSendServicecontent;
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:titleLabel];
                    
                    id orderSendTotalmoney = orderDetailDict[@"orderSendTotalmoney"];
                    if ([orderSendTotalmoney isMemberOfClass:[NSNull class]] || orderSendTotalmoney == nil) {
                        orderSendTotalmoney = @"";
                    }
                    
                    NSString *priceString = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
                    UIFont *priceFont = [UIFont systemFontOfSize:13.0];
                    CGSize priceSize = [MLLabel getViewSizeByString:priceString maxWidth:200 font:priceFont lineHeight:1.2f lines:0];
                    CGFloat priceLabelW = priceSize.width;
                    CGFloat priceLabelY = 0;
                    CGFloat priceLabelH = cellSize.height;
                    CGFloat priceLabelX = cellSize.width - priceLabelW - 10;
                    
                    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
                    priceLabel.text = priceString;
                    priceLabel.backgroundColor = [UIColor clearColor];
                    priceLabel.textColor = [UIColor redColor];
                    priceLabel.font = priceFont;
                    [cell addSubview:priceLabel];
                    
                    UILabel *priceTipL = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX-80, priceLabelY, 80, priceLabelH)];
                    priceTipL.text = @"预计收入";
                    priceTipL.textAlignment = NSTextAlignmentRight;
                    priceTipL.backgroundColor = [UIColor clearColor];
                    priceTipL.textColor = [UIColor blackColor];
                    priceTipL.font = priceFont;
                    [cell addSubview:priceTipL];
                    /*
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
                    */
                    break;
                }
                case 2:{
                    //套餐
                    [cell addSubview:serviceBG];
                    break;
                }
                case 3:
                {
                    CGFloat timeLabelX = 10;
                    CGFloat timeLabelW = SCREENWIDTH - 2 * timeLabelX-35;
                    CGFloat timeLabelH = cellSize.height / 2.0;
                    CGFloat timeLabelY = 0;
                    
                    UILabel *timeTipL = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, 30, timeLabelH)];
                    timeTipL.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    timeTipL.text = @"时间";
                    timeTipL.backgroundColor = [UIColor clearColor];
                    timeTipL.textColor = [UIColor grayColor];
                    [cell addSubview:timeTipL];
                    
                    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX+35, timeLabelY, timeLabelW, timeLabelH)];
                    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    timeLabel.text = self.tmpDateString;
                    [cell addSubview:timeLabel];
                    
//                    UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_address"]];
//                    locationIcon.frame = CGRectMake(locationIconX, locationIconY, locationIconW, locationIconH);
//                    [cell addSubview:locationIcon];
                    
                    NSString *orderSendAddree = orderDetailDict[@"orderSendAddree"];
                    NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
                    orderSendAddree = orderSendAddreeArray[2];
                    
                    CGFloat addressLabelX = 10;
                    CGFloat addressLabelW = cellSize.width -20-35-65; // CGRectGetMinX(locationButton.frame) - addressLabelX - 45;
                    CGFloat addressLabelH = cellSize.height / 2.0;
                    CGFloat addressLabelY = CGRectGetMaxY(timeLabel.frame);
                    
                    UILabel *addressTipL = [[UILabel alloc] initWithFrame:CGRectMake(addressLabelX, addressLabelY, 30, addressLabelH)];
                    addressTipL.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    addressTipL.text = @"地址";
                    addressTipL.backgroundColor = [UIColor clearColor];
                    addressTipL.textColor = [UIColor grayColor];
                    [cell addSubview:addressTipL];
                    
                    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressLabelX+35, addressLabelY, addressLabelW, addressLabelH)];
                    addressLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    addressLabel.text = orderSendAddree;
                    addressLabel.backgroundColor = [UIColor clearColor];
                    [cell addSubview:addressLabel];
                    
                    CGFloat locationIconH = 25;
                    CGFloat locationIconW = 65;
                    CGFloat locationIconX = CGRectGetMaxX(addressLabel.frame)+5;
                    CGFloat locationIconY = addressLabelY;
                    
                    UIButton *locationButton = [[UIButton alloc] initWithFrame:CGRectMake(locationIconX, locationIconY, locationIconW, locationIconH)];
                    locationButton.backgroundColor = APPDEFAULTORANGE;
                    [locationButton setTitle:@"查看地图" forState:UIControlStateNormal];
                    locationButton.layer.cornerRadius = 4.0;
                    [locationButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
                    [locationButton addTarget:self action:@selector(goToLocationView) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:locationButton];
                    
                    break;
                }
                case 4:
                {
                    //患者信息
                    CGFloat serviceInfoLX = 10;
                    CGFloat serviceInfoLY = 0;
                    CGFloat serviceInfoLW = cellSize.width-20;
                    CGFloat serviceInfoLH = cellSize.height/2.0;
                    
                    UILabel *userInfoL = [[UILabel alloc] initWithFrame:CGRectMake(serviceInfoLX, serviceInfoLY, serviceInfoLW, serviceInfoLH)];
                    userInfoL.userInteractionEnabled = YES;
                    userInfoL.textColor = [UIColor blackColor];
                    userInfoL.font = [UIFont systemFontOfSize:13.0];
                    userInfoL.backgroundColor = [UIColor clearColor];
                    [cell addSubview:userInfoL];
                    
                    id protectedPersonNexus = orderDetailDict[@"protectedPersonNexus"];
                    if ([protectedPersonNexus isMemberOfClass:[NSNull class]]) {
                        protectedPersonNexus = @"";
                    }
                    NSString *protectedPersonNexusStr = [NSString stringWithFormat:@"%@",protectedPersonNexus];
                    
                    NSString *username = orderDetailDict[@"orderSendUsername"];
                    NSArray *userArray = [username componentsSeparatedByString:@","];
                    NSString *nickname = nil;
                    @try {
                        nickname = userArray[1];
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                    
                    id orderSendSex = orderDetailDict[@"orderSendSex"];
                    NSString *sexStr = @"女";
                    if ([orderSendSex isMemberOfClass:[NSNull class]]) {
                        orderSendSex = @"";
                    }
                    if ([orderSendSex integerValue] == ENUM_SEX_Boy) {
                        sexStr = @"男";
                    }
                    
                    id orderSendAge = orderDetailDict[@"orderSendAge"];
                    if ([orderSendAge isMemberOfClass:[NSNull class]]) {
                        orderSendAge = @"";
                    }
                    NSString *ageStr = [NSString stringWithFormat:@"%@",orderSendAge];
                    
                    id protectedPersonHeight = orderDetailDict[@"protectedPersonHeight"];
                    if ([protectedPersonHeight isMemberOfClass:[NSNull class]]) {
                        protectedPersonHeight = @"";
                    }
                    NSString *protectedPersonHeightStr = [NSString stringWithFormat:@"%@",protectedPersonHeight];
                    
                    id protectedPersonWeight = orderDetailDict[@"protectedPersonWeight"];
                    if ([protectedPersonWeight isMemberOfClass:[NSNull class]]) {
                        protectedPersonWeight = @"";
                    }
                    NSString *protectedPersonWeightStr = [NSString stringWithFormat:@"%@",protectedPersonWeight];
                    
                    userInfoL.text = [NSString stringWithFormat:@"为%@（%@,%@,%@岁,身高%@cm,体重%@kg）预约",protectedPersonNexusStr,nickname,sexStr,ageStr,protectedPersonHeightStr,protectedPersonWeightStr];
                    
                    //备注信息
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, cellSize.height/2.0, 30, cellSize.height/2.0)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = @"备注";
                    titleLabel.font = [UIFont systemFontOfSize:13.0];
                    titleLabel.textColor = [UIColor grayColor];
                    [cell addSubview:titleLabel];
                    
                    CGFloat subTitleLabelX = CGRectGetMaxX(titleLabel.frame) + 5;
                    CGFloat subTitleLabelY = cellSize.height/2.0;
                    CGFloat subTitleLabelH = cellSize.height/2.0;
                    CGFloat subTitleLabelW = SCREENWIDTH - subTitleLabelX - 10;
                    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(subTitleLabelX, subTitleLabelY, subTitleLabelW, subTitleLabelH)];
                    subTitleLabel.backgroundColor = [UIColor clearColor];
                    
                    NSString *orderSendNote = orderDetailDict[@"orderSendNote"];
                    if ([orderSendNote isMemberOfClass:[NSNull class]]) {
                        orderSendNote = @"";
                    }
                    subTitleLabel.text = orderSendNote;
                    subTitleLabel.font = [UIFont systemFontOfSize:13.0];
                    subTitleLabel.textColor = [UIColor blackColor];
                    [cell addSubview:subTitleLabel];
                    
                    
                    
                    /*
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
                    */
                    
                    
                    
                    break;
                }
//                case 5:{
//                    //备注信息
//                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, cellSize.height)];
//                    titleLabel.backgroundColor = [UIColor clearColor];
//                    titleLabel.text = @"备注信息";
//                    titleLabel.font = [UIFont systemFontOfSize:15.0];
//                    titleLabel.textColor = [UIColor blackColor];
//                    [cell addSubview:titleLabel];
//                    
//                    CGFloat subTitleLabelX = CGRectGetMaxX(titleLabel.frame) + 5;
//                    CGFloat subTitleLabelY = 0;
//                    CGFloat subTitleLabelH = cellSize.height;
//                    CGFloat subTitleLabelW = SCREENWIDTH - subTitleLabelX - 10;
//                    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(subTitleLabelX, subTitleLabelY, subTitleLabelW, subTitleLabelH)];
//                    subTitleLabel.backgroundColor = [UIColor clearColor];
//                    
//                    NSString *orderSendNote = orderDetailDict[@"orderSendNote"];
//                    if ([orderSendNote isMemberOfClass:[NSNull class]]) {
//                        orderSendNote = @"";
//                    }
//                    subTitleLabel.text = orderSendNote;
//                    subTitleLabel.textAlignment = NSTextAlignmentRight;
//                    subTitleLabel.font = [UIFont systemFontOfSize:15.0];
//                    subTitleLabel.textColor = [UIColor blackColor];
//                    [cell addSubview:subTitleLabel];
//                }
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
                        endLabel.textColor = [UIColor redColor];
                        [cell addSubview:endLabel];
                    }
                    break;
                }
//                case 1:{
//                    
////                    [cell addSubview:timeLabel];
//                    
//                    break;
//                }
//                case 2:{
////                    [cell addSubview:nurseBG];
//                    id orderSendTypeObj = orderDetailDict[@"orderSendType"];
//                    if ([orderSendTypeObj isMemberOfClass:[NSNull class]]) {
//                        orderSendTypeObj = @"";
//                    }
//                    id orderSendStateObj = orderDetailDict[@"orderSendState"];
//                    if ([orderSendStateObj isMemberOfClass:[NSNull class]]) {
//                        orderSendStateObj = @"";
//                    }
//                    NSInteger orderSendType = [orderSendTypeObj integerValue];
//                    NSInteger orderSendState = [orderSendStateObj integerValue];
//                    
//                    if (orderSendState == 0) {
//                        //还没接单
//                        CGFloat endLabelY = 0;
//                        CGFloat endLabelW = 150;
//                        CGFloat endLabelH = cellSize.height;
//                        CGFloat endLabelX = 10;
//                        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
//                        endLabel.font = [UIFont systemFontOfSize:17.0];
//                        id orderSendCostmoney = orderDetailDict[@"orderSendCostmoney"];
//                        if ([orderSendCostmoney isMemberOfClass:[NSNull class]]) {
//                            orderSendCostmoney = @"";
//                        }
//                        endLabel.text = @"暂无护士资料";
//                        
//                        endLabel.textAlignment = NSTextAlignmentLeft;
//                        endLabel.textColor = [UIColor redColor];
//                        [cell addSubview:endLabel];
//                    }
//                    else{
//                        NSString *nurseHeader = orderDetailDict[@"nurseHeader"];
//                        if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
//                            nurseHeader = nil;
//                        }
//                        if (nurseHeader != nil) {
//                            nurseHeader = [NSString stringWithFormat:@"%@/%@",BASEURL,nurseHeader];
//                            [nurseArray addObject:nurseHeader];
//                        }
//                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
// 
//                        CGFloat imageViewX = 10;
//                        CGFloat imageViewY = 10;
//                        CGFloat imageViewH = cellSize.height - 2 * imageViewY;
//                        CGFloat imageViewW = imageViewH;
//                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH)];
//                        imageView.layer.masksToBounds = YES;
//                        imageView.layer.cornerRadius = imageViewW / 2.0;
//                        imageView.contentMode = UIViewContentModeScaleAspectFill;
//                        [cell addSubview:imageView];
//                        [imageView sd_setImageWithURL:[NSURL URLWithString:nurseHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
//                        
//                        CGFloat nurseInfoY = 10;
//                        CGFloat nurseInfoW = 150;
//                        CGFloat nurseInfoH = imageViewH / 3.0;
//                        CGFloat nurseInfoX = CGRectGetMaxX(imageView.frame) + 5;
//                        UILabel *nurseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(nurseInfoX, nurseInfoY, nurseInfoW, nurseInfoH)];
//                        nurseInfoLabel.font = [UIFont systemFontOfSize:13.0];
//                        id orderSendCostmoney = orderDetailDict[@"orderSendCostmoney"];
//                        if ([orderSendCostmoney isMemberOfClass:[NSNull class]]) {
//                            orderSendCostmoney = @"";
//                        }
//                        NSString *nurseNick = orderDetailDict[@"nurseNick"];
//                        if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
//                            nurseNick = @"";
//                        }
//                        NSString *nurseJob = orderDetailDict[@"nurseJob"];
//                        if ([nurseJob isMemberOfClass:[NSNull class]] || nurseJob == nil) {
//                            nurseJob = @"护士";
//                        }
//                        nurseInfoLabel.text = [NSString stringWithFormat:@"%@  %@",nurseNick,nurseJob];
//                        
//                        nurseInfoLabel.textAlignment = NSTextAlignmentLeft;
//                        nurseInfoLabel.textColor = [UIColor blackColor];
//                        [cell addSubview:nurseInfoLabel];
//                        
//                        NSString *nurseWorkNnit = orderDetailDict[@"nurseWorkNnit"];
//                        if ([nurseWorkNnit isMemberOfClass:[NSNull class]] || nurseWorkNnit == nil) {
//                            nurseWorkNnit = @"该护士未选定指定医院";
//                        }
//                        CGFloat hospitalLabelY = CGRectGetMaxY(nurseInfoLabel.frame);
//                        CGFloat hospitalLabelW = 150;
//                        CGFloat hospitalLabelH = imageViewH / 3.0;
//                        CGFloat hospitalLabelX = CGRectGetMaxX(imageView.frame) + 5;
//                        UILabel *hospitalLabel = [[UILabel alloc] initWithFrame:CGRectMake(hospitalLabelX, hospitalLabelY, hospitalLabelW, hospitalLabelH)];
//                        hospitalLabel.font = [UIFont systemFontOfSize:13.0];
//                        hospitalLabel.text = nurseWorkNnit;
//                        
//                        hospitalLabel.textAlignment = NSTextAlignmentLeft;
//                        hospitalLabel.textColor = [UIColor blackColor];
//                        [cell addSubview:hospitalLabel];
//                        
//                        
//                        CGFloat markInfoLabelY = CGRectGetMaxY(hospitalLabel.frame);
//                        CGFloat markInfoLabelW = 150;
//                        CGFloat markInfoLabelH = imageViewH / 3.0;
//                        CGFloat markInfoLabelX = CGRectGetMaxX(imageView.frame) + 5;
//                        UILabel *markInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(markInfoLabelX, markInfoLabelY, markInfoLabelW, markInfoLabelH)];
//                        markInfoLabel.font = [UIFont systemFontOfSize:13.0];
//                        markInfoLabel.text = @"熟悉医务护理知识";
//                        
//                        markInfoLabel.textAlignment = NSTextAlignmentLeft;
//                        markInfoLabel.textColor = [UIColor blackColor];
//                        [cell addSubview:markInfoLabel];
//                        
//                        CGFloat endLabelY = nurseInfoY;
//                        CGFloat endLabelW = 80;
//                        CGFloat endLabelH = nurseInfoH;
//                        CGFloat endLabelX = SCREENWIDTH - 30 - endLabelW;
//                        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
//                        endLabel.font = [UIFont systemFontOfSize:13.0];
//                        
//                        id nurseSex = orderDetailDict[@"nurseSex"];
//                        if ([nurseSex isMemberOfClass:[NSNull class]] || nurseSex == nil) {
//                            nurseSex = @"";
//                        }
//                        NSString *nurseSexStr = @"女";
//                        if ([nurseSexStr integerValue] == ENUM_SEX_Boy) {
//                            nurseSexStr = @"男";
//                        }
//                        
//                        id nurseAge = orderDetailDict[@"nurseAge"];
//                        if ([nurseAge isMemberOfClass:[NSNull class]] || nurseAge == nil) {
//                            nurseAge = @"24";
//                        }
//                        
//                        endLabel.text = [NSString stringWithFormat:@"%@  %@岁",nurseSexStr,nurseAge];
//                        
//                        endLabel.textAlignment = NSTextAlignmentRight;
//                        endLabel.textColor = [UIColor blackColor];
//                        
//                        //距离
//                        endLabelY = cellSize.height - 10 - nurseInfoH;
//                        endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
//                        endLabel.font = [UIFont systemFontOfSize:13.0];
//                        endLabel.textColor = [UIColor grayColor];
//                        
//                        id distance = orderDetailDict[@"distance"];
//                        if ([distance isMemberOfClass:[NSNull class]] || distance == nil) {
//                            distance = @"";
//                        }
//                        NSString *distanceStr = [NSString stringWithFormat:@"%.2fm",[distance floatValue]];
//                        if ([distance floatValue]>= 1000) {
//                            distanceStr = [NSString stringWithFormat:@"%.2fkm",[distance floatValue] / 1000.0];
//                        }
//                        
//                        
//                        
//                        
//                        
//                    }
//                    break;
//                }
//                case 3:{
//                    
//                    break;
//                }
                default:
                    break;
            }
            break;
        }
        case 2:
        {
            UIImageView *piccImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 40)];
            [piccImageView setBackgroundColor:[UIColor clearColor]];
            piccImageView.userInteractionEnabled = YES;
            piccImageView.image = [UIImage imageNamed:@"icon_picc"];
            [cell addSubview:piccImageView];
            
            UILabel *piccTipL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(piccImageView.frame), 5, SCREENWIDTH-CGRectGetMaxX(piccImageView.frame)-40, 50)];
            piccTipL.textColor = [UIColor grayColor];
            piccTipL.userInteractionEnabled = YES;
            piccTipL.numberOfLines = 0;
            piccTipL.text = @"【护士上门】将免费为患者和医护人员投保中国人寿意外险";
            piccTipL.font = [UIFont systemFontOfSize:12.0];
            piccTipL.backgroundColor = [UIColor clearColor];
            [cell addSubview:piccTipL];
            
            
            UIImageView *quessionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(piccTipL.frame), 20, 20, 20)];
            [quessionImageView setBackgroundColor:[UIColor clearColor]];
            quessionImageView.userInteractionEnabled = YES;
            quessionImageView.image = [UIImage imageNamed:@"icon_question"];
            [cell addSubview:quessionImageView];

            break;
        }
        case 3:
        {
            switch (row) {
                case 0:
                {
                    CGFloat timeLabelX = 10;
                    CGFloat timeLabelW = SCREENWIDTH - 2 * timeLabelX;
                    CGFloat timeLabelH = cellSize.height / 2.0;
                    CGFloat timeLabelY = 0;
                    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
                    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    timeLabel.text = [NSString stringWithFormat:@"接单时间：%@",self.tmpDateString];
                    [cell addSubview:timeLabel];
                    
                    CGFloat orderNoLabelX = 10;
                    CGFloat orderNoLabelW = SCREENWIDTH - 2 * orderNoLabelX;
                    CGFloat orderNoLabelH = cellSize.height/2.0;
                    CGFloat orderNoLabelY = CGRectGetMaxY(timeLabel.frame)-5;
                    UILabel *orderNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderNoLabelX, orderNoLabelY, orderNoLabelW, orderNoLabelH)];
                    orderNoLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    id orderSendNumbers = orderDetailDict[@"orderSendNumbers"];
                    orderNoLabel.text = [NSString stringWithFormat:@"订单编号: %@",orderSendNumbers];
                    [cell addSubview:orderNoLabel];
                    
                }
                    break;
                case 1:
                {
                    //订单状态（0正在发布/1已被接取/2已服务/3已完成/4被取消/为空为待预约
                    id orderSendStateObj = orderDetailDict[@"orderSendState"];
                    if ([orderSendStateObj isMemberOfClass:[NSNull class]] || orderSendStateObj == nil) {
                        orderSendStateObj = @"";
                    }
                    NSInteger orderSendState = [orderSendStateObj integerValue];
                    
                    CGFloat buttonX = 0;
                    CGFloat buttonY = 0;
                    CGFloat buttonW = SCREENWIDTH / 2.0;
                    CGFloat buttonH = cellSize.height;
                    
                    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
                    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
                    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:cancelButton];
                    if (orderSendState == 1 || orderSendState == 2) {
                        [cancelButton setTitle:@"取消服务" forState:UIControlStateNormal];
                        cancelButton.tag = 0;
                    }else if (orderSendState == 1){
                        [cancelButton setTitle:@"进行评价" forState:UIControlStateNormal];
                        cancelButton.tag = 10;
                    }

                    buttonX = CGRectGetMaxX(cancelButton.frame);
                    buttonW = SCREENWIDTH - buttonX;
                    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];

                    [nextButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
                    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [nextButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:nextButton];
                    if (orderSendState == 1 || orderSendState == 2) {
                        nextButton.tag = 1;
                        [nextButton setTitle:@"联系客服" forState:UIControlStateNormal];
                    }else if (orderSendState == 1){
                        nextButton.tag = 11;
                        [nextButton setTitle:@"联系客服" forState:UIControlStateNormal];
                    }

                    
                    CGFloat sepLineX = buttonX;
                    CGFloat sepLineY = 3;
                    CGFloat sepLineH = cellSize.height - 2 * sepLineY;
                    CGFloat sepLineW = 1;
                    
                    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
                    sepLine.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
                    [cell addSubview:sepLine];
                }
                    break;
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
            if (row == 2) {
                return serviceBG.frame.size.height;
            }
            else if (row == 3 || row == 4) {
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
//                case 1:
//                    //订单编号
//                    return 50;
//                    break;
//                case 2:{
//                    if ([nurseArray count] == 0) {
//                        return 44;
//                    }
//                    return nurseBG.frame.size.height + 10;
//                    break;
//                }
//                case 3:
//                    
//                    return 44;
                default:
                    break;
            }
        }
        case 2:
        {
            return 50;
            
        }
        break;
        case 3:
        {
            switch (row) {
                case 0:
                {
                    return 60;
                }
                    break;
                case 1:
                {
                    return 44;
                }
                    break;
                    
                default:
                    break;
            }
        }
        break;
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
                
                case 4:
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
                        return;
                    }
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

- (void)callCustomer{
    NSString *nursePhone = orderDetailDict[@"nursePhone"];
    if ([nursePhone isMemberOfClass:[NSNull class]] || nursePhone == nil) {
        [self showHint:@"暂无护士的联系方式"];
        return;
    }
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",nursePhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    
}

- (void)goToLocationView{
    //位置
    NSString *orderSendAddree = orderDetailDict[@"orderSendAddree"];
    NSArray *orderSendAddreeArray = [orderSendAddree componentsSeparatedByString:@","];
    NSString *zoneLocationX = nil;
    @try {
        zoneLocationX = orderSendAddreeArray[0];
    } @catch (NSException *exception) {
        zoneLocationX = @"";
    } @finally {
        
    }
    NSString *zoneLocationY = nil;
    @try {
        zoneLocationY = orderSendAddreeArray[1];
    } @catch (NSException *exception) {
        zoneLocationY = @"";
    } @finally {
        
    }
    
    NSDictionary *userLocationDict = @{@"zoneLocationX":zoneLocationX,@"zoneLocationY":zoneLocationY};
    HeUserLocatiVC *userLocationVC = [[HeUserLocatiVC alloc] init];
    userLocationVC.userLocationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
    userLocationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userLocationVC animated:YES];

}

//已预约，进行中
//取消服务
- (void)cancelServiceWithDict:(NSDictionary *)orderInfo
{
    if (ISIOS7) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求取消" message:@"若取消这笔订单，您支付的费用将于一周内全额退还至您的余额中，确定要取消这笔订单吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 200;
        [alertView show];
        return;
    }
    else{
        __weak HeOrderDetailVC *weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求取消" message:@"若取消这笔订单，您支付的费用将于一周内全额退还至您的余额中，确定要取消这笔订单吗？"  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//            _currentHandleOrderInfo = nil;
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [weakSelf requestCancelOrder:orderInfo];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    

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
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOrderNotification object:nil];
            [self performSelector:@selector(backToRootView) withObject:nil afterDelay:1.2f];
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

- (void)backToRootView{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200 && buttonIndex == 1){
        //取消订单
        [self requestCancelOrder:orderDetailDict];
    }
}

//前往评价
- (void)commentOrder
{
    NSLog(@"commentOrder");
    HeCommentNurseVC *commentNurseVC = [[HeCommentNurseVC alloc] init];
    commentNurseVC.nurseDict = [[NSDictionary alloc] initWithDictionary:orderDetailDict];
    commentNurseVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentNurseVC animated:YES];
    
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
