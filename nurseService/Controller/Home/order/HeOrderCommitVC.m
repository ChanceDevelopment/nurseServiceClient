//
//  HeOrderCommitVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeOrderCommitVC.h"
#import "HeBaseTableViewCell.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "ScanPictureView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "BrowserView.h"
#import "DeleteImageProtocol.h"
#import "UWDatePickerView.h"
#import "HeSettingPayPasswordVC.h"
#import "HeReportVC.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "HeSelectProtectedUserInfoVC.h"
#import "FTPopOverMenu.h"
#import "SSPopup.h"
#import "HeUserCouponVC.h"

#define ALERTTAG 200
#define MinLocationSucceedNum 1   //要求最少成功定位的次数
#define TextLineHeight 1.2f

#define MAXUPLOADIMAGE 6
#define MAX_column  4
#define MAX_row 3
#define IMAGEWIDTH 70

@interface HeOrderCommitVC ()<DeleteImageProtocol,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,TZImagePickerControllerDelegate,UWDatePickerViewDelegate,UITextFieldDelegate,SelectProtectUserInfoProtocol,SSPopupDelegate,SelectCouponDelegate>
{
    BOOL currentSelectBanner;
    NSInteger payType; //支付方式 0：在线 1：支付宝
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *bannerImageBG;
@property(strong,nonatomic)UIView *serviceBG;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSArray *payIconDataSource;
@property(strong,nonatomic)NSArray *payMethodDataSource;
@property(strong,nonatomic)NSMutableArray *bannerImageDataSource;
@property(strong,nonatomic)UIButton *addPictureButton;

@property(strong,nonatomic)NSMutableArray *selectedAssets;
@property(strong,nonatomic)NSMutableArray *selectedPhotos;
@property(strong,nonatomic)NSMutableArray *takePhotoArray;

@property(strong,nonatomic)IBOutlet UIView *payBGView;
@property(strong,nonatomic)NSString *tmpDateString;

@property(strong,nonatomic)NSDictionary *orderDetailDict;
@property(strong,nonatomic)UIView *dismissView;
@property(strong,nonatomic)UIScrollView *myScrollView;
@property(strong,nonatomic)NSArray *subServiceArray;

@end

@implementation HeOrderCommitVC
@synthesize tableview;
@synthesize bannerImageBG;
@synthesize dataSource;
@synthesize payIconDataSource;
@synthesize payMethodDataSource;
@synthesize serviceBG;
@synthesize bannerImageDataSource;
@synthesize addPictureButton;
@synthesize takePhotoArray;
@synthesize payBGView;
@synthesize tmpDateString;
@synthesize orderDetailDict;
@synthesize dismissView;
@synthesize myScrollView;
@synthesize orderDict;
@synthesize subServiceArray;

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
        label.text = @"订单确认";
        [label sizeToFit];
        self.title = @"订单确认";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    subServiceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    [self loadOrderDetail];
    
}

- (void)initializaiton
{
    [super initializaiton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetAlipayResult:) name:@"GetAlipayResult" object:nil];
    
    dataSource = @[@"服务时间",@"受护人",@"产妇护理套餐",@"套餐列表",@"备注信息",@"图片资料",@"优惠券",@"交通费",@"总额",@"支付方式",@"      中国人寿保险"];
    payMethodDataSource = @[@"余额支付",@"支付宝支付"];
    payIconDataSource = @[@"icon_online",@"icon_alipay"];
    bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (!_selectedPhotos) {
        _selectedPhotos = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    }
    takePhotoArray = [[NSMutableArray alloc] initWithCapacity:0];
    
}

- (void)initView
{
    [super initView];

    CGFloat payButtonW = 100;
    CGFloat payButtonX = SCREENWIDTH - payButtonW;
    CGFloat payButtonY = 0;
    CGFloat payButtonH = 50;
    
    UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(payButtonX, payButtonY, payButtonW, payButtonH)];
    [payButton setTitle:@"确认支付" forState:UIControlStateNormal];
    [payButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:payButton.frame.size] forState:UIControlStateNormal];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [payButton addTarget:self action:@selector(payButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [payBGView addSubview:payButton];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - payButtonW, payButtonH)];
    moneyLabel.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [payBGView addSubview:moneyLabel];
    
    UILabel *moneyTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, payButtonH)];
    moneyTipLabel.text = @"需支付:";
    moneyTipLabel.font = [UIFont systemFontOfSize:18.0];
    moneyTipLabel.textColor = [UIColor grayColor];
    moneyTipLabel.backgroundColor = [UIColor clearColor];
    [payBGView addSubview:moneyTipLabel];
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moneyTipLabel.frame) + 2.0, 0,CGRectGetWidth(moneyLabel.frame) - (CGRectGetMaxX(moneyTipLabel.frame) + 2.0), payButtonH)];
    payLabel.textAlignment = NSTextAlignmentLeft;
    id orderSendTotalmoney = orderDetailDict[@"orderSendTotalmoney"];
    payLabel.text = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
    payLabel.font = [UIFont systemFontOfSize:18.0];
    payLabel.textColor = [UIColor redColor];
    payLabel.backgroundColor = [UIColor clearColor];
    [payBGView addSubview:payLabel];
    
    CGFloat footerViewX = 0;
    CGFloat footerViewY = 0;
    CGFloat footerViewW = SCREENWIDTH;
    CGFloat footerViewH = 120;
//    icon_agree
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(footerViewX, footerViewY, footerViewW, footerViewH)];
    tableview.tableFooterView = footerView;
    
    UIImageView *agreeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    agreeIcon.image = [UIImage imageNamed:@"icon_agree"];
    [footerView addSubview:agreeIcon];
    
    CGFloat agreeLabelX = CGRectGetMaxX(agreeIcon.frame) + 5;
    CGFloat agreeLabelY = 10;
    CGFloat agreeLabelW = 200;
    CGFloat agreeLabelH = 20;
    
    UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(agreeLabelX, agreeLabelY, agreeLabelW, agreeLabelH)];
    agreeLabel.backgroundColor = [UIColor clearColor];
    agreeLabel.textColor = [UIColor grayColor];
    agreeLabel.font = [UIFont systemFontOfSize:13.0];
    agreeLabel.text = @"同意  i护到家免责提款";
    [footerView addSubview:agreeLabel];
    
    CGFloat tipLabelX = 10;
    CGFloat tipLabelY = CGRectGetMaxY(agreeIcon.frame) + 3;
    CGFloat tipLabelW = 100;
    CGFloat tipLabelH = 20;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipLabelX, tipLabelY, tipLabelW, tipLabelH)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = APPDEFAULTORANGE;
    tipLabel.font = [UIFont systemFontOfSize:13.0];
    tipLabel.text = @"温馨提示";
    [footerView addSubview:tipLabel];
    
    CGFloat tipContentLabelX = 10;
    CGFloat tipContentLabelY = CGRectGetMaxY(tipLabel.frame) + 1;
    CGFloat tipContentLabelW = SCREENWIDTH - 2 * tipContentLabelX;
    CGFloat tipContentLabelH = footerViewH - tipContentLabelY - 10;
    
    UILabel *tipContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipContentLabelX, tipContentLabelY, tipContentLabelW, tipContentLabelH)];
    tipContentLabel.backgroundColor = [UIColor clearColor];
    tipContentLabel.textColor = [UIColor grayColor];
    tipContentLabel.font = [UIFont systemFontOfSize:13.0];
    tipContentLabel.numberOfLines = 0;
    tipContentLabel.text = @"除套餐外，每个单项服务报价不含上门费50元，需要外加手，每个订单只收取一次上门费";
    [footerView addSubview:tipContentLabel];
    
    addPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, IMAGEWIDTH, IMAGEWIDTH)];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"icon_add_photo"] forState:UIControlStateNormal];
    addPictureButton.tag = 100;
    [addPictureButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
//    bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
//    int row = [Tool getRowNumWithTotalNum:[bannerImageDataSource count]];
//    int column = [Tool getColumnNumWithTotalNum:[bannerImageDataSource count]];
//    CGFloat bannerX = 5;
//    CGFloat bannerY = 5;
//    CGFloat bannerW = SCREENWIDTH - 2 * bannerX;
//    CGFloat bannerH = IMAGEWIDTH;
//    bannerImageBG = [[UIView alloc] initWithFrame:CGRectMake(bannerX, bannerY, bannerW, bannerH)];
//    [bannerImageBG setBackgroundColor:[UIColor whiteColor]];
//    [bannerImageBG addSubview:addPictureButton];
//    bannerImageBG.userInteractionEnabled = YES;
//    addPictureButton.hidden = YES;
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, SCREENWIDTH, 110)];
    
    
    serviceBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 20, 0)];
    
    [self addServiceLabel];
}

- (void)GetAlipayResult:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (![[userInfo objectForKey:@"result"] boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"支付未能成功" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self showHint:@"支付成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)payButtonClick:(UIButton *)sender
{
    NSLog(@"payButtonClick");
    if (payType == 1) {
        sender.enabled = NO;
        [self alipay];
        return;
    }
    [self inputPayPassword];
}

- (void)alipay
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/alipay/signProve.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    id finalyMoney = orderDetailDict[@"orderSendTotalmoney"];
    if ([finalyMoney isMemberOfClass:[NSNull class]] || finalyMoney == nil) {
        finalyMoney = @"";
    }
    CGFloat money = [finalyMoney floatValue];
    
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f",money];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"money":moneyStr,@"Type":@"2",@"orderId":_orderId,@"couponId":@""};
    [self showHudInView:self.view hint:@"支付中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (statueCode == REQUESTCODE_SUCCEED) {
            
            NSString *appScheme = @"AlipaySdkNurseServiceClient";//-----回调id,返回应用
            NSString *orderString = respondDict[@"json"];
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"resultDic: %@",resultDic);
                /*
                 *
                 *
                 *此处不返回支付结果
                 *
                 *
                 ***/
            }];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
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
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            orderDetailDict = [[NSDictionary alloc] initWithDictionary:respondDict[@"json"]];
            NSString *contentId = orderDetailDict[@"contentId"];
            if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
                contentId = @"";
            }
            [self loadOrderServiceArrayWithContentId:contentId];
            
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
            //所有数据重新刷新一次
            [self initializaiton];
            [self initView];
            
            bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
            NSString *orderSendUserpic = orderDetailDict[@"orderSendUserpic"];
            if ([orderSendUserpic isMemberOfClass:[NSNull class]] || orderSendUserpic == nil) {
                orderSendUserpic = nil;
            }
            NSArray *orderSendUserpicArray = [orderSendUserpic componentsSeparatedByString:@","];
            for (NSString *url in orderSendUserpicArray) {
                NSString *myurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
                [bannerImageDataSource addObject:myurl];
            }
            [self updateImageBG];
            [tableview reloadData];
        }
        else{
            [self hideHud];
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        NSLog(@"errorInfo = %@",err);
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}


- (void)addButtonClick:(UIButton *)sender
{
    if ([bannerImageDataSource count] > MAXUPLOADIMAGE) {
        [self showHint:[NSString stringWithFormat:@"上传图片最多不能超过%d张",MAXUPLOADIMAGE]];
        return;
    }
    currentSelectBanner = YES;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 1;
    [sheet showInView:bannerImageBG];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                if (ISIOS7) {
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        [self pickerCamer];
                    }
                }
                else{
                    [self pickerCamer];
                }
                
                
                break;
            }
            case 0:
            {
                if (ISIOS7) {
                    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
                        //无权限
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    else{
                        [self mutiplepickPhotoSelect];
                    }
                }
                else{
                    [self mutiplepickPhotoSelect];
                }
                break;
            }
            case 2:
            {
                break;
            }
            default:
                break;
        }
    }
}


- (void)updateImageBG
{
    CGFloat imageX = 5;
    CGFloat imageY = 5;
    CGFloat imageH = 100;
    CGFloat imageW = 100;
    for (NSInteger index = 0; index < [bannerImageDataSource count]; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:bannerImageDataSource[index]] placeholderImage:[UIImage imageNamed:@"index2"]];
        imageView.layer.cornerRadius = 5.0;
        imageView.tag = index + 10000;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        [myScrollView addSubview:imageView];
        imageX = imageX + imageW + 5;
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
        tapGes.numberOfTapsRequired = 1;
        tapGes.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:tapGes];
        
    }
    myScrollView.contentSize = CGSizeMake(imageX, 0);
    if ([bannerImageDataSource count] > 0) {
        [tableview reloadData];
        myScrollView.hidden = NO;
//        UIView *myfooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, myScrollView.frame.size.height)];
//        myfooterView.backgroundColor = [UIColor whiteColor];
//        [myfooterView addSubview:myScrollView];
//        
//        tableview.tableFooterView = myfooterView;
    }
    else{
        myScrollView.hidden = YES;
    }
}

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
    return;
    NSInteger selectIndex = tap.view.tag + 1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AsynImageView *asyImage in bannerImageDataSource) {
        if (asyImage.highlightedImage == nil) {
            [array addObject:asyImage];
        }
    }
    
    ScanPictureView *scanPictureView = [[ScanPictureView alloc] initWithArray:array selectButtonIndex:selectIndex];
    scanPictureView.deleteDelegate = self;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTintColor:[UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    scanPictureView.navigationItem.backBarButtonItem = backButton;
    scanPictureView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanPictureView animated:YES];
}

//删除所选图片的代理方法
-(void)deleteImageAtIndex:(int)index
{
    [bannerImageDataSource removeObjectAtIndex:index];
    [self updateImageBG];
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

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 9) {
        //支付方式，多种支付方式
        return 3;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
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
    if (section == 9) {
        if (row == 0) {
            NSString *titleString = dataSource[section];
            cell.textLabel.text = titleString;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        }
        else{
            
        }
    }
    else{
        NSString *titleString = dataSource[section];
        cell.textLabel.text = titleString;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    }
    
    switch (section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 30;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:14.0];
            endLabel.text = self.tmpDateString;
            if (self.tmpDateString == nil) {
                endLabel.text = @"请选择日期";
            }
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.textColor = [UIColor grayColor];
            [cell addSubview:endLabel];
            
            break;
        }
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height / 2.0;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 30;
            
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
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.font = [UIFont systemFontOfSize:13.0];
            endLabel.text = [NSString stringWithFormat:@"%@  %@  %@岁",orderSendUsername,orderSendSexStr,orderSendAge];
            endLabel.textColor = [UIColor grayColor];
            [cell addSubview:endLabel];
            
            endLabelW = SCREENWIDTH - 110;
            endLabelX = SCREENWIDTH - endLabelW - 30;
            endLabelY = CGRectGetMaxY(endLabel.frame);
            UILabel *endLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel1.textAlignment = NSTextAlignmentRight;
            endLabel1.font = [UIFont systemFontOfSize:13.0];
            endLabel1.text = orderSendAddree;
            endLabel1.textColor = [UIColor grayColor];
            [cell addSubview:endLabel1];
            
            break;
        }
        case 2:
        {
            
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 30;
            
            NSString *orderSendServicecontent = orderDetailDict[@"orderSendServicecontent"];
            NSArray *orderSendServicecontentArray = [orderSendServicecontent componentsSeparatedByString:@":"];
            orderSendServicecontent = orderSendServicecontentArray[0];
            cell.textLabel.text = orderSendServicecontent;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:17.0];
            id orderSendCostmoney = orderDetailDict[@"orderSendCostmoney"];
            if ([orderSendCostmoney isMemberOfClass:[NSNull class]]) {
                orderSendCostmoney = @"";
            }
            endLabel.text = [NSString stringWithFormat:@"￥%@",orderSendCostmoney];
            
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.textColor = [UIColor redColor];
            [cell addSubview:endLabel];
            
            break;
        }
            
        case 3:
        {
            //产妇套餐列表
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = nil;
            [cell addSubview:serviceBG];
            break;
        }
        case 5:{
            //图片资料
            cell.textLabel.text = nil;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
            titleLabel.font = [UIFont systemFontOfSize:15.0];
            titleLabel.text = @" 图片资料";
            [cell addSubview:titleLabel];
            
            CGRect bannerFrame = bannerImageBG.frame;
            bannerFrame.origin.y = CGRectGetMaxY(titleLabel.frame) + 5;
            bannerImageBG.frame = bannerFrame;
            [cell addSubview:myScrollView];
            if ([bannerImageDataSource count] == 0) {
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
        case 6:{
            //优惠券
            id orderSendCoupon = orderDetailDict[@"orderSendCoupon"];
            if ([orderSendCoupon isMemberOfClass:[NSNull class]] || orderSendCoupon == nil) {
                orderSendCoupon = @"";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 30;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            endLabel.text = @"选择可用优惠券";
            if ([orderSendCoupon floatValue] > 0) {
                endLabel.text = [NSString stringWithFormat:@"-￥%.2f",[orderSendCoupon floatValue]];
            }
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.textColor = [UIColor redColor];
            [cell addSubview:endLabel];
            
            break;
        }
        case 7:{
            //交通费
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 10;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            id orderSendTrafficmoney = orderDetailDict[@"orderSendTrafficmoney"];
            endLabel.text = [NSString stringWithFormat:@"￥%@",orderSendTrafficmoney];
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.textColor = APPDEFAULTORANGE;
            [cell addSubview:endLabel];
            break;
        }
        case 8:{
            //总额
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 10;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            id orderSendTotalmoney = orderDetailDict[@"orderSendTotalmoney"];
            endLabel.text = [NSString stringWithFormat:@"￥%@",orderSendTotalmoney];
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.textColor = [UIColor redColor];
            [cell addSubview:endLabel];
            
            break;
        }
        case 9:{
            //支付方式
            if (row > 0) {
                NSString *title = payMethodDataSource[row - 1];
                NSString *icon = payIconDataSource[row - 1];
                
                CGFloat iconImageX = 30;
                CGFloat iconImageH = 25;
                CGFloat iconImageW = 25;
                CGFloat iconImageY = (cellSize.height - iconImageH) / 2.0;
                
                UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(iconImageX, iconImageY, iconImageW, iconImageH)];
                iconImage.image = [UIImage imageNamed:icon];
                [cell addSubview:iconImage];
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImage.frame) + 5, 0, 100, cellSize.height)];
                titleLabel.font = [UIFont systemFontOfSize:14.0];
                titleLabel.text = title;
                [cell addSubview:titleLabel];
                
                if (row - 1 == payType) {
                    CGFloat selectImageW = 25;
                    CGFloat selectImageH = 25;
                    CGFloat selectImageX = SCREENWIDTH - selectImageW - 10;
                    CGFloat selectImageY = (cellSize.height - selectImageH) / 2.0;
                    UIImageView *selectImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose_item_right"]];
                    selectImage.frame = CGRectMake(selectImageX, selectImageY, selectImageW, selectImageH);
                    [cell addSubview:selectImage];
                    
                }
            }
            break;
        }
        case 10:{
            //中国人寿
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.textLabel.text = nil;
            NSString *title = @"中国人寿保险";
            NSString *icon = @"icon_insurance";
            
            CGFloat iconImageX = 8;
            CGFloat iconImageH = 30;
            CGFloat iconImageW = 30;
            CGFloat iconImageY = (cellSize.height - iconImageH) / 2.0;
            
            UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(iconImageX, iconImageY, iconImageW, iconImageH)];
            iconImage.image = [UIImage imageNamed:icon];
            [cell addSubview:iconImage];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImage.frame) + 5, 0, 100, cellSize.height)];
            titleLabel.font = [UIFont systemFontOfSize:14.0];
            titleLabel.text = title;
            [cell addSubview:titleLabel];
            
            CGFloat endLabelY = 0;
            CGFloat endLabelW = 150;
            CGFloat endLabelH = cellSize.height;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 30;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            
            id orderSendSavemoney = orderDetailDict[@"orderSendSavemoney"];
            endLabel.text = [NSString stringWithFormat:@"￥%@",orderSendSavemoney];
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.textColor = [UIColor grayColor];
            [cell addSubview:endLabel];
            
            
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
        case 3:{
            return serviceBG.frame.size.height;
            break;
        }
        case 5:
        {
            if ([bannerImageDataSource count] == 0) {
                return 40;
            }
            return myScrollView.frame.size.height + 35;
            break;
        }
        default:
            break;
    }
    return 50;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (section) {
        case 0:
        {
            //服务时间
            NSDate *nowDate = [NSDate date];
            if (!([self.tmpDateString isMemberOfClass:[NSNull class]] || self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""])) {
                
                //设置转换格式
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                //NSString转NSDate
                nowDate = [formatter dateFromString:self.tmpDateString];
            }
            [self setupDateView:DateTypeOfStart minDate:nowDate];
            break;
        }
        case 1:{
            //受保护人
            HeSelectProtectedUserInfoVC *protectedUserInfoVC = [[HeSelectProtectedUserInfoVC alloc] init];
            protectedUserInfoVC.selectDelegate = self;
            protectedUserInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:protectedUserInfoVC animated:YES];
            return;
        }
        case 3:{
            //选择的护士套餐
            NSLog(@"选择的护士套餐");
            [self selectService];
            
            return;
        }
        case 6:{
            //优惠券
            NSLog(@"优惠券");
            HeUserCouponVC *userCouponVC = [[HeUserCouponVC alloc] init];
            userCouponVC.selectDelegate = self;
            userCouponVC.orderDict = [[NSDictionary alloc] initWithDictionary:orderDetailDict];
            userCouponVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userCouponVC animated:YES];
            return;
        }
        case 9:{
            //支付方式
            if (row == 0) {
                return;
            }
            payType = row - 1;
            [tableView reloadData];
        }
        case 10:{
            //中国人寿
            NSLog(@"中国人寿");
            return;
        }
        default:
            break;
    }
    NSLog(@"row = %ld, section = %ld",row,section);
}

- (void)getSelectDate:(NSString *)date type:(DateType)type {
    
    NSLog(@"时间 : %@",date);
    switch (type) {
        case DateTypeOfStart:
            // TODO 日期确定选择
            self.tmpDateString = date;
            [tableview reloadData];
            break;
            
        case DateTypeOfEnd:
            // TODO 日期取消选择
            break;
        default:
            break;
    }
}

- (void)setupDateView:(DateType)type minDate:(NSDate *)minDate{
    
    UWDatePickerView *pickerView = [UWDatePickerView instanceDatePickerView];
    pickerView.datePickerView.minimumDate = minDate;
    if (!minDate) {
        pickerView.datePickerView.minimumDate = [NSDate date];
    }
    NSDate *maxDate = [minDate dateByAddingTimeInterval:365 * 24 * 60 * 60];
    pickerView.datePickerView.maximumDate = maxDate;
    
    pickerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [pickerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    pickerView.delegate = self;
    pickerView.type = type;
    [self.view addSubview:pickerView];
    
}

- (void)handleSelectPhoto
{
    for (AsynImageView *imageview in bannerImageDataSource) {
        if (imageview.imageTag != -1) {
            [bannerImageDataSource removeObject:imageview];
        }
    }
    
    for (UIImage *image in _selectedPhotos) {
        AsynImageView *asyncImage = [[AsynImageView alloc] init];
        [asyncImage setImage:image];
        asyncImage.bigImageURL = nil;
        [bannerImageDataSource addObject:asyncImage];
        
    }
    [self updateImageBG];
}

#pragma mark -
#pragma mark ImagePicker method
//从相册中打开照片选择画面(图片库)：UIImagePickerControllerSourceTypePhotoLibrary
//启动摄像头打开照片摄影画面(照相机)：UIImagePickerControllerSourceTypeCamera

//按下相机触发事件
-(void)pickerCamer
{
    //照相机类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断属性值是否可用
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        //UIImagePickerController是UINavigationController的子类
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        //设置可以编辑
        imagePicker.allowsEditing = YES;
        if (!currentSelectBanner) {
            imagePicker.allowsEditing = NO;
        }
        //设置类型为照相机
        imagePicker.sourceType = sourceType;
        //进入照相机画面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}


- (void)mutiplepickPhotoSelect{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXUPLOADIMAGE delegate:self];
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    // Set the appearance
    // 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // Set allow picking video & photo & originalPhoto or not
    // 设置是否可以选择视频/图片/原图
    // imagePickerVc.allowPickingVideo = NO;
    // imagePickerVc.allowPickingImage = NO;
    // imagePickerVc.allowPickingOriginalPhoto = NO;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark TZImagePickerControllerDelegate



/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
}

/// User finish picking video,
/// 用户选择好了视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    [_selectedPhotos addObjectsFromArray:@[coverImage]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
    
    /*
     // open this code to send video / 打开这段代码发送视频
     [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
     // Export completed, send video here, send by outputPath or NSData
     // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
     
     }];
     */
    
}

//当按下相册按钮时触发事件
-(void)pickerPhotoLibrary
{
    //图片库类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *photoAlbumPicker = [[UIImagePickerController alloc]init];
    photoAlbumPicker.delegate = self;
    photoAlbumPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置可以编辑
    photoAlbumPicker.allowsEditing = YES;
    if (!currentSelectBanner) {
        photoAlbumPicker.allowsEditing = NO;
    }
    //设置类型
    photoAlbumPicker.sourceType = sourceType;
    //进入图片库画面
    [self presentViewController:photoAlbumPicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark imagePickerController method
//当拍完照或者选取好照片之后所要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (currentSelectBanner) {
        CGSize sizeImage = image.size;
        float a = [self getSize:sizeImage];
        if (a > 0) {
            CGSize size = CGSizeMake(sizeImage.width / a, sizeImage.height / a);
            image = [self scaleToSize:image size:size];
        }
        
        CGSize imagesize = image.size;
        CGFloat width = imagesize.width;
        CGFloat hight = imagesize.height;
        CGFloat sizewidth = width;
        if (hight < width) {
            sizewidth = hight;
        }
    }
    else{
        image = [self turnImageWithInfo:info];
    }
    
    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    
    UIImageJPEGRepresentation(image, 0.6);
    [asyncImage setImage:image];
    
    asyncImage.bigImageURL = nil;
    asyncImage.imageTag = -1; //表明是调用系统相机、相册的
    [bannerImageDataSource addObject:asyncImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateImageBG];
    }];
}

- (UIImage *)turnImageWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    //类型为 UIImagePickerControllerOriginalImage 时调整图片角度
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImageOrientation imageOrientation=image.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp) {
            // 原始图片可以根据照相时的角度来显示，但 UIImage无法判定，于是出现获取的图片会向左转90度的现象。
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return image;
    
}

-(float)getSize:(CGSize)size
{
    float a = size.width / 480.0;
    if (a > 1) {
        return a;
    }
    else
        return -1;
    
    
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
//相应取消动作
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissViewGes:(UITapGestureRecognizer *)ges
{
    
    UIView *mydismissView = ges.view;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    [alertview removeFromSuperview];
}

- (void)inputPayPassword
{
    [self.view addSubview:dismissView];
    dismissView.hidden = NO;
    
    NSDictionary *payInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPayInfoKey];
    NSString *password = [payInfo objectForKey:kPayPassword];
    if ([password isMemberOfClass:[NSNull class]] || password == nil || [password isEqualToString:@""]) {
        dismissView.hidden = YES;
        password = @"";
        HeSettingPayPasswordVC *settingPayVC = [[HeSettingPayPasswordVC alloc] init];
        settingPayVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:settingPayVC animated:YES];
        return;
    }
    CGFloat viewX = 10;
    CGFloat viewY = 50;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = 150;
    UIView *shareAlert = [[UIView alloc] init];
    shareAlert.frame = CGRectMake(viewX, viewY, viewW, viewH);
    shareAlert.backgroundColor = [UIColor whiteColor];
    shareAlert.layer.cornerRadius = 5.0;
    shareAlert.layer.borderWidth = 0;
    shareAlert.layer.masksToBounds = YES;
    shareAlert.tag = ALERTTAG;
    shareAlert.layer.borderColor = [UIColor clearColor].CGColor;
    shareAlert.userInteractionEnabled = YES;
    
    CGFloat labelH = 40;
    CGFloat labelY = 0;
    
    UIFont *shareFont = [UIFont systemFontOfSize:15.0];
    
    UILabel *messageTitleLabel = [[UILabel alloc] init];
    messageTitleLabel.font = shareFont;
    messageTitleLabel.textColor = [UIColor blackColor];
    messageTitleLabel.textAlignment = NSTextAlignmentCenter;
    messageTitleLabel.backgroundColor = [UIColor clearColor];
    messageTitleLabel.text = @"支付密码";
    messageTitleLabel.frame = CGRectMake(0, 0, viewW, labelH);
    [shareAlert addSubview:messageTitleLabel];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logoImage"]];
    logoImage.frame = CGRectMake(20, 5, 30, 30);
    [shareAlert addSubview:logoImage];
    
    
    labelY = labelY + labelH + 10;
    UITextField *textview = [[UITextField alloc] init];
    textview.tag = 10;
    textview.secureTextEntry = YES;
    textview.backgroundColor = [UIColor whiteColor];
    textview.tintColor= [UIColor blueColor];
    textview.placeholder = @"请输入6位数的密码";
    textview.font = shareFont;
    textview.delegate = self;
    textview.frame = CGRectMake(10, labelY, shareAlert.frame.size.width - 20, labelH);
    textview.layer.borderWidth = 1.0;
    textview.layer.cornerRadius = 5.0;
    textview.layer.masksToBounds = YES;
    textview.layer.borderColor = [UIColor colorWithWhite:0xcc / 255.0 alpha:1.0].CGColor;
    [shareAlert addSubview:textview];
    
    CGFloat buttonDis = 10;
    CGFloat buttonW = (viewW - 3 * buttonDis) / 2.0;
    CGFloat buttonH = 40;
    CGFloat buttonY = labelY = labelY + labelH + 10;
    CGFloat buttonX = 10;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [shareButton setTitle:@"确定" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tag = 1;
    [shareButton.titleLabel setFont:shareFont];
//    [shareButton setBackgroundColor:APPDEFAULTORANGE];
//    [shareButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:shareButton.frame.size] forState:UIControlStateHighlighted];
    [shareButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [shareAlert addSubview:shareButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX + buttonDis + buttonW, buttonY, buttonW, buttonH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 0;
    [cancelButton.titleLabel setFont:shareFont];
//    [cancelButton setBackgroundColor:APPDEFAULTORANGE];
//    [cancelButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:shareButton.frame.size] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [shareAlert addSubview:cancelButton];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [shareAlert.layer addAnimation:popAnimation forKey:nil];
    [self.view addSubview:shareAlert];
}

- (void)alertbuttonClick:(UIButton *)button
{
    UIView *mydismissView = dismissView;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    UIView *subview = [alertview viewWithTag:10];
    if (button.tag == 0) {
        [alertview removeFromSuperview];
        return;
    }
    UITextField *textview = nil;
    if ([subview isMemberOfClass:[UITextField class]]) {
        textview = (UITextField *)subview;
    }
    textview.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    NSString *password = textview.text;
    [alertview removeFromSuperview];
    if (password == nil || [password isEqualToString:@""]) {
        
        [self showHint:@"请输入6位数的密码"];
        return;
    }
    [self verifyPassword:password];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

//验证密码
- (void)verifyPassword:(NSString *)password
{
    [self showHudInView:self.tableview hint:@"验证密码中..."];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/nurseAnduser/UserPasswordVerification.action",BASEURL];
    NSDictionary *param = @{@"userId":userId,@"passWord":password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            //验证密码成功，发布
            [self showHudInView:self.tableview hint:@"支付中..."];
            [self performSelector:@selector(creatOrder) withObject:nil afterDelay:0.3];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)creatOrder
{
    if (payType == 1) {
        [self showHint:@"暂不支持支付宝支付"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/orderSend/UpdateIsPayState.action",BASEURL];
    id finalyMoney = orderDetailDict[@"orderSendTotalmoney"];
    if ([finalyMoney isMemberOfClass:[NSNull class]] || finalyMoney == nil) {
        finalyMoney = @"";
    }
    NSString *userCouponId = @"";
    NSDictionary *param = @{@"userId":userId,@"orderSendId":_orderId,@"finalyMoney":finalyMoney,@"userCouponId":userCouponId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            //验证密码成功，发布
            [self showHint:@"支付成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateOrder" object:nil];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.8];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (!textField.window.isKeyWindow) {
        [textField.window makeKeyAndVisible];
    }
}

#pragma mark - SelectProtectUserInfoProtocol
- (void)selectUserInfoWithDict:(NSDictionary *)userInfo
{
    //更新订单信息
    NSString *orderSendId = [NSString stringWithFormat:@"%@",_orderId];
    if ([orderSendId isMemberOfClass:[NSNull class]] || orderSendId == nil) {
        orderSendId = @"";
    }
    NSString *orderSendBegintime = @"";
    NSString *personId = userInfo[@"protectedPersonId"];
    if ([personId isMemberOfClass:[NSNull class]] || personId == nil) {
        personId = @"";
    }
    NSString *goodId = @"";
    NSString *orderSendTrafficmoney = orderDetailDict[@"orderSendTrafficmoney"];
    if ([orderSendTrafficmoney isMemberOfClass:[NSNull class]] || orderSendTrafficmoney == nil) {
        orderSendTrafficmoney = @"";
    }
    NSString *orderSendSavemoney = orderDetailDict[@"orderSendSavemoney"];
    if ([orderSendSavemoney isMemberOfClass:[NSNull class]] || orderSendSavemoney == nil) {
        orderSendSavemoney = @"";
    }
    NSDictionary *paramDict = @{@"orderSendId":orderSendId,@"orderSendBegintime":orderSendBegintime,@"personId":personId,@"goodId":goodId,@"orderSendTrafficmoney":orderSendTrafficmoney,@"orderSendSavemoney":orderSendSavemoney};
    [self updateOrderInfoWithParam:paramDict];
}

- (void)updateOrderInfoWithParam:(NSDictionary *)param
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/orderSend/updateOrderInfo.action",BASEURL];

    [self showHudInView:self.view hint:@"更新订单..."];
    __weak HeOrderCommitVC *weakSelf = self;
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [weakSelf loadOrderDetail];
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

- (void)loadOrderServiceArrayWithContentId:(NSString *)contentId
{
    NSDictionary *param = @{@"contentId":contentId};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/goods/selectgoodsbycoentid.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:param success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict objectForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]]) {
                return;
            }
            subServiceArray = [[NSArray alloc] initWithArray:jsonArray];
        }
        else{
            
        }
    } failure:^(NSError* err){
        NSLog(@"errorInfo = %@",err);
    }];
}

- (void)selectService
{
//    goodsId,goodsName
    NSString *orderSendServicecontent = orderDetailDict[@"orderSendServicecontent"];
    if ([orderSendServicecontent isMemberOfClass:[NSNull class]]) {
        orderSendServicecontent = @"";
    }
    NSArray *select_orderSendServicecontentArray = [orderSendServicecontent componentsSeparatedByString:@":"];
    @try {
        orderSendServicecontent = select_orderSendServicecontentArray[1];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSArray *select_serviceArray = [orderSendServicecontent componentsSeparatedByString:@","];
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dict in subServiceArray) {
        NSString *goodsName = dict[@"goodsName"];
        if ([goodsName isMemberOfClass:[NSNull class]] || goodsName == nil) {
            goodsName = @"";
        }
        [nameArray addObject:goodsName];
    }
    SSPopup* selection=[[SSPopup alloc]init];
    selection.selectArray = [[NSMutableArray alloc] initWithArray:select_serviceArray];
    selection.backgroundColor=[UIColor colorWithWhite:0.00 alpha:0.4];
    
    selection.frame = CGRectMake(0,0,SCREENWIDTH,self.view.frame.size.height);
    selection.SSPopupDelegate=self;
    [self.view  addSubview:selection];
    
    [selection CreateTableview:nameArray withSender:nil  withTitle:@"请选择套餐" setCompletionBlock:^(int tag){
        
        NSLog(@"Tag--->%d",tag);
        
        
    }];
    
}

- (void)selectWithArray:(NSArray *)array
{
    NSMutableString *goodsString = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < [array count]; index++) {
        NSString *myName = array[index];
        for (NSDictionary *dict in subServiceArray) {
            NSString *goodsName = dict[@"goodsName"];
            if ([goodsName isMemberOfClass:[NSNull class]] || goodsName == nil) {
                goodsName = @"";
            }
            if ([myName isEqualToString:goodsName]) {
                NSString *goodsId = dict[@"goodsId"];
                if ([goodsId isMemberOfClass:[NSNull class]] || goodsId == nil) {
                    goodsId = @"";
                }
                if (index == 0) {
                    [goodsString appendString:goodsId];
                }
                else{
                    [goodsString appendFormat:@",%@",goodsId];
                }
            }
        }
    }
    
    //更新订单信息
    NSString *orderSendId = [NSString stringWithFormat:@"%@",_orderId];
    if ([orderSendId isMemberOfClass:[NSNull class]] || orderSendId == nil) {
        orderSendId = @"";
    }
    NSString *orderSendBegintime = @"";
    NSString *personId = @"";
    if ([personId isMemberOfClass:[NSNull class]] || personId == nil) {
        personId = @"";
    }
    NSString *goodId = [NSString stringWithFormat:@"%@",goodsString];
    NSString *orderSendTrafficmoney = orderDetailDict[@"orderSendTrafficmoney"];
    if ([orderSendTrafficmoney isMemberOfClass:[NSNull class]] || orderSendTrafficmoney == nil) {
        orderSendTrafficmoney = @"";
    }
    NSString *orderSendSavemoney = orderDetailDict[@"orderSendSavemoney"];
    if ([orderSendSavemoney isMemberOfClass:[NSNull class]] || orderSendSavemoney == nil) {
        orderSendSavemoney = @"";
    }
    NSDictionary *paramDict = @{@"orderSendId":orderSendId,@"orderSendBegintime":orderSendBegintime,@"personId":personId,@"goodId":goodId,@"orderSendTrafficmoney":orderSendTrafficmoney,@"orderSendSavemoney":orderSendSavemoney};
    [self updateOrderInfoWithParam:paramDict];
    
}

- (void)selectCouponWithOrder:(NSDictionary *)myorderDict
{
    orderDetailDict = [[NSDictionary alloc] initWithDictionary:myorderDict];
    NSString *contentId = orderDetailDict[@"contentId"];
    if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
        contentId = @"";
    }
    [self loadOrderServiceArrayWithContentId:contentId];
    
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
    //所有数据重新刷新一次
    [self initializaiton];
    [self initView];
    
    bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *orderSendUserpic = orderDetailDict[@"orderSendUserpic"];
    if ([orderSendUserpic isMemberOfClass:[NSNull class]] || orderSendUserpic == nil) {
        orderSendUserpic = nil;
    }
    NSArray *orderSendUserpicArray = [orderSendUserpic componentsSeparatedByString:@","];
    for (NSString *url in orderSendUserpicArray) {
        NSString *myurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
        [bannerImageDataSource addObject:myurl];
    }
    [self updateImageBG];
    [tableview reloadData];
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
