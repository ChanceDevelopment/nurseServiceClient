//
//  HeInfoVC.m
//  carTune
//
//  Created by HeDongMing on 16/6/18.
//  Copyright © 2016年 Jitsun. All rights reserved.
//


#import "DCPicScrollView.h"
#import "DCWebImageManager.h"
#import "HeSearchInfoVC.h"
#import "AppDelegate.h"
#import "HeBaseTableViewCell.h"
#import "HeSearchNurseTableCell.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "ImageScale.h"
#import "HeNurseDetailVC.h"

#define HEADVIEWHEIGH 150
#define SCROLLTAG 300
#define LEFTVIEWTAG 200
#define LOADRECORDNUM 20

@interface HeSearchInfoVC ()<UISearchBarDelegate>
{
    NSInteger limit;
    NSInteger offset;
}
@property(strong,nonatomic)IBOutlet UITableView *infoTable;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *headerArray;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeSearchInfoVC
@synthesize infoTable;
@synthesize dataSource;
@synthesize headerArray;
@synthesize imageCache;
@synthesize searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"护士上门";
        [label sizeToFit];
        self.title = @"护士上门";
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
    
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    imageCache = [[NSCache alloc] init];
    headerArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    limit = LOADRECORDNUM;
    offset = [dataSource count];

    dataSource = [[NSMutableArray alloc] initWithCapacity:0];

}

- (void)initView
{
    [super initView];

    [Tool setExtraCellLineHidden:infoTable];
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    CGFloat searchX = 30;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = SCREENHEIGH - 2 * searchY;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"搜索护士";
    self.navigationItem.titleView = searchBar;self.infoTable.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.infoTable.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
    
    self.infoTable.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.infoTable.footer.automaticallyHidden = YES;
        self.infoTable.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
}

- (void)endRefreshing
{
    [self.infoTable.footer endRefreshing];
    self.infoTable.footer.hidden = YES;
    self.infoTable.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.infoTable.footer.automaticallyHidden = YES;
        self.infoTable.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
    NSLog(@"endRefreshing");
}


- (void)updateInfo:(NSNotification *)notificaition
{
    
}

- (void)loadInfoDataWithKey:(NSString *)searchKey
{
    NSLog(@"loadInfoDataWithKey");
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    NSString *searchKey = searchBar.text;
    if (searchKey == nil || [searchKey isEqualToString:@""]) {
        [self showHint:@"请输入搜索关键字"];
        return;
    }
    limit = 20;
    offset = 0;
    
    NSLog(@"searchKey = %@",searchKey);
    
}


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
    NSInteger section = indexPath.section;
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    static NSString *cellIndentifier = @"HeInfoTableViewCell";
    HeSearchNurseTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeSearchNurseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    NSDictionary *dict = nil;
    
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeNurseDetailVC *nurseDetailVC = [[HeNurseDetailVC alloc] init];
    nurseDetailVC.nurseDictInfo = [[NSDictionary alloc] initWithDictionary:dict];
    nurseDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nurseDetailVC animated:YES];
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
