//
//  LeftViewController.m
//  YCW
//
//  Created by apple on 15/12/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LeftViewController.h"
#import "HomeTabbarController.h"
#import "XDMultTableView.h"
#import "HeServiceDetailVC.h"
#import "HeTabBarVC.h"
#import "AppDelegate.h"
#import "RESideMenu.h"
#import "HeBookServiceVC.h"
#import "HYPageView.h"

@interface LeftViewController ()<XDMultTableViewDatasource,XDMultTableViewDelegate>
{
    NSMutableArray *sectionArr;
    NSMutableArray *titleArr;
    NSMutableArray *titleImageArr;
    NSInteger currentSection;
}
@property (nonatomic, strong) XDMultTableView *tableView;
@property(strong,nonatomic)NSArray *menuArray;

@end

@implementation LeftViewController
@synthesize menuArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLeftMenu:) name:kLoadLeftMenuNotification object:nil];
    [self initDataSource];
}

- (void)initDataSource
{
    titleArr = [[NSMutableArray alloc] initWithCapacity:0];
    titleImageArr = [[NSMutableArray alloc] initWithCapacity:0];
    sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([menuArray count] == 0) {
        menuArray = [HeSysbsModel getSysModel].menuArray;
    }
    
    if (menuArray == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"leftMenu" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        NSString *menuString = dict[@"menu"];
        NSDictionary *menuDict = [menuString objectFromJSONString];
        menuArray = [[NSArray alloc] initWithArray:[menuDict valueForKey:@"json"]];
    }
    for (id dict in menuArray) {
        NSString *manageNursingProjectNameId = dict[@"manageNursingProjectNameId"];
        if ([manageNursingProjectNameId isMemberOfClass:[NSNull class]] || manageNursingProjectNameId == nil) {
            manageNursingProjectNameId = @"";
        }
        [titleArr addObject:manageNursingProjectNameId];
        
        NSString *manageNursingProjectPic = dict[@"manageNursingProjectPic"];
        if ([manageNursingProjectPic isMemberOfClass:[NSNull class]] || manageNursingProjectPic == nil) {
            manageNursingProjectPic = @"";
        }
        manageNursingProjectPic = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,manageNursingProjectPic];
        [titleImageArr addObject:manageNursingProjectPic];
        
        id undelObj = dict[@"undel"];
        NSArray *undelArray = nil;
        if ([undelObj isKindOfClass:[NSString class]]) {
            undelArray = [(NSString *)undelObj objectFromJSONString];
        }
        else{
            undelArray = undelObj;
        }
        NSMutableArray *subArray = [[NSMutableArray alloc] initWithCapacity:0];
        //有二级图标
        for (id undelObj in undelArray) {
            NSString *contentname = undelObj[@"contentname"];
            [subArray addObject:contentname];
        }
        if ([subArray count] == 0) {
            //没有二级图标
            [subArray addObject:@"1"];
        }
        
        [sectionArr addObject:subArray];
    }
}

- (void)initView
{
    self.view.backgroundColor = [UIColor purpleColor];
    
    
    _tableView.frame = CGRectMake(0, 64, SCREENWIDTH, self.view.frame.size.width - 64);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"我是多级列表";
    _tableView = [[XDMultTableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width-150, self.view.frame.size.height - 64)];
    //默认打开
    currentSection = 0;
    _tableView.openSectionArray = [NSArray arrayWithObjects:@0, nil];
    _tableView.delegate = self;
    _tableView.datasource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoAdjustOpenAndClose = NO;
    [self.view addSubview:_tableView];
}

- (void)reloadLeftMenu:(NSNotification *)notification
{
    NSLog(@"notification.object = %@",notification.object);
    id menuArrayObj = notification.object;
    if ([menuArrayObj isKindOfClass:[NSArray class]]) {
        menuArray = menuArrayObj;
        [self initDataSource];
        [_tableView reloadData];
    }
    
}

//设置状态栏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - datasource
- (NSInteger)mTableView:(XDMultTableView *)mTableView numberOfRowsInSection:(NSInteger)section{
    id obj = sectionArr[section];
    NSLog(@"[sectionArr[section] count] = %ld",[sectionArr[section] count]);
    return [sectionArr[section] count];
}

- (XDMultTableViewCell *)mTableView:(XDMultTableView *)mTableView
              cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [mTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds] ;
    view.layer.backgroundColor  = [UIColor purpleColor].CGColor;
    view.layer.masksToBounds    = YES;
    view.layer.borderWidth      = 0.1;
    view.layer.borderColor      = [UIColor lightGrayColor].CGColor;
    
    cell.backgroundView = view;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"###%ld:%ld",indexPath.row,currentSection);
    cell.textLabel.text =[NSString stringWithFormat:@"%@",[sectionArr[currentSection] objectAtIndex:indexPath.row]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(XDMultTableView *)mTableView{
    return sectionArr.count;
}

-(NSString *)mTableView:(XDMultTableView *)mTableView titleForHeaderInSection:(NSInteger)section{
    return titleArr[section];
}

-(NSString *)mTableView:(XDMultTableView *)mTableView titleImageForHeaderInSection:(NSInteger)section{
    return titleImageArr[section];
}

#pragma mark - delegate
- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


- (void)mTableView:(XDMultTableView *)mTableView willOpenHeaderAtSection:(NSInteger)section{
    NSLog(@"即将展开:%ld",section);
    currentSection = section;
}


- (void)mTableView:(XDMultTableView *)mTableView willCloseHeaderAtSection:(NSInteger)section{
    NSLog(@"即将关闭");
}

- (void)mTableView:(XDMultTableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击cell:%ld:%ld",currentSection,indexPath.row);
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSDictionary *menuDict = menuArray[section];
    
    id undelObj = menuDict[@"undel"];
    NSArray *undelArray = nil;
    if ([undelObj isKindOfClass:[NSString class]]) {
        undelArray = [(NSString *)undelObj objectFromJSONString];
    }
    else{
        undelArray = undelObj;
    }
    NSDictionary *undelDict = undelArray[row];
    
    NSLog(@"menuDict = %@ , undelDict = %@",menuDict,undelDict);
    
    [self bookServiceWithDict:undelDict];
    
    CustomNavigationController *selectedVC = [self getCurrentNav];
//    NSLog(@"selectedVC = %@",selectedVC);
//    HeServiceDetailVC *serviceDetailVC = [[HeServiceDetailVC alloc] init];
//    serviceDetailVC.hidesBottomBarWhenPushed = YES;
//    [selectedVC pushViewController:serviceDetailVC animated:YES];
//    [menuVC presentLeftMenuViewController];
//    [menuVC hideMenuViewController];
}

- (CustomNavigationController *)getCurrentNav
{
    RESideMenu *menuVC = (RESideMenu *)((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    HeTabBarVC *tabBarVC = (HeTabBarVC *)menuVC.contentViewController;
    CustomNavigationController *selectedVC = (CustomNavigationController *)tabBarVC.selectedViewController;
    return selectedVC;
}
- (void)bookServiceWithDict:(NSDictionary *)dict
{
    //总控制器，控制商品、详情、评论三个子控制器
    RESideMenu *menuVC = (RESideMenu *)((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    [menuVC hideMenuViewController];
    
    HeBookServiceVC *serviceDetailVC = [[HeBookServiceVC alloc] init];
    [[self getCurrentNav] setNavigationBarHidden:YES animated:YES];
    [serviceDetailVC.view addSubview:[self getPageViewWithParam:dict]];
    [[self getCurrentNav] pushViewController:serviceDetailVC animated:YES];
    
}


- (HYPageView *)getPageViewWithParam:(NSDictionary *)dict
{
    NSString *contentid = dict[@"contentid"];
    if (!contentid) {
        contentid = @"";
    }
    NSDictionary *myDict = @{@"contentId":contentid};
    
    NSDictionary *nurseInfoDict = [[NSDictionary alloc] init];
    NSDictionary *paramDict = @{@"service":myDict,@"nurse":nurseInfoDict};
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH) withTitles:@[@"商品",@"详情",@"评论"] withViewControllers:@[@"HeServiceDetailVC",@"HeServiceInfoVC",@"HeCommentVC"] withParameters:@[paramDict,myDict,myDict]];
    pageView.isTranslucent = NO;
    pageView.topTabBottomLineColor = [UIColor whiteColor];
    pageView.selectedColor = [UIColor whiteColor];
    pageView.unselectedColor = [UIColor whiteColor];
    UIButton *backImage = [[UIButton alloc] init];
    [backImage setBackgroundImage:[UIImage imageNamed:@"navigationBar_back_icon"] forState:UIControlStateNormal];
    [backImage addTarget:self action:@selector(backItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    backImage.frame = CGRectMake(0, 0, 25, 25);
    
    pageView.leftButton = backImage;
    
    return pageView;
}

- (void)backItemClick:(id)sender
{
    [[self getCurrentNav] popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoadLeftMenuNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
