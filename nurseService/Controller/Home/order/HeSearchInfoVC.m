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
    NSString  *keyWord;
    NSInteger pageNum;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *headerArray;
@property(strong,nonatomic)NSCache *imageCache;
@end

@implementation HeSearchInfoVC
@synthesize tableview;
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

    dataSource = [[NSMutableArray alloc] initWithCapacity:0];

}

- (void)initView
{
    [super initView];

    [Tool setExtraCellLineHidden:tableview];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    CGFloat searchX = 30;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = SCREENHEIGH - 2 * searchY;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"搜索护士";
    self.navigationItem.titleView = searchBar;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
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
        pageNum++;
        [self loadNurseData];
    }];
    NSLog(@"endRefreshing");
}


- (void)updateInfo:(NSNotification *)notificaition
{
    
}

- (void)loadNurseData
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/searchNurse.action",BASEURL];
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary * params  = @{@"keyWord":keyWord,@"pageNum":pageNumStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = [respondDict valueForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil || [jsonArray count] == 0) {
                if (pageNum > 0) {
                    //因为无法加载更多，所以回复到原来的页数
                    pageNum--;
                }
                return;
            }
            if (pageNum == 0) {
                //如果刷新，先清除数据
                [dataSource removeAllObjects];
            }
            for (NSDictionary *dict in jsonArray) {
                [dataSource addObject:dict];
            }
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                imageview.frame = CGRectMake(100, 100, imageW, imageH);
                imageview.center = bgView.center;
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
                
            }
            else{
                tableview.backgroundView = nil;
            }
            [tableview reloadData];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
                
            }
            [self showHint:@"没有该护士"];
            [dataSource removeAllObjects];
        }
        [tableview reloadData];
    } failure:^(NSError* err){
        
    }];
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
    NSRange _range = [searchKey rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        //有空格
        [self showHint:@"不能加空格"];
        return;
    }
    if (searchKey == nil || [searchKey isEqualToString:@""]) {
        [self showHint:@"请输入搜索关键字"];
        return;
    }
    pageNum = 0;
    keyWord = searchKey;
    [self loadNurseData];
    NSLog(@"searchKey = %@",searchKey);
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
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
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    HeSearchNurseTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeSearchNurseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    NSString *nurseHeader = dict[@"nurseHeader"];
    if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
        nurseHeader = @"";
    }
    nurseHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,nurseHeader];
    NSString *nurseHeaderKey = [NSString stringWithFormat:@"%ld%ld_%@",section,row,nurseHeader];
    UIImageView *imageview = [imageCache objectForKey:nurseHeaderKey];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:nurseHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
        imageview = cell.userImage;
    }
    cell.userImage = imageview;
    [cell insertSubview:cell.userImage atIndex:0];
    
    NSString *nurseNick = dict[@"nurseNick"];
    if ([nurseNick isMemberOfClass:[NSNull class]] || nurseNick == nil) {
        nurseNick = @"";
    }
    cell.nameLabel.text = nurseNick;
    
    NSString *nurseWorkUnit = dict[@"nurseWorkUnit"];
    if ([nurseWorkUnit isMemberOfClass:[NSNull class]] || nurseWorkUnit == nil) {
        nurseWorkUnit = @"";
    }
    cell.hospitalLabel.text = nurseWorkUnit;
    
    NSString *nurseNote = dict[@"nurseNote"];
    if ([nurseNote isMemberOfClass:[NSNull class]] || nurseNote == nil) {
        nurseNote = @"";
    }
    cell.addresssLabel.text = nurseNote;
    
    CGFloat distance = [dict[@"distance"] floatValue] / 1000.0;
    NSString *distanceStr = [NSString stringWithFormat:@"%.2fkm",distance];
    CGSize distanceSize = [MLLabel getViewSizeByString:distanceStr maxWidth:cell.addresssLabel.frame.size.width font:cell.distanceLabel.font lineHeight:1.2f lines:0];
    
    CGRect distanceFrame = cell.distanceLabel.frame;
    
    
    distanceFrame.size.width = distanceSize.width + 30;
    CGFloat distanceLabelX = SCREENWIDTH - distanceFrame.size.width - 10;
    distanceFrame.origin.x = distanceLabelX;
    cell.distanceLabel.frame = distanceFrame;
    cell.distanceLabel.text = distanceStr;
    
    
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
