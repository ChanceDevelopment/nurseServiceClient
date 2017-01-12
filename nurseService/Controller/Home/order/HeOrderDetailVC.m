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
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    statusArray = @[@"已接单",@"已沟通",@"已出发",@"开始服务",@"已完成"];
    imageScrollViewHeigh = 80;
    paperArray = [[NSMutableArray alloc] initWithCapacity:0];
    nurseArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 55)];
    tableview.tableHeaderView = statusView;
    [self addStatueViewWithStatus:eOrderStatusTypeStart];
    
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
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    [paperArray addObject:@"123"];
    
    [self addPhotoScrollView];
    
    serviceBG = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 20, 0)];
    
    [self addServiceLabel];
    
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    [nurseArray addObject:@"123"];
    
    CGFloat receivescrollX = 5;
    CGFloat receivescrollY = 5;
    CGFloat receivescrollW = SCREENWIDTH - 2 * receivescrollX;
    CGFloat receivescrollH = 80;
    nurseBG = [[UIScrollView alloc] initWithFrame:CGRectMake(receivescrollX, receivescrollY, receivescrollW, receivescrollH)];
    [self addNurseHead];
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
        if (![url hasPrefix:@"http"]) {
            imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
        }
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
    NSArray *serviceArray = @[@"产妇护理套餐",@"产妇护理套餐产妇护理套餐1产妇护理套餐2",@"产妇护理套餐",@"产妇护理套餐"];
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
        if (index <= statusType) {
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
        NSString *imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        [imageview sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
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
        NSLog(@"请求取消");
    }
    else{
        NSLog(@"填写护理报告");
    }
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
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, cellSize.height)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.text = @"新生儿护理";
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
                    subTitleLabel.text = @"未接单";
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
                    timeLabel.text = @"07/26 星期二 16:00 ~ 18:00";
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
                    addressLabel.text = @"西湖区西溪路385号西西创立方24号801";
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
                    subTitleLabel.text = @"小明   男   12岁";
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
                    subTitleLabel.text = @"宝宝一岁半，经常尿床";
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
                    break;
                }
                case 1:{
                    CGFloat orderNoLabelX = 10;
                    CGFloat orderNoLabelW = SCREENWIDTH - 2 * orderNoLabelX;
                    CGFloat orderNoLabelH = cellSize.height;
                    CGFloat orderNoLabelY = 0;
                    UILabel *orderNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderNoLabelX, orderNoLabelY, orderNoLabelW, orderNoLabelH)];
                    orderNoLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
                    orderNoLabel.text = @"订单编号: 201610324222";
                    [cell addSubview:orderNoLabel];
                    
                    
                    
                    CGFloat timeLabelX = 10;
                    CGFloat timeLabelW = SCREENWIDTH - 2 * timeLabelX;
                    CGFloat timeLabelH = cellSize.height / 2.0;
                    CGFloat timeLabelY = CGRectGetMaxY(orderNoLabel.frame);
                    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
                    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    timeLabel.text = @"接单时间: 2016 07/26 17:30";
//                    [cell addSubview:timeLabel];
                    
                    break;
                }
                case 2:{
                    [cell addSubview:nurseBG];
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
                    return 44 + photoScrollView.frame.size.height;
                    break;
                case 1:
                    //订单编号
                    return 50;
                    break;
                case 2:{
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
                    HePaitentInfoVC *paitentInfoVC = [[HePaitentInfoVC alloc] init];
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
