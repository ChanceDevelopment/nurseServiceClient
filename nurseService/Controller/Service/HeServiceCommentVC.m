//
//  HeCommentVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//  服务评论控制器

#import "HeServiceCommentVC.h"
#import "HeCommentCell.h"
#import "DLNavigationTabBar.h"
#import "MLLabel.h"
#import "MLLabel+Size.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "HeServiceCommentCell.h"

@interface HeServiceCommentVC ()<UITableViewDataSource,UITableViewDelegate>
{
    //@"全部 0",@"好评 1",@"一般 2",@"不满意 3"
    NSInteger currentCommentType;
    NSInteger pageNum;
}
//视图列表
@property(strong,nonatomic)IBOutlet UITableView *tableview;
//筛选的背景view
@property(strong,nonatomic)IBOutlet UIView *filterBgView;
//顶部滑动选择的选择条
@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
//不同控制器传参数的变量
@property(strong,nonatomic)id parameter;
//护士的信息字典
@property(strong,nonatomic)NSDictionary *nurseInfoDict;
//存放图片的缓存区
@property(strong,nonatomic)NSCache *imageCache;
//存放评论的容器
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeServiceCommentVC
@synthesize tableview;
@synthesize filterBgView;
@synthesize parameter;
@synthesize nurseInfoDict;
@synthesize imageCache;
@synthesize dataSource;

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
        label.text = @"评论";
        [label sizeToFit];
        self.title = @"评论";
    }
    return self;
}

//筛选条，分别有：全部、好评、一般、不满意
-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"全部",@"好评",@"一般",@"不满意"]];
        self.navigationTabBar.sliderBackgroundColor = [UIColor clearColor];
        self.navigationTabBar.backgroundColor = [UIColor whiteColor];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        self.navigationTabBar.buttonNormalTitleColor = [UIColor grayColor];
        self.navigationTabBar.buttonSelectedTileColor = APPDEFAULTORANGE;
        
        CGFloat lineX = 30;
        CGFloat lineH = 1;
        CGFloat lineY = CGRectGetMaxY(self.navigationTabBar.frame) - 1;
        CGFloat lineW = CGRectGetWidth(self.navigationTabBar.frame) - 2 * lineX;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
        line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [self.navigationTabBar addSubview:line];
        
        __weak typeof(self) weakSelf = self;
        [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
            [weakSelf navigationDidSelectedControllerIndex:index];
        }];
    }
    return _navigationTabBar;
}

//滑动顶部的选择条的回调方法
#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
    currentCommentType = index;
    //初始化分页
    pageNum = -1;
    NSString *nurseid = nurseInfoDict[@"nurseId"];
    if ([nurseid isMemberOfClass:[NSNull class]] || nurseid == nil) {
        nurseid = @"";
    }
    //根据护士ID加载这个护士的服务评论
    [self loadCommentDataWihtNurseId:nurseid];
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
    //根据护士ID加载这个护士的服务评论
    [self loadCommentDataWihtNurseId:nurseid];
}

//初始化资源
- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    nurseInfoDict = parameter;
    pageNum = -1;
}

- (void)initView
{
    [super initView];
    [filterBgView addSubview:self.navigationTabBar];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    //下拉刷新的回调
    __weak HeServiceCommentVC *weakSelf = self;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        
        
    }];
    //上拉加载更多回调
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        
        
    }];
}
//结束刷新的回调
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

/*
 @brief 加载护士的评价，区别于加载某项服务的评价
 @param nurseId 护士的ID
 */
- (void)loadCommentDataWihtNurseId:(NSString *)nurseId
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectnurserated.action",BASEURL];
    NSString *type = [NSString stringWithFormat:@"%ld",currentCommentType];
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    //nurseid：护士的ID type：类型 //@"全部 0",@"好评 1",@"一般 2",@"不满意 3"
    //pageNum：当前页码
    NSDictionary * params  = @{@"nurseid":nurseId,@"type":type,@"pageNum":pageNumStr};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            id jsonObj = respondDict[@"json"];
            if ([jsonObj isMemberOfClass:[NSNull class]] || jsonObj == nil) {
                if ([jsonObj count] == 0 && pageNum != -1) {
                    pageNum--;
                }
                return;
            }
            //如果是刷新，先清除内容
            if (pageNum == -1) {
                [dataSource removeAllObjects];
            }
            else{
                //如果是加载更多，但是加载回来没有数据，恢复到上次加载的状态
                if ([jsonObj count] == 0) {
                    pageNum--;
                }
            }
            
            [dataSource addObjectsFromArray:jsonObj];
            //如果加载回来没有数据，则显示没有数据的图片
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                CGFloat imageX = (SCREENWIDTH - imageW) / 2.0;
                CGFloat imageY = 50;
                
                UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                imageview.frame = CGRectMake(imageX, imageY, imageW, imageH);
                [bgView addSubview:imageview];
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
            }
            else{
                tableview.backgroundView = nil;
            }
            [tableview reloadData];
        }
        else{
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                CGFloat imageX = (SCREENWIDTH - imageW) / 2.0;
                CGFloat imageY = 30;
                
                UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                imageview.frame = CGRectMake(imageX, imageY, imageW, imageH);
                [bgView addSubview:imageview];
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
            }
            else{
                tableview.backgroundView = nil;
            }
            [tableview reloadData];
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
//            [self showHint:data];
        }
    } failure:^(NSError* err){
        
    }];
}

//列表视图的各种代理方法
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
    static NSString *cellIndentifier = @"HeCommentCell";
    //对服务评论列表进行配置
    HeServiceCommentCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeServiceCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        
    }
    //每个服务评论
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    //评论人的头像
    NSString *contentImgurl = dict[@"userHeader"];
    if ([contentImgurl isMemberOfClass:[NSNull class]] || contentImgurl == nil) {
        contentImgurl = @"";
    }
    contentImgurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,contentImgurl];
    NSString *imageKey = [NSString stringWithFormat:@"%ld_%@",row,contentImgurl];
    UIImageView *imageview = [imageCache objectForKey:imageKey];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:contentImgurl] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
        imageview = cell.userImage;
        [imageCache setObject:imageview forKey:imageKey];
    }
    cell.userImage = imageview;
    [cell addSubview:cell.userImage];
    
    //评论人的昵称
    NSString *userNike = dict[@"userNike"];
    if ([userNike isMemberOfClass:[NSNull class]] || userNike == nil) {
        userNike = @"";
    }
    cell.phoneLabel.text = userNike;
    
    //评论护士的名称
    NSString *manageNursingContenName = dict[@"manageNursingContenName"];
    if ([manageNursingContenName isMemberOfClass:[NSNull class]] || manageNursingContenName == nil) {
        manageNursingContenName = @"";
    }
    cell.serviceLabel.text = [NSString stringWithFormat:@"护理项:  %@",manageNursingContenName];
    //评论内容
    NSString *commentContent = dict[@"evaluateContent"];
    if ([commentContent isMemberOfClass:[NSNull class]] || commentContent == nil) {
        commentContent = @"";
    }
    cell.commentContentLabel.text = commentContent;
    //评论等级
    id evaluateMark = dict[@"evaluateMark"];
    if ([evaluateMark isMemberOfClass:[NSNull class]]) {
        evaluateMark = @"";
    }
    cell.commentRank = [evaluateMark integerValue];
    //评论时间
    id zoneCreatetimeObj = [dict objectForKey:@"evaluateCreatetime"];
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
    cell.timeLabel.text = time;
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"section = %ld , row = %ld",section,row);
    
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
