//
//  FirstViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "FirstViewController.h"
#import "LBBanner.h"
#import "HomePageTableCell.h"
#import "RESideMenu.h"
#import "AppDelegate.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "ImageScale.h"

@interface FirstViewController ()<LBBannerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger addStatusBarHeight;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;

@end

@implementation FirstViewController
@synthesize tableview;

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
        label.text = @"首页";
        [label sizeToFit];
        self.title = @"首页";
        
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
}

- (void)initView
{
    [super initView];
    
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIImage *menuIcon = [UIImage imageNamed:@"icon_list"];
//    CGFloat menuButtonH = 25;
//    CGFloat menuButtonW = menuIcon.size.width / menuIcon.size.height * menuButtonH;
//    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, menuButtonW, menuButtonH)];
//    [menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] init];
    menuItem.image = menuIcon;
    menuItem.target = self;
    menuItem.action = @selector(menuButtonClick:);
    self.navigationItem.leftBarButtonItem = menuItem;
    
    CGFloat addressButtonH = 25;
    CGFloat addressButtonW = 80;
    UIButton *addressButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addressButtonW, addressButtonH)];
    [addressButton addTarget:self action:@selector(addressButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    addressButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [addressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addressButton setTitle:@"杭州市" forState:UIControlStateNormal];
    UIImage *arrowImage = [UIImage imageNamed:@"icon_white_down"];
    [addressButton setImage:arrowImage forState:UIControlStateNormal];
    // 设置按钮图片偏移
    // 设置按钮标题偏移
    [addressButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0,-addressButton.imageView.bounds.size.width, 0.0,addressButton.imageView.bounds.size.width)];
    [addressButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, addressButton.titleLabel.bounds.size.width, 0.0, -addressButton.titleLabel.bounds.size.width)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addressButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGFloat headerHeight = 300;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    headerView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    
    
    CGFloat bannerHeight = 180;
    NSArray * imageNames = @[@"index1", @"index2"];
    LBBanner * banner = [[LBBanner alloc] initWithImageNames:imageNames andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
    banner.delegate = self;
    
    [headerView addSubview:banner];
    
    CGFloat buttonBGHeight = 110;
    UIView *buttonBG = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(banner.frame), SCREENWIDTH, buttonBGHeight)];
    NSArray *iconArray = @[@[@"icon_nurse_door",@"icon_personal"]];
    NSArray *titleArray = @[@[@"护士上门",@"私人定制"]];
    
    buttonBG.backgroundColor = [UIColor whiteColor];
    [self addButtonToView:buttonBG withImage:iconArray andTitle:titleArray imageWidth:60];
    [headerView addSubview:buttonBG];
    
    CGFloat sepLineX = SCREENWIDTH / 2.0 - 0.5;
    CGFloat sepLineW = 2;
    CGFloat sepLineH = 40;
    CGFloat sepLineY = (buttonBGHeight - sepLineH) / 2.0;
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    sepLine.backgroundColor = [UIColor blackColor];
    [buttonBG addSubview:sepLine];
    
    self.tableview.tableHeaderView = headerView;
    
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
}

- (void)endRefreshing
{
    [self.tableview.footer endRefreshing];
    self.tableview.footer.hidden = YES;
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
    NSLog(@"endRefreshing");
}

//添加按钮
- (void)addButtonToView:(UIView *)buttonBG withImage:(NSArray *)imagearray andTitle:(NSArray *)nameArray imageWidth:(CGFloat)myimageWidth
{
    CGFloat viewW = buttonBG.frame.size.width;
    CGFloat viewH = buttonBG.frame.size.height;
    NSInteger buttonCountRow = [[imagearray objectAtIndex:0] count];
    NSInteger buttonCountColumn = [imagearray count];
    CGFloat buttonX = 0;
    
    CGFloat buttonVDistance = 1;
    
    CGFloat buttonW = 80;
    CGFloat buttonH = 70;
    CGFloat buttonHDistance = 80;
    
    buttonX = (SCREENWIDTH - (buttonCountRow - 1) * buttonHDistance - buttonCountRow * buttonW) / 2.0;
    CGFloat buttonY = 20;
    
    for (int i = 0; i < [imagearray count]; i++) {
        for (int j = 0; j < [[imagearray objectAtIndex:i] count]; j++) {
            
            NSString *imageName = [[imagearray objectAtIndex:i] objectAtIndex:j];
            UIImage *orignalImage = [UIImage imageNamed:imageName];
            CGFloat imageWidth = myimageWidth;
            CGFloat imageHeight = imageWidth / orignalImage.size.width * orignalImage.size.height;
            CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
            NSString *buttonTitle = [[nameArray objectAtIndex:i] objectAtIndex:j];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(buttonX + j * buttonHDistance + j * buttonW, buttonY + i * buttonVDistance + i * buttonH, buttonW, buttonH);
            button.tag = i * [[imagearray objectAtIndex:i] count] + j + buttonBG.tag;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[orignalImage scaleToSize:CGSizeMake(imageWidth, imageHeight)] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [buttonBG addSubview:button];
            [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
            
            // 按钮图片和标题总高度
            CGFloat totalHeight = (button.imageView.frame.size.height + button.titleLabel.frame.size.height);
            // 设置按钮图片偏移
            // 设置按钮标题偏移
            [button setTitleEdgeInsets:UIEdgeInsetsMake(10.0, -button.imageView.frame.size.width, -(totalHeight - button.titleLabel.frame.size.height),0.0)];
            
            [button setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - button.imageView.frame.size.height), 0.0, 0.0, -button.titleLabel.frame.size.width)];
            
            
        }
        
    }
}

- (void)buttonClick:(UIButton *)button
{
    if (button.tag == 0) {
        NSLog(@"护士上门");
    }
    else{
        NSLog(@"私人定制");
    }
}
- (void)menuButtonClick:(id)sender
{
    //展示左边菜单
    RESideMenu *resideMenuVC = (RESideMenu *)((AppDelegate *)[UIApplication sharedApplication].delegate).viewController;
    [resideMenuVC presentLeftMenuViewController];
}

- (void)addressButtonClick:(UIButton *)button
{
    NSLog(@"addressButtonClick");
}

-(void)chooseCity{
    NSLog(@"chooseCity");
    
}

#pragma mark LBBannerDelegate
- (void)banner:(LBBanner *)banner didClickViewWithIndex:(NSInteger)index {
    NSLog(@"didClickViewWithIndex:%ld", index);
}

- (void)banner:(LBBanner *)banner didChangeViewWithIndex:(NSInteger)index {
    NSLog(@"didChangeViewWithIndex:%ld", index);
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HomePageTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    
    HomePageTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HomePageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.text = @"精品推荐";
    [headerView addSubview:titleLabel];
    
    CGSize size = [MLLabel getViewSizeByString:titleLabel.text maxWidth:titleLabel.frame.size.width font:titleLabel.font lineHeight:1.2f lines:0];
    
    //两条横线的间距
    CGFloat lineDistance = 20 + size.width;
    CGFloat sepLineX = 20;
    CGFloat sepLineW = (SCREENWIDTH - lineDistance - 2 * sepLineX) / 2.0;
    CGFloat sepLineH = 1;
    CGFloat sepLineY = (50 - sepLineH) / 2.0 - 0.5;
    UIView *leftSepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    leftSepLine.backgroundColor = [UIColor grayColor];
    [headerView addSubview:leftSepLine];

    sepLineX = CGRectGetMaxX(leftSepLine.frame) + lineDistance;
    UIView *rightSepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
    rightSepLine.backgroundColor = [UIColor grayColor];
    [headerView addSubview:rightSepLine];
    
    return headerView;
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
