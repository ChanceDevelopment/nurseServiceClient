//
//  HeServiceItemVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeServiceItemVC.h"
#import "HeServiceTableCell.h"
#import "HeBookServiceVC.h"
#import "HYPageView.h"
#import "HeBookServiceVC.h"
#import "HeServiceInfoVC.h"
#import "HeCommentVC.h"
#import "HeServiceDetailVC.h"
#import "BrowserView.h"
#import "HeServiceItemVC.h"
#import "HeServiceTimeVC.h"
#import "HeCommentVC.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"

@interface HeServiceItemVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)id parameter;
@property(strong,nonatomic)NSDictionary *nurseInfoDict;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeServiceItemVC
@synthesize dataSource;
@synthesize tableview;
@synthesize parameter;
@synthesize nurseInfoDict;
@synthesize imageCache;

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
        label.text = @"服务项目";
        [label sizeToFit];
        self.title = @"服务项目";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    NSLog(@"parameter = %@",parameter);
    NSString *nurseid = nurseInfoDict[@"nurseId"];
    if ([nurseid isMemberOfClass:[NSNull class]] || nurseid == nil) {
        nurseid = @"";
    }
    [self loadNurserServiceWithNurserID:nurseid];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    nurseInfoDict = parameter;
}

- (void)initView
{
    [super initView];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak HeServiceItemVC *weakSelf = self;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    
        
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    
        
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

//加载护士的服务项目
- (void)loadNurserServiceWithNurserID:(NSString *)nurseId
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectContentBynurseId.action",BASEURL];
    NSDictionary * params  = @{@"nurseid":nurseId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            id jsonObj = respondDict[@"json"];
            if ([jsonObj isMemberOfClass:[NSNull class]] || jsonObj == nil) {
                return;
            }
            [dataSource removeAllObjects];
            dataSource = [[NSMutableArray alloc] initWithArray:jsonObj];
            
            [tableview reloadData];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        
    }];
}

- (void)bookServiceWithDict:(NSDictionary *)dict
{
    //总控制器，控制商品、详情、评论三个子控制器
    HeBookServiceVC *serviceDetailVC = [[HeBookServiceVC alloc] init];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [serviceDetailVC.view addSubview:[self getPageViewWithParam:dict]];
    [self showViewController:serviceDetailVC sender:nil];
}

- (HYPageView *)getPageViewWithParam:(NSDictionary *)dict
{
    NSDictionary *paramDict = @{@"service":dict,@"nurse":nurseInfoDict};
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH) withTitles:@[@"商品",@"详情",@"评论"] withViewControllers:@[@"HeServiceDetailVC",@"HeServiceInfoVC",@"HeCommentVC"] withParameters:@[paramDict,dict,dict]];
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
    [self.navigationController popViewControllerAnimated:YES];
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
    static NSString *cellIndentifier = @"HeServiceTableCell";
    HeServiceTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeServiceTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    __weak HeServiceItemVC *weakSelf = self;
    cell.booklBlock = ^{
        [weakSelf bookServiceWithDict:dict];
    };
    
    NSString *contentImgurl = dict[@"contentImgurl"];
    if ([contentImgurl isMemberOfClass:[NSNull class]] || contentImgurl == nil) {
        contentImgurl = @"";
    }
    contentImgurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,contentImgurl];
    NSString *imageKey = [NSString stringWithFormat:@"%ld_%@",row,contentImgurl];
    UIImageView *imageview = [imageCache objectForKey:imageKey];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:contentImgurl] placeholderImage:[UIImage imageNamed:@"index2"]];
        imageview = cell.userImage;
        [imageCache setObject:imageview forKey:imageKey];
    }
    cell.userImage = imageview;
    [cell addSubview:cell.userImage];
    
    NSString *manageNursingContentName = dict[@"manageNursingContentName"];
    if ([manageNursingContentName isMemberOfClass:[NSNull class]] || manageNursingContentName == nil) {
        manageNursingContentName = @"";
    }
    cell.serviceTitleLabel.text = manageNursingContentName;
    
    NSString *manageNursingContentContent = dict[@"manageNursingContentContent"];
    if ([manageNursingContentContent isMemberOfClass:[NSNull class]] || manageNursingContentContent == nil) {
        manageNursingContentContent = @"";
    }
    cell.peopleLabel.text = manageNursingContentContent;
    
    id contentRequired = dict[@"contentRequired"];
    if ([contentRequired isMemberOfClass:[NSNull class]]) {
        contentRequired = @"";
    }
    
    cell.numberLabel.text = [NSString stringWithFormat:@"已服务:  %ld次",[contentRequired integerValue]];
    
    id minMoney = dict[@"minMoney"];
    if ([minMoney isMemberOfClass:[NSNull class]]) {
        minMoney = @"";
    }
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[minMoney floatValue]];
         
         
    
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
