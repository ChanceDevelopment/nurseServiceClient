//
//  HeServiceDetailVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeServiceDetailVC.h"
#import "DLNavigationTabBar.h"
#import "HeBaseTableViewCell.h"
#import "LBBanner.h"
#import "MLLabel+Size.h"
#import "UWDatePickerView.h"
#import "HeProtectedUserInfoVC.h"

@interface HeServiceDetailVC ()<UITableViewDelegate,UITableViewDataSource,LBBannerDelegate,UIWebViewDelegate,UIAlertViewDelegate,UWDatePickerViewDelegate,SelectProtectUserInfoProtocol>

@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)IBOutlet UIView *footerBGView;
@property(assign,nonatomic)CGFloat maxContentOffSet_Y;
@property(strong,nonatomic)UIView *contentView;
@property(strong,nonatomic)UILabel *headLab;
@property(strong,nonatomic)UIWebView *webView;
@property(strong,nonatomic)UIView *webContentView;
//服务时间
@property(strong,nonatomic)NSString *tmpDateString;

//选择服务类型的背景图
@property(strong,nonatomic)UIView *selectMenuBgView;

@end

@implementation HeServiceDetailVC
@synthesize tableview;
@synthesize footerBGView;

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

#pragma mark - SelectProtectUserInfoProtocol
- (void)selectUserInfoWithDict:(NSDictionary *)userInfo
{
    NSLog(@"selectUserInfo");
}

#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    NSString *webViewUrl = @"http://www.hao123.com/?tn=29065018_265_hao_pg";
    switch (index) {
        case 0:
            webViewUrl = @"https://www.baidu.com/?tn=SE_hldp07601_n9xgcmbe";
            break;
        case 1:
            webViewUrl = @"http://118.178.186.59:8080/nurseDoor/nurseAnduser/contentDetails.action?contentId=2a64345c6f4e48358d198f7d01cf0b97";
            break;
        case 2:
            webViewUrl = @"http://www.hao123.com/?tn=29065018_265_hao_pg";
            break;
        default:
            break;
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webViewUrl]]];
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
}

- (UIView *)selectMenuBgView
{
    if (!_selectMenuBgView) {
        CGFloat selectMenuBgViewX = 0;
        CGFloat selectMenuBgViewY = SCREENHEIGH - 64;
        CGFloat selectMenuBgViewW = SCREENWIDTH;
        CGFloat selectMenuBgViewH = 350;
        
        _selectMenuBgView = [[UIView alloc] initWithFrame:CGRectMake(selectMenuBgViewX, selectMenuBgViewY, selectMenuBgViewW, selectMenuBgViewH)];
        _selectMenuBgView.backgroundColor = [UIColor redColor];
        
        CGFloat commitButtonX = 0;
        CGFloat commitButtonW = SCREENWIDTH;
        CGFloat commitButtonH = 40;
        CGFloat commitButtonY = selectMenuBgViewH - commitButtonH;
        
        UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(commitButtonX, commitButtonY, commitButtonW, commitButtonH)];
        [commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
        [_selectMenuBgView addSubview:commitButton];
    }
    return _selectMenuBgView;
}


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
    
    CGFloat headerHeight = 180;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    headerView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.tableHeaderView = headerView;
    
    CGFloat bannerHeight = 180;
    NSArray * imageNames = @[@"index1", @"index2"];
    LBBanner * banner = [[LBBanner alloc] initWithImageNames:imageNames andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
    banner.delegate = self;
    
    [headerView addSubview:banner];
    
    [self loadContentView];
}

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
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
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


- (IBAction)favButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    NSLog(@"favButtonClick");
}
//加入预约框
- (IBAction)addToBookItem:(id)sender
{
    NSLog(@"addToBookItem");
}
//立即预约
- (IBAction)bookService:(UIButton *)sender
{
    NSLog(@"bookService");
    [self.view addSubview:self.selectMenuBgView];
    if (sender.selected) {
        [self setInfoViewisDown:YES withView:_selectMenuBgView];
    }
    else{
        [self setInfoViewisDown:NO withView:_selectMenuBgView];
    }
    sender.selected = !sender.selected;
    
}

- (void)commitButtonClick:(UIButton *)button
{
    NSLog(@"commitButtonClick");
}

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

#pragma mark LBBannerDelegate
- (void)banner:(LBBanner *)banner didClickViewWithIndex:(NSInteger)index {
    NSLog(@"didClickViewWithIndex:%ld", index);
}

- (void)banner:(LBBanner *)banner didChangeViewWithIndex:(NSInteger)index {
    NSLog(@"didChangeViewWithIndex:%ld", index);
}

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
            CGFloat titleLabelW = 100;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
            titleLabel.font = [UIFont systemFontOfSize:18.0];
            titleLabel.text = @"新生儿护理";
            [cell addSubview:titleLabel];
            
            
            CGFloat endLabelY = 0;
            CGFloat endLabelH = cellsize.height;
            CGFloat endLabelW = 100;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 10;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            endLabel.textColor = [UIColor redColor];
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.text = @"￥300.00起";
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
                    CGFloat titleLabelW = 100;
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.text = @"被保护人信息";
                    [cell addSubview:titleLabel];
                    
                    NSString *infoString = @"小明 男 15768580734";
                    CGSize size = [MLLabel getViewSizeByString:infoString maxWidth:SCREENWIDTH - 30 - titleLabelW font:[UIFont systemFontOfSize:15.0] lineHeight:1.2 lines:0];
                    titleLabelW = size.width;
                    titleLabelX = SCREENWIDTH - titleLabelW - 30;
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    nameLabel.textAlignment = NSTextAlignmentRight;
                    nameLabel.font = [UIFont systemFontOfSize:15.0];
                    nameLabel.text = @"小明 男 15768580734";
                    nameLabel.textColor = [UIColor  grayColor];
                    [cell addSubview:nameLabel];
                    
                    titleLabelX = 10;
                    titleLabelW = SCREENWIDTH - titleLabelX - 30;
                    titleLabelY = CGRectGetMaxY(nameLabel.frame);
                    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    addressLabel.textAlignment = NSTextAlignmentRight;
                    addressLabel.font = [UIFont systemFontOfSize:15.0];
                    addressLabel.textColor = [UIColor  grayColor];
                    addressLabel.text = @"中国广东省中山市西区";
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
                    titleLabel.text = @"中国人寿为您保驾护航";
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
                    //被受保护人信息
                    NSLog(@"被受保护人信息");
                    HeProtectedUserInfoVC *protectedUserInfoVC = [[HeProtectedUserInfoVC alloc] init];
                    protectedUserInfoVC.selectDelegate = self;
                    protectedUserInfoVC.hidesBottomBarWhenPushed = YES;
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
