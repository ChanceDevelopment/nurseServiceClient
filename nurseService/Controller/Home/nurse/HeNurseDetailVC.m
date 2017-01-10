//
//  HeNurseDetailVC.m
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeNurseDetailVC.h"
#import "HeServiceTableCell.h"
#import "HeServiceDetailVC.h"
#import "MLLabel+Size.h"
#import "DLNavigationTabBar.h"
#import "HYPageView.h"
#import "HeBookServiceVC.h"
#import "HeServiceInfoVC.h"
#import "HeCommentVC.h"
#import "HeServiceDetailVC.h"
#import "BrowserView.h"
#import "HeServiceItemVC.h"
#import "HeServiceTimeVC.h"
#import "HeServiceCommentVC.h"

@interface HeNurseDetailVC ()
@property(strong,nonatomic)IBOutlet UIImageView *headerView;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)IBOutlet UIButton *commentButton;
@property(strong,nonatomic)IBOutlet UIButton *serviceButton;
@property(strong,nonatomic)IBOutlet UIButton *followButton;
@property(strong,nonatomic)IBOutlet UIButton *followNumButton;
@property(strong,nonatomic)IBOutlet UILabel *nameLabel;
@property(strong,nonatomic)IBOutlet UILabel *hospitalLabel;
@property(strong,nonatomic)IBOutlet UIImageView *userImage;

@property(strong,nonatomic)IBOutlet UIView *otherInfoView;
@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
@property(strong,nonatomic)IBOutlet UIView *footerView;



@end

@implementation HeNurseDetailVC
@synthesize nurseDictInfo;
@synthesize headerView;
@synthesize tableview;
@synthesize dataSource;
@synthesize commentButton;
@synthesize serviceButton;
@synthesize followButton;
@synthesize followNumButton;
@synthesize nameLabel;
@synthesize hospitalLabel;
@synthesize userImage;
@synthesize otherInfoView;

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
        label.text = @"护士详情";
        [label sizeToFit];
        self.title = @"护士详情";
        
    }
    return self;
}

-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"服务项目",@"服务时间",@"用户评价"]];
        self.navigationTabBar.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 40);
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

#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self addFooterView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    [self initOtherInfoView];
    
    followButton.layer.cornerRadius = 5.0;
    followButton.layer.borderWidth = 1.0;
    followButton.layer.masksToBounds = YES;
    followButton.layer.borderColor = [UIColor whiteColor].CGColor;
    CGFloat tipLabelX = 0;
    CGFloat tipLabelY = 0;
    CGFloat tipLabelW = 0;
    CGFloat tipLabelH = 20;
    
    UIFont *font = [UIFont systemFontOfSize:13.0];
    
    CGSize size = [MLLabel getViewSizeByString:@"国家卫计委认证" maxWidth:SCREENWIDTH / 2.0 font:font lineHeight:1.2f lines:0];
    tipLabelW = size.width + 20;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipLabelX, tipLabelY, tipLabelW, tipLabelH)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = font;
    tipLabel.textAlignment = NSTextAlignmentRight;
    tipLabel.text = @"国家卫计委认证";
    tipLabel.textColor = [UIColor whiteColor];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, 15, 15)];
    icon.image = [UIImage imageNamed:@"icon_health_authent"];
    [tipLabel addSubview:icon];
    
    size = [MLLabel getViewSizeByString:@"实名认证" maxWidth:SCREENWIDTH / 2.0 font:font lineHeight:1.2f lines:0];
    tipLabelW = size.width + 20;
    
    UILabel *tipLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tipLabel.frame), tipLabelY, tipLabelW, tipLabelH)];
    tipLabel1.backgroundColor = [UIColor clearColor];
    tipLabel1.font = font;
    tipLabel1.textAlignment = NSTextAlignmentRight;
    tipLabel1.text = @"实名认证";
    tipLabel1.textColor = [UIColor whiteColor];
    
    UIImageView *icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, 15, 15)];
    icon1.image = [UIImage imageNamed:@"icon_name_authent"];
    [tipLabel1 addSubview:icon1];
    
    CGFloat bgViewY = 200;
    CGFloat bgViewW = CGRectGetWidth(tipLabel.frame) + CGRectGetWidth(tipLabel1.frame);
    CGFloat bgViewH = 20;
    CGFloat bgViewX = (SCREENWIDTH - bgViewW) / 2.0;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(bgViewX, bgViewY, bgViewW, bgViewH)];
    [bgView addSubview:tipLabel];
    [bgView addSubview:tipLabel1];
    
    [headerView addSubview:bgView];
}

- (void)initOtherInfoView
{
    CGFloat cellHeight = 40;
    
    UILabel *advantangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH, cellHeight)];
    advantangeLabel.text = @"优势：服务好，价格不贵";
    advantangeLabel.textColor = APPDEFAULTORANGE;
    advantangeLabel.font = [UIFont systemFontOfSize:15.0];
    [otherInfoView addSubview:advantangeLabel];
    
    UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(advantangeLabel.frame), SCREENWIDTH, cellHeight)];
    [otherInfoView addSubview:addressView];
    
    CGFloat locationViewW = 20;
    CGFloat locationViewH = 20;
    CGFloat locationViewX = 10;
    CGFloat locationViewY = (cellHeight - locationViewH) / 2.0;
    
    UIImageView *locationView = [[UIImageView alloc] initWithFrame:CGRectMake(locationViewX, locationViewY, locationViewW, locationViewH)];
    locationView.image = [UIImage imageNamed:@"icon_address"];
    [addressView addSubview:locationView];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 30, cellHeight)];
    addressLabel.textAlignment = NSTextAlignmentRight;
    addressLabel.text = @"距离我的所在位置约7.2km";
    addressLabel.textColor = [UIColor blackColor];
    addressLabel.font = [UIFont systemFontOfSize:15.0];
    [addressView addSubview:addressLabel];
    
//    [otherInfoView addSubview:self.navigationTabBar];
//    CGRect barFrame = _navigationTabBar.frame;
//    barFrame.origin.y = CGRectGetMaxY(addressView.frame);
//    _navigationTabBar.frame = barFrame;
    
    
    CGFloat lineX = 0;
    CGFloat lineW = SCREENWIDTH;
    CGFloat lineY = cellHeight;
    CGFloat lineH = 1;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [otherInfoView addSubview:line];
    
    lineY = lineY + cellHeight;
    line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [otherInfoView addSubview:line];
    
    lineY = lineY + cellHeight;
    line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [otherInfoView addSubview:line];
    
}

- (void)addFooterView
{
    
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH) withTitles:@[@"服务项目",@"服务时间",@"评论"] withViewControllers:@[@"HeServiceItemVC",@"HeServiceTimeVC",@"HeServiceCommentVC"] withParameters:@[@"123",@"这是一片很寂寞的天"]];
    pageView.isTranslucent = YES;
    pageView.font = [UIFont systemFontOfSize:13.0];
    pageView.topTabBottomLineColor = APPDEFAULTORANGE;
    pageView.selectedColor = APPDEFAULTORANGE;
    pageView.unselectedColor = [UIColor grayColor];
    
    [_footerView addSubview:pageView];
    
}

- (IBAction)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followButtonClick:(UIButton *)sender
{
    NSLog(@"followButtonClick");
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
