//
//  HeMessageVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserInviteVC.h"
#import "HeBaseTableViewCell.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "HeUserCouponCell.h"
#import "HeUserInviteCell.h"

@interface HeUserInviteVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger pageNum;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeUserInviteVC
@synthesize tableview;
@synthesize dataSource;

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
        label.text = @"我的邀请";
        [label sizeToFit];
        self.title = @"我的邀请";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self loadInvite];
}

- (void)initializaiton
{
    [super initializaiton];
    pageNum = 0;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _imageCache = [[NSCache alloc] init];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Tool setExtraCellLineHidden:tableview];
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    
    __weak HeUserInviteVC *weakSelf = self;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
        [weakSelf loadInvite];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
        [weakSelf loadInvite];
        
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

- (void)loadInvite
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/nurseAnduser/selectMyInvitationUserInfo.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"pageNum":pageNumStr};
    [self showHudInView:self.view hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                resultArray = [NSArray array];
            }
            if (pageNum == 0) {
                [dataSource removeAllObjects];
            }
            if (pageNum != 0 && [resultArray count] == 0) {
                pageNum--;
            }
            [dataSource addObjectsFromArray:resultArray];
            
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_no_data_refresh"]];
                imageview.frame = CGRectMake(100, 100, imageW, imageH);
                imageview.center = bgView.center;
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
            }
            
            [self.tableview reloadData];
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
    
    static NSString *cellIndentifier = @"HeUserInviteCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeUserInviteCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeUserInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSString *userHeader = dict[@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]]) {
        userHeader = @"";
    }
    userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    NSString *imagekey = [NSString stringWithFormat:@"%ld_%ld_%@",section,row,userHeader];
    UIImageView *imageview = [_imageCache objectForKey:imagekey];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
        imageview = cell.userImage;
        [_imageCache setObject:imageview forKey:imagekey];
    }
    cell.userImage = imageview;
    [cell.nameLabel.superview addSubview:cell.userImage];
    
    NSString *userNick = dict[@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.nameLabel.text = userNick;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
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
