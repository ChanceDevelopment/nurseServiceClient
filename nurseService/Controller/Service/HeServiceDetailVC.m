//
//  HeServiceDetailVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//  服务详情视图控制器

#import "HeServiceDetailVC.h"
#import "DLNavigationTabBar.h"
#import "HeBaseTableViewCell.h"
#import "LBBanner.h"
#import "MLLabel+Size.h"
#import "UWDatePickerView.h"
#import "HeProtectedUserInfoVC.h"
#import "DeleteImageProtocol.h"
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
#import "HeOrderCommitVC.h"
#import "HeSelectProtectedUserInfoVC.h"
#import "DVYearMonthDatePicker.h"

#define MAXUPLOADIMAGE 8
#define MAX_column  4
#define MAX_row 3
#define IMAGEWIDTH 70

#define ALERTTAG 500

@interface HeServiceDetailVC ()<DeleteImageProtocol,UITableViewDelegate,UITableViewDataSource,LBBannerDelegate,UIWebViewDelegate,UIAlertViewDelegate,UWDatePickerViewDelegate,SelectProtectUserInfoProtocol,TZImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,DVYearMonthDatePickerDelegate>
{
    BOOL currentSelectBanner;
    BOOL isBook;// YES:加入预约框 No:立即预约
    BOOL isHaveSomeProblem; //家中是否有小孩
    CGFloat currentTotalMoney;
}

@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
//列表视图
@property(strong,nonatomic)IBOutlet UITableView *tableview;
//底部的视图
@property(strong,nonatomic)IBOutlet UIView *footerBGView;
//最大的内容偏移
@property(assign,nonatomic)CGFloat maxContentOffSet_Y;
//内容的view
@property(strong,nonatomic)UIView *contentView;
//头部的信息
@property(strong,nonatomic)UILabel *headLab;
//显示服务详情的网页
@property(strong,nonatomic)UIWebView *webView;
//存放webview的view
@property(strong,nonatomic)UIView *webContentView;
//服务时间选择器
@property(strong,nonatomic)DVYearMonthDatePicker *yearMonth;

//服务时间
@property(strong,nonatomic)NSString *tmpDateString;

//选择服务类型的背景图
@property(strong,nonatomic)UIView *selectMenuBgView;

@property(strong,nonatomic)UIView *bannerImageBG;
@property(strong,nonatomic)NSMutableArray *bannerImageDataSource;
@property(strong,nonatomic)UIButton *addPictureButton;

@property(strong,nonatomic)NSMutableArray *selectedAssets;
@property(strong,nonatomic)NSMutableArray *selectedPhotos;
@property(strong,nonatomic)NSMutableArray *takePhotoArray;

@property(strong,nonatomic)id parameter;
@property(strong,nonatomic)NSDictionary *serviceInfoDict;
@property(strong,nonatomic)NSDictionary *serviceDetailInfoDict;

@property(strong,nonatomic)IBOutlet UIButton *collectButton;
//套餐
@property(strong,nonatomic)NSArray *subServiceArray;
@property(strong,nonatomic)NSMutableArray *subSelectArray;

@property(strong,nonatomic)UIView *dismissView;

@property(strong,nonatomic)NSString *remarKString;
@property(strong,nonatomic)NSMutableArray *remarKStringArray;

@end

@implementation HeServiceDetailVC
@synthesize tableview;
@synthesize footerBGView;
@synthesize bannerImageBG;
@synthesize bannerImageDataSource;
@synthesize addPictureButton;
@synthesize takePhotoArray;

@synthesize parameter;
@synthesize serviceInfoDict;
@synthesize serviceDetailInfoDict;

@synthesize collectButton;

@synthesize subServiceArray;
@synthesize subSelectArray;

@synthesize dismissView;
@synthesize remarKString;
@synthesize remarKStringArray;

@synthesize yearMonth;

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
        label.text = @"服务详情";
        [label sizeToFit];
        self.title = @"服务详情";
        
    }
    return self;
}

//顶部三大功能的选择
-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"服务内容",@"适用人群",@"注意事项"]];
        self.navigationTabBar.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        self.navigationTabBar.sliderBackgroundColor = APPDEFAULTORANGE;
        self.navigationTabBar.buttonNormalTitleColor = [UIColor grayColor];
        self.navigationTabBar.buttonSelectedTileColor = APPDEFAULTORANGE;
        __weak typeof(self) weakSelf = self;
        [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
            [weakSelf navigationDidSelectedControllerIndex:index];
        }];
    }
    return _navigationTabBar;
}

/*
 @brief 选择用户的信息之后回调回来的方法
 @param userInfo 用户的信息
 */
#pragma mark - SelectProtectUserInfoProtocol
- (void)selectUserInfoWithDict:(NSDictionary *)userInfo
{
    NSLog(@"selectUserInfo");
    NSLog(@"serviceDict = %@",serviceInfoDict);
    NSLog(@"serviceDetailInfoDict = %@",serviceDetailInfoDict);
    NSLog(@"userInfo = %@",userInfo);
    NSArray *allKeyArray = userInfo.allKeys;
    
    NSMutableDictionary *mutable_serviceInfoDict = [[NSMutableDictionary alloc] initWithDictionary:serviceInfoDict];
    NSMutableDictionary *mutable_serviceDetailInfoDict = [[NSMutableDictionary alloc] initWithDictionary:serviceDetailInfoDict];
    for (NSString *key in allKeyArray) {
        id obj = userInfo[key];
        if ([obj isMemberOfClass:[NSNull class]]) {
            obj = @"";
        }
        
        id obj1 = mutable_serviceInfoDict[key];
        id obj2 = mutable_serviceDetailInfoDict[key];
        if (obj1) {
            [mutable_serviceInfoDict setObject:obj forKey:key];
        }
        if (obj2) {
            [mutable_serviceDetailInfoDict setObject:obj forKey:key];
        }
    }
    serviceInfoDict = [[NSDictionary alloc] initWithDictionary:mutable_serviceInfoDict];
    serviceDetailInfoDict = [[NSDictionary alloc] initWithDictionary:mutable_serviceDetailInfoDict];
    [tableview reloadData];
}

#pragma mark - PrivateMethod
//选择顶部的tab之后的回调方法
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    NSString *contentId = serviceDetailInfoDict[@"contentId"];
    
    NSString *webViewUrl = @"http://www.hao123.com/?tn=29065018_265_hao_pg";
    switch (index) {
        case 0:
            //服务内容
            webViewUrl = [NSString stringWithFormat:@"%@nurseAnduser/contentPackaAge.action?contentId=%@",BASEURL,contentId];
            break;
        case 1:
            //使用人群
            webViewUrl = [NSString stringWithFormat:@"%@nurseAnduser/contentForPeopleInfo.action?contentId=%@",BASEURL,contentId];
            break;
        case 2:
            //注意事项
            webViewUrl = [NSString stringWithFormat:@"%@nurseAnduser/contentLook.action?contentId=%@",BASEURL,contentId];
            break;
        default:
            break;
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webViewUrl]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self initializaiton];
//    [self initView];
    tableview.hidden = YES;
    footerBGView.hidden = YES;
    [self initializaiton];
    //加载服务详情
    [self loadServiceDetail];
    //加载服务的子服务项目
    [self loadServiceArray];
}

//加载服务的子服务项目
- (void)loadServiceArray
{
    NSString *contentId = serviceInfoDict[@"contentId"];
    if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
        contentId = serviceInfoDict[@"manageNursingContentId"];
        if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
            contentId = @"";
        }
    }
    //contentId；服务的ID
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

//资源初始化
- (void)initializaiton
{
    [super initializaiton];
    serviceInfoDict = [parameter objectForKey:@"service"];
    currentTotalMoney = 0;
    subSelectArray = [[NSMutableArray alloc] initWithCapacity:0];
    remarKString = @"";
    remarKStringArray = [[NSMutableArray alloc] initWithCapacity:0];
}

//当选择下单的时候，弹框选择详情的下单参数
- (UIView *)selectMenuBgView
{
    if (!_selectMenuBgView) {
        CGFloat selectMenuBgViewX = 0;
        CGFloat selectMenuBgViewY = SCREENHEIGH - 64;
        CGFloat selectMenuBgViewW = SCREENWIDTH;
        CGFloat selectMenuBgViewH = 350;
        
        _selectMenuBgView = [[UIView alloc] initWithFrame:CGRectMake(selectMenuBgViewX, selectMenuBgViewY, selectMenuBgViewW, selectMenuBgViewH)];
        _selectMenuBgView.backgroundColor = [UIColor whiteColor];
        
        CGFloat commitButtonX = 0;
        CGFloat commitButtonW = SCREENWIDTH;
        CGFloat commitButtonH = 40;
        CGFloat commitButtonY = selectMenuBgViewH - commitButtonH;
        
        UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(commitButtonX, commitButtonY, commitButtonW, commitButtonH)];
        [commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
        [commitButton setTitle:@"下一步" forState:UIControlStateNormal];
        [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [commitButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_selectMenuBgView addSubview:commitButton];
        
        CGFloat serviceImageX = 20;
        CGFloat serviceImageY = -20;
        CGFloat serviceImageH = 80;
        CGFloat serviceImageW = 80;
        
        NSString *imgurls = [serviceDetailInfoDict objectForKey:@"imgurls"];
        NSArray *imgurlsArray = [imgurls componentsSeparatedByString:@","];
        NSString *imageUrl = imgurlsArray[0];
        imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,imageUrl];
        
        UIImageView *serviceImage = [[UIImageView alloc] initWithFrame:CGRectMake(serviceImageX, serviceImageY, serviceImageW, serviceImageH)];
        serviceImage.layer.cornerRadius = 5.0;
        serviceImage.layer.masksToBounds = YES;
        serviceImage.contentMode = UIViewContentModeScaleAspectFill;
        serviceImage.image = [UIImage imageNamed:@"index2"];
        [serviceImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"index2"]];
        [_selectMenuBgView addSubview:serviceImage];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 40, 20, 25, 25)];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectMenuBgView addSubview:closeButton];
        
        CGFloat priceLabelX = CGRectGetMaxX(serviceImage.frame) + 5;
        CGFloat priceLabelY = 5;
        CGFloat priceLabelW = 150;
        CGFloat priceLabelH = 20;
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:18.0];
        priceLabel.textColor = [UIColor redColor];
        priceLabel.tag = 1000;
        id serviceMoney = serviceDetailInfoDict[@"serviceMoney"];
        if ([serviceMoney isMemberOfClass:[NSNull class]]) {
            serviceMoney = @"";
        }
        priceLabel.text = [NSString stringWithFormat:@"￥%.2f",currentTotalMoney];
        priceLabel.backgroundColor = [UIColor clearColor];
        [_selectMenuBgView addSubview:priceLabel];
        
        CGFloat titleLabelX = priceLabelX;
        CGFloat titleLabelY = CGRectGetMaxY(priceLabel.frame);
        CGFloat titleLabelW = SCREENWIDTH - titleLabelX - 10;
        CGFloat titleLabelH = 30;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:18.0];
        titleLabel.textColor = [UIColor blackColor];
        
        NSString *serviceName = serviceDetailInfoDict[@"serviceName"];
        if ([serviceName isMemberOfClass:[NSNull class]]) {
            serviceName = @"";
        }
        titleLabel.text = serviceName;
        titleLabel.backgroundColor = [UIColor clearColor];
        [_selectMenuBgView addSubview:titleLabel];
        
        CGFloat lineX = 0;
        CGFloat lineY = 70;
        CGFloat lineW = SCREENWIDTH;
        CGFloat lineH = lineH;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, 1)];
        line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1];
        [_selectMenuBgView addSubview:line];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), SCREENWIDTH, selectMenuBgViewH - CGRectGetMaxY(line.frame) - 40)];
        [_selectMenuBgView addSubview:contentView];
        
        UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:contentView.bounds];
        contentScrollView.showsVerticalScrollIndicator = NO;
        contentScrollView.showsHorizontalScrollIndicator = NO;
        contentScrollView.delegate = nil;
        contentScrollView.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:contentScrollView];
 
//        NSMutableArray *serviceArray = [NSMutableArray alloc];
        
        CGFloat cellHeight = 35;
        CGFloat serviceItemViewX = 0;
        CGFloat serviceItemViewY = 0;
        CGFloat serviceItemViewW = SCREENWIDTH;
        CGFloat serviceItemViewH = cellHeight * [subServiceArray count] + 30;
        //套餐背景
        UIView *serviceItemView = [[UIView alloc] initWithFrame:CGRectMake(serviceItemViewX, serviceItemViewY, serviceItemViewW, serviceItemViewH)];
        [contentScrollView addSubview:serviceItemView];
        CGFloat titleLabelX1 = 10;
        CGFloat titleLabelY1 = 0;
        CGFloat titleLabelW1 = SCREENWIDTH - titleLabelX - 10;
        CGFloat titleLabelH1 = 30;
        
        UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX1, titleLabelY1, titleLabelW1, titleLabelH1)];
        titleLabel1.backgroundColor = [UIColor clearColor];
        titleLabel1.font = [UIFont systemFontOfSize:15.0];
        titleLabel1.textColor = [UIColor blackColor];
        titleLabel1.text = @"请选择项目详情";
        titleLabel1.backgroundColor = [UIColor clearColor];
        [serviceItemView addSubview:titleLabel1];
        
        //备注信息
        CGFloat remarkViewX = 10;
        CGFloat remarkViewY = CGRectGetMaxY(serviceItemView.frame);
        CGFloat remarkViewW = SCREENWIDTH;
        CGFloat remarkViewH = 80;
        
        UIScrollView *remarkView = [[UIScrollView alloc] initWithFrame:CGRectMake(remarkViewX, remarkViewY, remarkViewW, remarkViewH)];
        [contentScrollView addSubview:remarkView];
        
        CGFloat titleLabelX2 = 0;
        CGFloat titleLabelY2 = 0;
        CGFloat titleLabelW2 = 100;
        CGFloat titleLabelH2 = 30;
        
        UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX2, titleLabelY2, titleLabelW2, titleLabelH2)];
        titleLabel2.backgroundColor = [UIColor clearColor];
        titleLabel2.font = [UIFont systemFontOfSize:15.0];
        titleLabel2.textColor = [UIColor blackColor];
        titleLabel2.text = @"备注信息";
        titleLabel2.backgroundColor = [UIColor clearColor];
        [remarkView addSubview:titleLabel2];
        
        titleLabelX2 = CGRectGetMaxX(titleLabel2.frame);
        titleLabelW2 = SCREENWIDTH - 20 - titleLabelX2;
        UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX2, titleLabelY2, titleLabelW2, titleLabelH2)];
        tipLabel2.tag = 2400;
        tipLabel2.backgroundColor = [UIColor clearColor];
        tipLabel2.font = [UIFont systemFontOfSize:15.0];
        tipLabel2.textColor = [UIColor grayColor];
        tipLabel2.text = @"病史、禁忌、特殊说明";
//        tipLabel2.delegate = self;
        tipLabel2.textAlignment = NSTextAlignmentRight;
        tipLabel2.backgroundColor = [UIColor clearColor];
        [remarkView addSubview:tipLabel2];
        tipLabel2.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputReamrk)];
        [tipLabel2 addGestureRecognizer:tap];
        
        id firstService ;//= subServiceArray[0]
        @try {
            firstService = subServiceArray[0];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        NSString *contentNote = firstService[@"contentNote"];
        if ([contentNote isMemberOfClass:[NSNull class]] || contentNote == nil) {
            contentNote = @"";
        }
        
        NSArray *contentNoteArray = [contentNote componentsSeparatedByString:@","];
        
        UIImage *historySelectedImage = [UIImage imageNamed:@"icon_checkbox"];
        UIImage *historyImage = [UIImage imageNamed:@"icon_checkboxNormal"];
        CGFloat historyButtonX = 5;
        CGFloat historyButtonY = CGRectGetMaxY(titleLabel2.frame) + 2;
        CGFloat historyButtonH = 40;
        CGFloat historyButtonW = historySelectedImage.size.width / historySelectedImage.size.height * historyButtonH;
        
        CGFloat buttonDistacne = 8;
        for (NSInteger index = 0; index < [contentNoteArray count]; index++) {
            id note = contentNoteArray[index];
            if ([note isMemberOfClass:[NSNull class]] || note == nil) {
                note = @"";
            }
            historySelectedImage = [UIImage imageNamed:@"icon_checkbox"];
            historyImage = [UIImage imageNamed:@"icon_checkboxNormal"];
            
            UIButton *historyButton = [[UIButton alloc] initWithFrame:CGRectMake(historyButtonX, historyButtonY, historyButtonW, historyButtonH)];
            [historyButton setTitle:note forState:UIControlStateNormal];
            historyButton.tag = index;
            [historyButton setTitleColor:[UIColor colorWithWhite:100.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];

            [historyButton setBackgroundImage:historySelectedImage forState:UIControlStateSelected];
            [historyButton setBackgroundImage:historyImage forState:UIControlStateNormal];
            historyButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [historyButton addTarget:self action:@selector(historyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [remarkView addSubview:historyButton];
            
            historyButtonX = historyButtonX + historyButtonW + buttonDistacne;
            
            remarkView.contentSize = CGSizeMake(historyButtonX, 0);
        }

        //图片资料
        CGFloat pictureViewX = 5;
        CGFloat pictureViewY = CGRectGetMaxY(remarkView.frame);
        CGFloat pictureViewW = SCREENWIDTH - 2 * pictureViewX;
        CGFloat pictureViewH = 100;
        
        bannerImageBG = [[UIView alloc] initWithFrame:CGRectMake(pictureViewX, pictureViewY, pictureViewW, pictureViewH)];
        [contentScrollView addSubview:bannerImageBG];
        
        addPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 35, IMAGEWIDTH, IMAGEWIDTH)];
        [addPictureButton setBackgroundImage:[UIImage imageNamed:@"icon_add_photo"] forState:UIControlStateNormal];
        addPictureButton.tag = 100;
        [addPictureButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
        [bannerImageBG setBackgroundColor:[UIColor whiteColor]];
        [bannerImageBG addSubview:addPictureButton];
        bannerImageBG.userInteractionEnabled = YES;
        [contentScrollView addSubview:bannerImageBG];
        
        [self updateImageBG];
        
        CGFloat titleLabelX3 = 10;
        CGFloat titleLabelY3 = 0;
        CGFloat titleLabelW3 = 80;
        CGFloat titleLabelH3 = 30;
        
        UILabel *titleLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX3, titleLabelY3, titleLabelW3, titleLabelH3)];
        titleLabel3.backgroundColor = [UIColor clearColor];
        titleLabel3.font = [UIFont systemFontOfSize:15.0];
        titleLabel3.textColor = [UIColor blackColor];
        titleLabel3.text = @"图片资料";
        [bannerImageBG addSubview:titleLabel3];
        
        titleLabelX3 = CGRectGetMaxX(titleLabel3.frame);
        titleLabelW3 = SCREENWIDTH - 10 - titleLabelX3;
        UILabel *tipLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX3, titleLabelY3, titleLabelW3, titleLabelH3)];
        tipLabel3.backgroundColor = [UIColor clearColor];
        tipLabel3.font = [UIFont systemFontOfSize:13.0];
        tipLabel3.textColor = [UIColor grayColor];
        tipLabel3.text = @"可上传医嘱、处方单、注射单、伤口照片";
        tipLabel3.textAlignment = NSTextAlignmentRight;
        tipLabel3.backgroundColor = [UIColor clearColor];
        [bannerImageBG addSubview:tipLabel3];
        
        CGFloat contentHeight = CGRectGetMaxY(bannerImageBG.frame) + 10;
        contentScrollView.contentSize = CGSizeMake(0, contentHeight);
        
        
        lineY = CGRectGetMaxY(serviceItemView.frame);
        line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, 1)];
        line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [contentScrollView addSubview:line];
        
        lineY = CGRectGetMaxY(remarkView.frame);
        line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, 1)];
        line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [contentScrollView addSubview:line];
        
        CGFloat cellViewX = 0;
        CGFloat cellViewY = CGRectGetMaxY(titleLabel1.frame);
        CGFloat cellViewW = SCREENWIDTH;
        CGFloat cellViewH = cellHeight;
        
        
        for (NSInteger index = 0; index < [subServiceArray count]; index++) {
            
            NSDictionary *dict = subServiceArray[index];
            NSString *goodsName = dict[@"goodsName"];
            if ([dict isMemberOfClass:[NSNull class]]) {
                goodsName = @"";
            }
            NSString *title = goodsName;
            UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(cellViewX, cellViewY, cellViewW, cellViewH)];
            cellView.backgroundColor = [UIColor whiteColor];
            [serviceItemView addSubview:cellView];
            
            CGFloat selectButtonX = 10;
            CGFloat selectButtonW = 20;
            CGFloat selectButtonH = 20;
            CGFloat selectButtonY = (cellHeight - selectButtonH) / 2.0;
            
            UIButton *selectButton = [[UIButton alloc] initWithFrame:CGRectMake(selectButtonX, selectButtonY, selectButtonW, selectButtonH)];
            selectButton.tag = index;
            [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_agree"] forState:UIControlStateSelected];
            [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_unagree"] forState:UIControlStateNormal];
            [selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cellView addSubview:selectButton];
            
            CGFloat titleLabelX = CGRectGetMaxX(selectButton.frame) + 10;
            CGFloat titleLabelY = 0;
            CGFloat titleLabelW = 200;
            CGFloat titleLabelH = cellHeight;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
            titleLabel.font = [UIFont systemFontOfSize:15.0];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.text = title;
            titleLabel.backgroundColor = [UIColor clearColor];
            [cellView addSubview:titleLabel];
            
            CGFloat priceLabelW = 100;
            CGFloat priceLabelY = 0;
            CGFloat priceLabelH = cellHeight;
            CGFloat priceLabelX = SCREENWIDTH - 10 - priceLabelW;
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
            priceLabel.font = [UIFont systemFontOfSize:15.0];
            priceLabel.textColor = [UIColor blackColor];
            
            id goodsMoney = dict[@"goodsMoney"];
            if ([goodsMoney isMemberOfClass:[NSNull class]]) {
                goodsMoney = @"";
            }
            priceLabel.text = [NSString stringWithFormat:@"￥%@",goodsMoney];
            priceLabel.textAlignment = NSTextAlignmentRight;
            priceLabel.backgroundColor = [UIColor clearColor];
            [cellView addSubview:priceLabel];
            
            if (index + 1 < [subServiceArray count]) {
                CGFloat lineX = 10;
                CGFloat lineY = cellHeight - 1;
                CGFloat lineW = SCREENWIDTH - 2 * lineX;
                CGFloat lineH = 1;
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
                line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1];
                [cellView addSubview:line];
            }
            
            cellViewY = cellViewY + cellHeight;
            
            if ([subSelectArray count] == 0 && index == 0) {
                //默认选择第一个服务
                [self selectButtonClick:selectButton];
            }
        }
    
    }
    return _selectMenuBgView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

//初始化视图
- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Tool setExtraCellLineHidden:tableview];
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 60)];
    tipView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    NSString *tipString = @"继续拖动，查看图文详情";
    CGSize size = [MLLabel getViewSizeByString:tipString maxWidth:SCREENWIDTH font:[UIFont systemFontOfSize:13.0] lineHeight:1.2f lines:0];
    
    CGFloat tabFootLabH = 35;
    UILabel *tabFootLab = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - size.width) / 2.0, 0, size.width, tabFootLabH)];
    tabFootLab.text = tipString;
    tabFootLab.font = [UIFont systemFontOfSize:13.0];
    tabFootLab.textAlignment = NSTextAlignmentCenter;
    [tipView addSubview:tabFootLab];
    
    
    CGFloat lineH = 1;
    CGFloat lineW = CGRectGetMinX(tabFootLab.frame) - 10;
    CGFloat lineY = (tabFootLabH - lineH) / 2.0;
    CGFloat lineX = 5;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    line.backgroundColor = [UIColor grayColor];
    [tipView addSubview:line];
    
    lineX = CGRectGetMaxX(tabFootLab.frame) + 5;
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    line1.backgroundColor = [UIColor grayColor];
    [tipView addSubview:line1];
    
    
    tableview.tableFooterView = tipView;
    
    CGFloat headerHeight = 220;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    headerView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.tableHeaderView = headerView;
    
    CGFloat bannerHeight = 220;
    NSArray * imageNames = @[@"index1", @"index2"];
    LBBanner * banner = [[LBBanner alloc] initWithImageNames:imageNames andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
    banner.tag = 100;
    banner.delegate = self;
    
    [headerView addSubview:banner];
    
    [self loadContentView];
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
}

//选择相应的服务子项目回调
- (void)selectButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        NSDictionary *dict = subServiceArray[button.tag];
        id goodsMoney = dict[@"goodsMoney"];
        CGFloat goodsmoney = [goodsMoney floatValue];
        currentTotalMoney = currentTotalMoney + goodsmoney;
        
        [subSelectArray addObject:dict];
        
        
    }
    else{
        NSDictionary *dict = subServiceArray[button.tag];
        id goodsMoney = dict[@"goodsMoney"];
        CGFloat goodsmoney = [goodsMoney floatValue];
        currentTotalMoney = currentTotalMoney - goodsmoney;
        
        NSString *goodsId = dict[@"goodsId"];
        for (NSDictionary *selectDict in subSelectArray) {
            NSString *selecygoodsId = selectDict[@"goodsId"];
            if ([goodsId isEqualToString:selecygoodsId]) {
                [subSelectArray removeObject:selectDict];
                break;
            }
        }
    }
    UILabel *label = [_selectMenuBgView viewWithTag:1000];
    label.text = [NSString stringWithFormat:@"¥%.2f",currentTotalMoney];
    
    
    
}

//加载服务详情
- (void)loadServiceDetail
{
    [self showHudInView:self.view hint:@"加载中..."];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/service/selectservicebycontentid.action",BASEURL];
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *nurseid = @"";//为空，暂时不用
    NSString *contentId = serviceInfoDict[@"manageNursingContentId"];
    if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
        contentId = serviceInfoDict[@"contentId"];
        if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
            contentId = @"";
        }
    }
    
    NSDictionary * params  = @{@"nurseid":nurseid,@"userid":userid,@"contentId":contentId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            id jsonObj = respondDict[@"json"];
            if ([jsonObj isMemberOfClass:[NSNull class]] || jsonObj == nil) {
                return;
            }
            
            serviceDetailInfoDict = [[NSDictionary alloc] initWithDictionary:jsonObj];
            serviceInfoDict = [[NSDictionary alloc] initWithDictionary:jsonObj];
            tableview.hidden = NO;
            footerBGView.hidden = NO;
            [self initView];
            
            NSString *imgurls = serviceDetailInfoDict[@"imgurls"];
            if ([imgurls isMemberOfClass:[NSNull class]]) {
                imgurls = nil;
            }
            NSArray *imageArray = [imgurls componentsSeparatedByString:@","];
            NSMutableArray *imageUrlArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSString *tempRollPicUrl in imageArray) {
                NSString *rollPicUrl = tempRollPicUrl;
                if ([rollPicUrl isMemberOfClass:[NSNull class]] || rollPicUrl == nil) {
                    rollPicUrl = @"";
                }
                rollPicUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,rollPicUrl];
                [imageUrlArray addObject:rollPicUrl];
                
            }
            CGFloat bannerHeight = 220;
            LBBanner *banner1 = [tableview.tableHeaderView viewWithTag:100];
            LBBanner *banner = nil;
            if ([imageUrlArray count] == 0) {
                banner = [[LBBanner alloc] initWithImageNames:@[@"index2"] andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
            }
            else{
                banner = [[LBBanner alloc] initWithImageURLArray:imageUrlArray andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
            }
            banner.tag = 100;
            banner.delegate = self;
            [tableview.tableHeaderView addSubview:banner];
            [banner1 removeFromSuperview];
            
            id isfollow = serviceInfoDict[@"iscollect"];
            if ([isfollow isMemberOfClass:[NSNull class]]) {
                isfollow = @"";
            }
            if ([isfollow boolValue]) {
                collectButton.selected = YES;
                [collectButton setTitle:@"已收藏" forState:UIControlStateNormal];
                [collectButton setImage:[UIImage imageNamed:@"icon_favorites_gray_modify"] forState:UIControlStateNormal];
//                collectButton.enabled = NO;
                
            }
            else{
                collectButton.enabled = YES;
                [collectButton setTitle:@"收藏" forState:UIControlStateNormal];
                [collectButton setImage:[UIImage imageNamed:@"icon_favorites_gray"] forState:UIControlStateNormal];
                collectButton.selected = NO;
            }
            
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
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

//加载网页的详情
- (void)loadContentView
{
    // first view
    self.contentView = self.view;
    
    // second view
    [self.contentView addSubview:self.webContentView];
    [_webContentView addSubview:self.navigationTabBar];
    [_webContentView addSubview:self.webView];
    
    UILabel *headLabel = self.headLab;
    // headLab
    [self.webView addSubview:headLabel];
//    [self.headLab bringSubviewToFront:self.contentView];
    
    [_webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    _maxContentOffSet_Y = 90;
}

- (UILabel *)headLab
{
    if(!_headLab){
        _headLab = [[UILabel alloc] init];
        _headLab.text = @"上拉，返回详情";
        _headLab.textAlignment = NSTextAlignmentCenter;
        _headLab.font = [UIFont systemFontOfSize:13];
        
    }
    
    _headLab.frame = CGRectMake(0, 0, SCREENWIDTH, 40.f);
    _headLab.alpha = 0.f;
    _headLab.textColor = [UIColor grayColor];
    
    
    return _headLab;
}

- (UIWebView *)webView
{
    CGFloat height = CGRectGetHeight(_webContentView.frame) - CGRectGetHeight(_navigationTabBar.frame);
    CGFloat webviewY = CGRectGetMaxY(_navigationTabBar.frame);
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, webviewY, SCREENWIDTH, height)];
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        
        NSString *contentId = serviceInfoDict[@"contentId"];
        if (contentId == nil) {
            contentId = serviceInfoDict[@"manageNursingContentId"];
        }
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@nurseAnduser/contentPackaAge.action?contentId=%@",BASEURL,contentId]]]];
    }
    
    return _webView;
}

- (UIView *)webContentView
{
    CGFloat height = tableview.contentSize.height;
    if (height < SCREENHEIGH) {
        height = SCREENHEIGH;
    }
    
    if (!_webContentView) {
        _webContentView = [[UIView alloc] initWithFrame:CGRectMake(0, height, SCREENWIDTH, SCREENHEIGH)];
        _webContentView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [_webContentView addSubview:_navigationTabBar];
    }
    return _webContentView;
}

#pragma mark ---- scrollView delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if([scrollView isKindOfClass:[UITableView class]]) // tableView界面上的滚动
    {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
        CGFloat valueNum = tableview.contentSize.height - SCREENHEIGH;
        if ((offsetY - valueNum) > _maxContentOffSet_Y)
        {
            [self goToDetailAnimation]; // 进入图文详情的动画
        }
    }
    
    else // webView页面上的滚动
    {
        NSLog(@"-----webView-------");
        if(offsetY<0 && -offsetY>_maxContentOffSet_Y)
        {
            [self backToFirstPageAnimation]; // 返回基本详情界面的动画
        }
    }
}
//加载历史信息按钮点击事件
- (void)historyButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    id firstService = subServiceArray[0];
    @try {
        firstService = subServiceArray[0];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    NSString *contentNote = firstService[@"contentNote"];
    NSArray *contentNoteArray = [contentNote componentsSeparatedByString:@","];
    
    if ([contentNote isMemberOfClass:[NSNull class]] || contentNote == nil) {
        contentNote = @"";
    }
    
    if (button.selected) {
        [remarKStringArray addObject:[NSString stringWithFormat:@"%ld",button.tag]];
    }
    else{
        for (NSInteger index = 0; index < [remarKStringArray count]; index++) {
            id obj = remarKStringArray[index];
            if ([obj integerValue] == button.tag) {
                [remarKStringArray removeObject:obj];
                break;
            }
        }
    }
    
    
    NSMutableString *tempString = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < [remarKStringArray count]; index++) {
        NSString *indexObj = remarKStringArray[index];
        NSInteger myindex = [indexObj integerValue];
        id obj = contentNoteArray[myindex];
        if (index == 0) {
            [tempString appendString:obj];
        }
        else{
            [tempString appendFormat:@",%@",obj];
        }
    }
    remarKString = [NSString stringWithFormat:@"%@",tempString];
    NSLog(@"remarKString = %@",remarKString);
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:remarKString forKey:kRemarKString];
}

// 进入详情的动画
- (void)goToDetailAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH);
        tableview.frame = CGRectMake(0, -self.contentView.bounds.size.height, SCREENWIDTH, self.contentView.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.view addSubview:footerBGView];
    }];
}


// 返回第一个界面的动画
- (void)backToFirstPageAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        tableview.frame = CGRectMake(0, 0, SCREENWIDTH, self.contentView.bounds.size.height);
        
        CGFloat height = tableview.contentSize.height;
        if (height < SCREENHEIGH) {
            height = SCREENHEIGH;
        }
        
        _webContentView.frame = CGRectMake(0, height, SCREENWIDTH, SCREENHEIGH);
        
    } completion:^(BOOL finished) {
        [self.view addSubview:footerBGView];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
        NSLog(@"----old:%@----new:%@",change[@"old"],change[@"new"]);
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    _headLab.alpha = -offsetY / 60;
    _headLab.center = CGPointMake(SCREENWIDTH / 2, -offsetY / 2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY>_maxContentOffSet_Y){
        _headLab.textColor = [UIColor redColor];
        _headLab.text = @"释放，返回详情";
    }else{
        _headLab.textColor = [UIColor grayColor];
        _headLab.text = @"上拉，返回详情";
    }
}

//打电话点击事件
- (IBAction)phoneCall:(id)sender
{
    NSLog(@"phoneCall");
    NSString *phoneString = @"15768580734";
    NSString *message = [NSString stringWithFormat:@"确定拨打: %@",phoneString];
    
    if (iOS7) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        alertview.tag = 1;
        [alertview show];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:phoneString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [Tool callPhoneWithPhone:phoneString];
    }];
    [alertController addAction:callAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        NSString *phoneString = @"15768580734";
        [Tool callPhoneWithPhone:phoneString];
    }
}


//收藏关注的方法
- (IBAction)favButtonClick:(UIButton *)sender
{
    id isfollow = serviceDetailInfoDict[@"iscollect"];
    if ([isfollow isMemberOfClass:[NSNull class]]) {
        isfollow = @"";
    }
    if ([isfollow boolValue]) {
        return;
    }
    
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/follow/addcollects.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    //contentId：收藏关注的ID
    NSString *contentId = serviceDetailInfoDict[@"contentId"];
    if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
        contentId = serviceDetailInfoDict[@"manageNursingContentId"];
        if ([contentId isMemberOfClass:[NSNull class]] || contentId == nil) {
            contentId = @"";
        }
    }
    [self showHudInView:tableview hint:@"正在收藏，请稍候..."];
    NSDictionary * params  = @{@"userId":userId,@"contentId":contentId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:serviceDetailInfoDict];
            [dict setObject:@YES forKey:@"iscollect"];
            serviceDetailInfoDict = [[NSDictionary alloc] initWithDictionary:dict];
            serviceInfoDict = [[NSDictionary alloc] initWithDictionary:dict];
            
            id isfollow = serviceInfoDict[@"iscollect"];
            if ([isfollow isMemberOfClass:[NSNull class]]) {
                isfollow = @"";
            }
            if ([isfollow boolValue]) {
                sender.selected = YES;
                [sender setTitle:@"已收藏" forState:UIControlStateNormal];
                [sender setImage:[UIImage imageNamed:@"icon_favorites_gray_modify"] forState:UIControlStateNormal];
//                sender.enabled = NO;
            }
            else{
                sender.enabled = YES;
                sender.selected = NO;
            }
            [self showHint:@"收藏成功"];
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
//加入预约框
- (IBAction)addToBookItem:(id)sender
{
    if (self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""]) {
        [self showHint:@"请选择服务时间"];
        return;
    }
    NSLog(@"addToBookItem");
    //加入预约框
    isBook = YES;
    [self.view addSubview:self.selectMenuBgView];
    _selectMenuBgView.hidden = NO;
    [self setInfoViewisDown:NO withView:_selectMenuBgView];
}
//立即预约
- (IBAction)bookService:(UIButton *)sender
{
    if (self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""]) {
        [self showHint:@"请选择服务时间"];
        return;
    }
    if (subServiceArray.count == 0) {
        [self showHint:@"暂无服务类产品"];
        return;
    }
    //
    NSLog(@"serviceDetailInfoDict");
    //立即预约
    isBook = NO;
    [self.view addSubview:self.selectMenuBgView];
    _selectMenuBgView.hidden = NO;
    [self setInfoViewisDown:NO withView:_selectMenuBgView];
    
}

//提交按钮的点击事件
- (void)commitButtonClick:(UIButton *)button
{
    NSLog(@"commitButtonClick");
    if (self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""]) {
        [self showHint:@"请选择服务时间"];
        return;
    }
    if ([subSelectArray count] == 0) {
        [self showHint:@"请选择相应套餐"];
        return;
    }
    _selectMenuBgView.hidden = YES;
    [self setInfoViewisDown:YES withView:_selectMenuBgView];
    
    
    NSDictionary *nurseDict = parameter[@"nurse"];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *specifyNurseId = nurseDict[@"nurseId"];
    if ([specifyNurseId isMemberOfClass:[NSNull class]] || specifyNurseId == nil) {
        //可以不用指定某个护士
        specifyNurseId = @"";
    }
    NSMutableString *goodId = [[NSMutableString alloc] initWithCapacity:0];
    NSInteger index = 0;
    for (NSDictionary *dict in subSelectArray) {
        NSString *tempgoodsId = dict[@"goodsId"];
        if (index == 0) {
            [goodId appendString:tempgoodsId];
        }
        else {
            [goodId appendFormat:@",%@",tempgoodsId];
        }
        index++;
    }
    NSString *personId = serviceDetailInfoDict[@"protectedPersonId"];
    if ([personId isMemberOfClass:[NSNull class]] || personId == nil || [personId isEqualToString:@""]) {
        [self showHint:@"请选择或者新增被护人信息"];
        return;
    }
    
    NSMutableString *orderSendUserpic = [[NSMutableString alloc] initWithCapacity:0];
    
    //赛区宣传图
    for (NSInteger index = 0; index < self.bannerImageDataSource.count; index++) {
        AsynImageView *imageview = self.bannerImageDataSource[index];
        
        UIImage *imageData = imageview.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.1);
        NSData *base64Data = [GTMBase64 encodeData:data];
        NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        if (index == 0) {
            [orderSendUserpic appendString:base64String];
        }
        else {
            [orderSendUserpic appendFormat:@",%@",base64String];
        }
    }
    UILabel *field = (UILabel *)[_selectMenuBgView viewWithTag:2400];
    NSString *mark = field.text;
    NSString *orderSendNote	= [NSString stringWithFormat:@"%@",remarKString];
    
    if (![mark isEqualToString:@""] && mark != nil) {
        orderSendNote = [NSString stringWithFormat:@"%@,%@",mark,orderSendNote];
    }
    NSString *orderSendCoupon = @"";
    NSString *orderSendTrafficmoney	= serviceDetailInfoDict[@"trafficCost"];
    if ([orderSendTrafficmoney isMemberOfClass:[NSNull class]] || orderSendTrafficmoney == nil) {
        orderSendTrafficmoney = @"";
    }
    NSString *orderSendSavemoney = serviceDetailInfoDict[@"saveCost"];
    if ([orderSendSavemoney isMemberOfClass:[NSNull class]] || orderSendSavemoney == nil) {
        orderSendSavemoney = @"";
    }
    NSString *orderSendIspayment = @"0";
    NSString *orderSendIssafe = @"1";
    long long timeSp = [Tool convertStringToTimesp:self.tmpDateString dateFormate:@"yyyy-MM-dd HH:mm"];
    NSString *orderSendBegintime = [NSString stringWithFormat:@"%lld",timeSp];
    if (orderSendBegintime.length < 13) {
        NSInteger length = 13 - orderSendBegintime.length;
        for (NSInteger index = 0; index < length; index++) {
            orderSendBegintime = [NSString stringWithFormat:@"%@0",orderSendBegintime];
        }
    }
    //specifyNurseId:护士的ID
    //goodId 服务项目的ID
    //personId 受护人的ID
    //orderSendUserpic 上传的图片
    //orderSendNote 备注
    //orderSendCoupon 优惠券
    //orderSendTrafficmoney 运费
    //orderSendBegintime 开始时间
    //orderSendStoptime 结束时间
    NSString *orderSendStoptime = @"";
    NSDictionary *paramsDict = @{
                                 @"userId":userId,
                                 @"specifyNurseId":specifyNurseId,
                                 @"goodId":goodId,
                                 @"personId":personId,
                                 @"orderSendUserpic":orderSendUserpic,
                                 @"orderSendNote":remarKString,
                                 @"orderSendCoupon":orderSendCoupon,
                                 @"orderSendTrafficmoney":orderSendTrafficmoney,
                                 @"orderSendSavemoney":orderSendSavemoney,
                                 @"orderSendIspayment":orderSendIspayment,
                                 @"orderSendIssafe":orderSendIssafe,
                                 @"orderSendBegintime":orderSendBegintime,
                                 @"orderSendStoptime":orderSendStoptime
                                 };
    
    //发出网络请求
    NSString *requestUrl = [NSString stringWithFormat:@"%@orderSend/orderSend.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:paramsDict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"成功加入!";
            }
            NSString *orderId = [respondDict objectForKey:@"json"];
            if (!isBook) {
                
                //如果不是来自于预订界面，跳到订单确认界面
                HeOrderCommitVC *commitVC = [[HeOrderCommitVC alloc] init];
                commitVC.orderId = orderId;
                commitVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:commitVC animated:YES];
                return;
            }
            [self showHint:data];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOrderNotification object:nil];
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

- (void)closeButtonClick:(UIButton *)sender
{
    _selectMenuBgView.hidden = YES;
    [self setInfoViewisDown:YES withView:_selectMenuBgView];
}

/*
 @brief 弹出弹下的动画
 @param isDown 是否弹下
 @param infoView 目标视图
 */
- (void)setInfoViewisDown:(BOOL)isDown withView:(UIView *)infoView{
    CGFloat infoViewHeight = CGRectGetHeight(infoView.frame);
    CGFloat infoViewWidth = CGRectGetWidth(infoView.frame);
    CGFloat infoViewX = CGRectGetMinX(infoView.frame);
    CGFloat infoViewY = CGRectGetMinY(infoView.frame);
    
    if(isDown == NO)
    {
        //底部弹出
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             [infoView setFrame:CGRectMake(infoViewX, SCREENHEIGH - 64, SCREENWIDTH, infoViewHeight)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  [infoView setFrame:CGRectMake(infoViewX, SCREENHEIGH - infoViewHeight - 64, SCREENWIDTH, infoViewHeight)];
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
        
    }else
    {
        //弹回
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             [infoView setFrame:CGRectMake(infoViewX, infoViewY, infoViewWidth, infoViewHeight)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  [infoView setFrame:CGRectMake(infoViewX, SCREENHEIGH - 64 ,infoViewWidth, infoViewHeight)];
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    }
}

//顶部轮播的回调
#pragma mark LBBannerDelegate
- (void)banner:(LBBanner *)banner didClickViewWithIndex:(NSInteger)index {
    NSLog(@"didClickViewWithIndex:%ld", index);
}

- (void)banner:(LBBanner *)banner didChangeViewWithIndex:(NSInteger)index {
    NSLog(@"didChangeViewWithIndex:%ld", index);
}

//视图列表的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    static NSString *cellIndentifier = @"HeInfoTableViewCell";
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        
    }
    NSDictionary *dict = nil;
    switch (section) {
        case 0:
        {
            CGFloat titleLabelX = 10;
            CGFloat titleLabelY = 0;
            CGFloat titleLabelH = cellsize.height;
            CGFloat titleLabelW = cellsize.width / 2.0 - titleLabelX;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
            titleLabel.font = [UIFont systemFontOfSize:18.0];
            NSString *serviceName = serviceDetailInfoDict[@"serviceName"];
            if ([serviceName isMemberOfClass:[NSNull class]] || serviceName == nil) {
                serviceName = @"";
            }
            titleLabel.text = serviceName;
            [cell addSubview:titleLabel];
            
            
            CGFloat endLabelY = 0;
            CGFloat endLabelH = cellsize.height;
            CGFloat endLabelX = cellsize.width / 2.0;
            CGFloat endLabelW = cellsize.width - endLabelX - 10;
            
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            endLabel.textColor = [UIColor redColor];
            endLabel.textAlignment = NSTextAlignmentRight;
            id serviceMoney = serviceDetailInfoDict[@"serviceMoney"];
            if ([serviceMoney isMemberOfClass:[NSNull class]]) {
                serviceMoney = @"";
            }
            endLabel.text = [NSString stringWithFormat:@"￥%@起",serviceMoney];
            [cell addSubview:endLabel];
            
            break;
        }
        case 1:{
            switch (row) {
                case 0:
                {
                    //服务时间
                    cell.textLabel.text = @"服务时间";
                    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    CGFloat endLabelY = 0;
                    CGFloat endLabelW = 150;
                    CGFloat endLabelH = cellsize.height;
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
                    
                    CGFloat titleLabelX = 10;
                    CGFloat titleLabelY = 0;
                    CGFloat titleLabelH = cellsize.height / 2.0;
                    NSString *protectedPersonName = serviceDetailInfoDict[@"protectedPersonName"];
                    if ([protectedPersonName isMemberOfClass:[NSNull class]] || protectedPersonName == nil) {
                        titleLabelH = cellsize.height;
                    }
                    
                    CGFloat titleLabelW = 100;
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.text = @"受护人信息";
                    [cell addSubview:titleLabel];
                    
                    NSString *infoString = @"小明 男 15768580734";
                    CGSize size = [MLLabel getViewSizeByString:infoString maxWidth:SCREENWIDTH - 30 - titleLabelW font:[UIFont systemFontOfSize:15.0] lineHeight:1.2 lines:0];
                    titleLabelW = size.width;
                    titleLabelX = SCREENWIDTH - titleLabelW - 30;
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    nameLabel.textAlignment = NSTextAlignmentRight;
                    nameLabel.font = [UIFont systemFontOfSize:15.0];
                    
                    if ([protectedPersonName isMemberOfClass:[NSNull class]] || protectedPersonName == nil) {
                        protectedPersonName = @"暂无受护人信息";
                        nameLabel.text = protectedPersonName;
                        nameLabel.textColor = [UIColor  grayColor];
                        [cell addSubview:nameLabel];
                        break;
                    }
                    
                    id protectedPersonSex = serviceDetailInfoDict[@"protectedPersonSex"];
                    if ([protectedPersonSex isMemberOfClass:[NSNull class]]) {
                        protectedPersonSex = @" ";
                    }
                    
                    NSString *sexStr = @"女";
                    if ([protectedPersonSex integerValue] == ENUM_SEX_Boy) {
                        sexStr = @"男";
                    }
                    id protectedPersonAge = serviceDetailInfoDict[@"protectedPersonAge"];
                    NSLog(@"%@",protectedPersonAge);
                    if ([protectedPersonAge isMemberOfClass:[NSNull class]]) {
                        protectedPersonAge = @"";
                    }
                    NSLog(@"%@",protectedPersonAge);
                    nameLabel.text = [NSString stringWithFormat:@"%@  %@  %@",protectedPersonName,sexStr,protectedPersonAge];
                    
                    nameLabel.textColor = [UIColor  grayColor];
                    [cell addSubview:nameLabel];
                    
                    titleLabelX = 10;
                    titleLabelW = SCREENWIDTH - titleLabelX - 30;
                    titleLabelY = CGRectGetMaxY(nameLabel.frame);
                    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    addressLabel.textAlignment = NSTextAlignmentRight;
                    addressLabel.font = [UIFont systemFontOfSize:15.0];
                    addressLabel.textColor = [UIColor  grayColor];
                    
                    NSString *protectedAddress = serviceDetailInfoDict[@"protectedAddress"];
                    if ([protectedAddress isMemberOfClass:[NSNull class]]) {
                        protectedAddress = @"";
                    }
                    addressLabel.text = protectedAddress;
                    [cell addSubview:addressLabel];
                    
                    break;
                }
                case 2:
                {
                    UIImage *image_picc = [UIImage imageNamed:@"icon_picc"];
                    CGFloat imageViewX = 5;
                    CGFloat imageViewY = 15;
                    CGFloat imageViewH = cellsize.height - 2 * imageViewY;
                    CGFloat imageViewW = imageViewH / image_picc.size.height * image_picc.size.width;
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_picc"]];
                    imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
                    [cell addSubview:imageView];
                    
                    CGFloat titleLabelX = CGRectGetMaxX(imageView.frame) + 5;
                    CGFloat titleLabelY = 0;
                    CGFloat titleLabelH = cellsize.height;
                    CGFloat titleLabelW = 150;
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    titleLabel.textColor = [UIColor grayColor];
                    titleLabel.font = [UIFont systemFontOfSize:13.0];
                    
                    NSString *saveInfo = serviceDetailInfoDict[@"saveInfo"];
                    if ([saveInfo isMemberOfClass:[NSNull class]] || saveInfo == nil) {
                        saveInfo = @"";
                    }
                    titleLabel.text = saveInfo;
                    [cell addSubview:titleLabel];
                    
                    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_question"]];
                    icon.frame = CGRectMake(SCREENWIDTH - 20 - 10, (cellsize.height - 20) / 2.0, 20, 20);
                    [cell addSubview:icon];
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && (row == 2 || row == 1)) {
        if (row == 1) {
            NSString *protectedPersonName = serviceDetailInfoDict[@"protectedPersonName"];
            if ([protectedPersonName isMemberOfClass:[NSNull class]] || protectedPersonName == nil) {
                return 44;
            }
        }
        return 80;
    }
    return 44;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:{
            
            switch (row) {
                case 0:
                {
                    //服务项目
                    break;
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
                    //服务时间
                    [self selectDate];
//                    NSDate *nowDate = [NSDate date];
//                    if (!([self.tmpDateString isMemberOfClass:[NSNull class]] || self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""])) {
//                        
//                        //设置转换格式
//                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
//                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//                        //NSString转NSDate
//                        nowDate = [formatter dateFromString:self.tmpDateString];
//                    }
//                    [self setupDateView:DateTypeOfStart minDate:nowDate];
                    break;
                }
                case 1:{
                    //被受保护人信息
                    NSLog(@"被受保护人信息");
                    HeProtectedUserInfoVC *protectedUserInfoVC = [[HeProtectedUserInfoVC alloc] init];
                    protectedUserInfoVC.selectDelegate = self;
                    protectedUserInfoVC.hidesBottomBarWhenPushed = YES;
                    protectedUserInfoVC.isFromOrder = YES;
                    [self.navigationController pushViewController:protectedUserInfoVC animated:YES];
                    
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
}

//选择设置服务时间
- (void)selectDate
{
    UIView *myview = [self.view viewWithTag:1000];
    if (myview) {
        myview.hidden = NO;
        [self.view viewWithTag:2000].hidden = NO;
        return;
    }
    UIView *bgView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH)];
    bgView1.tag = 1000;
    bgView1.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:bgView1];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGH - 64 - 240, SCREENWIDTH, 240)];
    bgView.tag = 2000;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMyView:)];
    [bgView1 addGestureRecognizer:tap];
    
    yearMonth = [[DVYearMonthDatePicker alloc] initWithFrame:CGRectMake(0, 50, SCREENWIDTH, 200)];
    
    yearMonth.dvDelegate = self;
    
    [yearMonth selectToday];
    
    UIView *buttonBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 50, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [cancelButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [buttonBGView addSubview:cancelButton];
    cancelButton.tag = 1;
    [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 50 - 5, 0, 50, 40)];
    [commitButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [commitButton setTitle:@"确定" forState:UIControlStateNormal];
    [commitButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    commitButton.tag = 2;
    [buttonBGView addSubview:commitButton];
    [commitButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:yearMonth];
    [bgView addSubview:buttonBGView];
}

- (void)dismissMyView:(UITapGestureRecognizer *)tap
{
    UIView *myview = [self.view viewWithTag:1000];
    myview.hidden = YES;
    [self.view viewWithTag:2000].hidden = YES;
}

//选择时间确认
- (void)buttonClick:(UIButton *)button
{
    UIView *myview = [self.view viewWithTag:1000];
    myview.hidden = YES;
    [self.view viewWithTag:2000].hidden = YES;
    
    if (button.tag == 2) {
        NSString *tempString = self.yearMonth.dateStr;
        NSLog(@"tempString = %@",tempString);
        tempString = [tempString stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
        tempString = [tempString stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
        tempString = [tempString stringByReplacingOccurrencesOfString:@"日" withString:@""];
        self.tmpDateString = tempString;
        [tableview reloadData];
    }
}

/*
 获取选择时间的内容
 @param date 时间的字符串
 @param type类型 DateTypeOfStart：日期确定选择
                  DateTypeOfEnd：日期取消选择
 */
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

//设置时间
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

//选择图片之后，更新视图
- (void)updateImageBG
{
    for (UIView *subview in bannerImageBG.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            continue;
        }
        [subview removeFromSuperview];
    }
    CGFloat buttonH = IMAGEWIDTH;
    CGFloat buttonW = IMAGEWIDTH;
    
    CGFloat buttonHDis = (SCREENWIDTH - 20 - MAX_column * buttonW) / (MAX_column - 1);
    CGFloat buttonVDis = 10;
    
    int row = [Tool getRowNumWithTotalNum:[bannerImageDataSource count]];
    int column = [Tool getColumnNumWithTotalNum:[bannerImageDataSource count]];
    
    for (int i = 0; i < row; i++) {
        if ((i + 1) * MAX_column <= [bannerImageDataSource count]) {
            column = MAX_column;
        }
        else{
            column = [bannerImageDataSource count] % MAX_column;
        }
        for (int j = 0; j < column; j++) {
            
            CGFloat buttonX = (buttonW + buttonHDis) * j;
            CGFloat buttonY = (buttonH + buttonVDis) * i + 35;
            
            NSInteger picIndex = i * MAX_column + j;
            AsynImageView *asynImage = [bannerImageDataSource objectAtIndex:picIndex];
            asynImage.tag = picIndex;
            asynImage.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            asynImage.layer.borderColor = [UIColor clearColor].CGColor;
            asynImage.layer.borderWidth = 0;
            asynImage.layer.masksToBounds = YES;
            asynImage.contentMode = UIViewContentModeScaleAspectFill;
            asynImage.userInteractionEnabled = YES;
            [bannerImageBG addSubview:asynImage];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
            tapGes.numberOfTapsRequired = 1;
            tapGes.numberOfTouchesRequired = 1;
            [asynImage addGestureRecognizer:tapGes];
        }
    }
    if ([bannerImageDataSource count] < MAXUPLOADIMAGE) {
        
        NSInteger last_i = -1;
        NSInteger last_j = -1;
        row = [Tool getRowNumWithTotalNum:[bannerImageDataSource count] + 1];
        for (int i = 0; i < row; i++) {
            if ((i + 1) * MAX_column <= [bannerImageDataSource count] + 1) {
                column = MAX_column;
            }
            else{
                column = ([bannerImageDataSource count] + 1) % MAX_column;
            }
            last_i = i;
            for (int j = 0; j < column; j++) {
                last_j = j;
            }
        }
        if (last_i == -1 || last_j == -1) {
            addPictureButton.hidden = YES;
        }
        else{
            addPictureButton.hidden = NO;
        }
        
        CGFloat buttonX = (buttonW + buttonHDis) * last_j;
        CGFloat buttonY = (buttonH + buttonVDis) * last_i + 35;
        CGFloat buttonW = addPictureButton.frame.size.width;
        CGFloat buttonH = addPictureButton.frame.size.height;
        
        addPictureButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        CGFloat distributeX = bannerImageBG.frame.origin.x;
        CGFloat distributeY = bannerImageBG.frame.origin.y;
        CGFloat distributeW = bannerImageBG.frame.size.width;
        CGFloat distributeH = addPictureButton.frame.origin.y + addPictureButton.frame.size.height;
        
        bannerImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
    }
    else{
        
        CGFloat distributeX = bannerImageBG.frame.origin.x;
        CGFloat distributeY = bannerImageBG.frame.origin.y;
        CGFloat distributeW = bannerImageBG.frame.size.width;
        CGFloat distributeH = (buttonH + buttonVDis) * (MAX_row - 1) + buttonH;
        
        bannerImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
        addPictureButton.hidden = YES;
    }
    [bannerImageBG addSubview:addPictureButton];
    
    CGFloat contentHeight = CGRectGetMaxY(bannerImageBG.frame) + 10;
    
    UIScrollView *contentScrollView = (UIScrollView *)bannerImageBG.superview;
    contentScrollView.contentSize = CGSizeMake(0, contentHeight);
    
}

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
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

//添加图片的方法
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

//处理选择回来图片
- (void)handleSelectPhoto
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < bannerImageDataSource.count; index++) {
        AsynImageView *imageview = bannerImageDataSource[index];
        if (imageview.imageTag != -1) {
            
        }
        else{
            [tempArray addObject:imageview];
        }
    }
    bannerImageDataSource = [[NSMutableArray alloc] initWithArray:tempArray];
//    for (AsynImageView *imageview in bannerImageDataSource) {
//        if (imageview.imageTag != -1) {
//            [bannerImageDataSource removeObject:imageview];
//        }
//    }
    
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

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    return YES;
}

//输入备注
- (void)inputReamrk
{
    [self.view addSubview:dismissView];
    dismissView.hidden = NO;
    
    CGFloat viewX = 10;
    CGFloat viewY = 120;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = 120;
    UIView *shareAlert = [[UIView alloc] init];
    shareAlert.frame = CGRectMake(viewX, viewY, viewW, viewH);
    shareAlert.backgroundColor = [UIColor whiteColor];
    shareAlert.layer.cornerRadius = 5.0;
    shareAlert.layer.borderWidth = 0;
    shareAlert.layer.masksToBounds = YES;
    shareAlert.tag = ALERTTAG;
    shareAlert.layer.borderColor = [UIColor clearColor].CGColor;
    shareAlert.userInteractionEnabled = YES;
    
    CGFloat labelH = 30;
    CGFloat labelY = 0;
    
    UIFont *shareFont = [UIFont systemFontOfSize:13.0];
    
    UILabel *messageTitleLabel = [[UILabel alloc] init];
    messageTitleLabel.font = shareFont;
    messageTitleLabel.textColor = [UIColor blackColor];
    messageTitleLabel.textAlignment = NSTextAlignmentCenter;
    messageTitleLabel.backgroundColor = [UIColor clearColor];
    messageTitleLabel.text = @"备注信息";
    messageTitleLabel.frame = CGRectMake(0, 0, viewW, labelH);
    [shareAlert addSubview:messageTitleLabel];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logoImage"]];
    logoImage.frame = CGRectMake(20, 5, 30, 30);
    [shareAlert addSubview:logoImage];
    
    
    labelY = labelY + labelH + 10;
    UITextField *textview = [[UITextField alloc] init];
    textview.tag = 10;
    textview.backgroundColor = [UIColor whiteColor];
    textview.placeholder = @"病史、禁忌、特殊说明";
    
    UILabel *field = (UILabel *)[_selectMenuBgView viewWithTag:2400];
    NSString *fieldText = field.text;
    
    if ([fieldText hasPrefix:@"病史、禁忌、特殊说明"]) {
        fieldText = nil;
    }
    textview.text = fieldText;
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
    CGFloat buttonH = 30;
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
    //    [cancelButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:cancelButton.frame.size] forState:UIControlStateHighlighted];
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
    [[UIApplication sharedApplication].keyWindow addSubview:shareAlert];
}

//提示信息
- (void)alertbuttonClick:(UIButton *)button
{
    UIView *mydismissView = dismissView;
    mydismissView.hidden = YES;
    
    UIView *alertview = [[UIApplication sharedApplication].keyWindow viewWithTag:ALERTTAG];
    
    UIView *subview = [alertview viewWithTag:10];
    if (button.tag == 0) {
        [alertview removeFromSuperview];
        return;
    }
    UITextField *textview = nil;
    if ([subview isMemberOfClass:[UITextField class]]) {
        textview = (UITextField *)subview;
    }
    NSString *password = textview.text;
    [alertview removeFromSuperview];
    if (password == nil || [password isEqualToString:@""]) {
        
        [self showHint:@"请输入备注"];
        return;
    }
    UILabel *field = (UILabel *)[_selectMenuBgView viewWithTag:2400];
    field.text = password;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [_webView.scrollView removeObserver:self forKeyPath:@"contentOffset"];
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
