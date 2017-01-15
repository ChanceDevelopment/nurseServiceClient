//
//  NurseViewController.m
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "NurseViewController.h"
#import "DropDownListView.h"
#import "HeNurseTableViewCell.h"
#import "DOPDropDownMenu.h"
#import "HeNurseDetailVC.h"
#import "HeSearchInfoVC.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "MLLabel+Size.h"
#import "MLLabel.h"

@interface NurseViewController ()<UITableViewDelegate,UITableViewDataSource,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>
{
    NSString *hospitalNameID;
    NSString *majorNameID;
    NSString *latitude;
    NSString *longitude;
    NSInteger pageNum;
}
@property (nonatomic, strong) NSArray *classifys;
@property (nonatomic, strong) NSArray *cates;
@property (nonatomic, strong) NSArray *movices;
@property (nonatomic, strong) NSArray *hostels;
@property (nonatomic, strong) NSArray *areas;

@property(strong,nonatomic)NSCache *imageCache;

@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, weak) DOPDropDownMenu *menu;

@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *chooseArray;
@property(strong,nonatomic)NSMutableArray *currentClassArray;
@property(strong,nonatomic)IBOutlet UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource;
//医院分类数据
@property(strong,nonatomic)NSMutableArray *hospitalNameArray;  //医院名字
@property(strong,nonatomic)NSMutableArray *subHospitalNameArray;  //医院名字
@property(strong,nonatomic)NSMutableArray *hospitalModelArray;   //模型，包括一些医院的ID，医院名字
@property(strong,nonatomic)NSMutableArray *subHospitalModelArray;

//专业分类数据
@property(strong,nonatomic)NSMutableArray *majorNameArray;  //专业名字
@property(strong,nonatomic)NSMutableArray *subMajorNameArray;
@property(strong,nonatomic)NSMutableArray *majorModelArray;
@property(strong,nonatomic)NSMutableArray *subMajorModelArray;

@end

@implementation NurseViewController
@synthesize tableview;
@synthesize currentClassArray;
@synthesize sectionHeaderView;
@synthesize chooseArray;
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
        label.text = @"护士";
        [label sizeToFit];
        self.title = @"护士";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    //加载护士数据
    [self loadNurseData];
}

- (void)initializaiton
{
    [super initializaiton];
    //初始化分类数据
    [self initCategoryData];
    _imageCache = [[NSCache alloc] init];
    chooseArray = [[NSMutableArray alloc] initWithCapacity:0];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    hospitalNameID = @"";
    majorNameID = @"";
    latitude = [[HeSysbsModel getSysModel].userLocationDict objectForKey:@"longitude"];
    if (!latitude) {
        latitude = @"";
    }
    longitude = [[HeSysbsModel getSysModel].userLocationDict objectForKey:@"latitude"];
    if (!longitude) {
        longitude = @"";
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCategoryData) name:kLoadHospitalDataNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCategoryData) name:kLoadMajorDataNotification object:nil];
}

- (void)initView
{
    [super initView];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [self initSelectView];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [searchButton addTarget:self action:@selector(searchOrder) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"icon_search_white"] forState:UIControlStateNormal];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [scanButton addTarget:self action:@selector(scanOrder) forControlEvents:UIControlEventTouchUpInside];
    [scanButton setBackgroundImage:[UIImage imageNamed:@"icon_scan_white"] forState:UIControlStateNormal];
    
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    
    self.navigationItem.rightBarButtonItems = @[searchItem];
    
    __weak NurseViewController *weakSelf = self;
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [weakSelf.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum = 0;
        [weakSelf loadNurseData];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [weakSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        pageNum++;
        [weakSelf loadNurseData];
        
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

- (void)initSelectView
{
    // 添加下拉菜单
    DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:40];
    menu.delegate = self;
    menu.dataSource = self;
    [self.view addSubview:menu];
    _menu = menu;
    
    // 创建menu 第一次显示 不会调用点击代理，可以用这个手动调用
    [menu selectDefalutIndexPath];
}


- (void)initCategoryData
{
    _hospitalNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    _hospitalModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    _majorNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    _majorModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    _subHospitalNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    _subHospitalModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    _subMajorNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    _subMajorModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([[HeSysbsModel getSysModel].hospitalArray count] == 0) {
        //没有请求道网络数据，从本地获取数据
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"categoryData" ofType:@"plist"];
        NSDictionary *catagoryDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        
        NSString *respondString = catagoryDict[@"hospital"];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSArray *menuArray = [[NSArray alloc] initWithArray:[respondDict valueForKey:@"json"]];
            if ([[HeSysbsModel getSysModel].hospitalArray count] == 0) {
                [HeSysbsModel getSysModel].hospitalArray = [[NSArray alloc] initWithArray:menuArray];
            }
        }
        
        respondString = catagoryDict[@"major"];
        respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSArray *menuArray = [[NSArray alloc] initWithArray:[respondDict valueForKey:@"json"]];
            if ([[HeSysbsModel getSysModel].majorArray count] == 0) {
                [HeSysbsModel getSysModel].majorArray = [[NSArray alloc] initWithArray:menuArray];
            }
        }
    }
    
    //初始化医院数据
    NSDictionary *allHospitalDict = @{@"hospitalId":@"",@"hospitalName":@"全部医院",@"hospitalProvince":@"",@"hospitalCity":@"",@"hospitalDistrict":@"",@"hospitalAddress":@"",@"hospitalPhone":@"",@"hospitalCreateter":@"",@"hospitalCreatetime":@"",@"maj":[NSArray array]};
    
    
    _hospitalModelArray = [[NSMutableArray alloc] initWithArray:[HeSysbsModel getSysModel].hospitalArray];
    [_hospitalModelArray insertObject:allHospitalDict atIndex:0];
    
    //初始化专业数据
    NSDictionary *allMajorDict = @{@"majorId":@"",@"majorName":@"全部专业",@"majorNote":@"",@"majorDetails":@"",@"majorCreateter":@"",@"majorCteatetime":@"",@"hbt":[NSArray array]};
    _majorModelArray = [[NSMutableArray alloc] initWithArray:[HeSysbsModel getSysModel].majorArray];
    [_majorModelArray insertObject:allMajorDict atIndex:0];

    for (NSDictionary *dict in _hospitalModelArray) {
        NSString *hospitalName = dict[@"hospitalName"];
        if ([hospitalName isMemberOfClass:[NSNull class]] || hospitalName == nil) {
            hospitalName = @"未知医院";
        }
        [_hospitalNameArray addObject:hospitalName];
        
        NSMutableArray *subModelArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *subNameArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        id maj = dict[@"maj"];
        NSArray *array = nil;
        if ([maj isKindOfClass:[NSString class]]) {
            if ([maj isMemberOfClass:[NSNull class]] || maj == nil) {
                maj = @"";
            }
            array = [maj objectFromJSONString];
        }
        if (!array) {
            array = [NSArray array];
        }
        
        NSDictionary *subAllDict = @{@"majorName":@"全部",@"majorId":@""};
        [subModelArray addObject:subAllDict];
        
        [subNameArray addObject:@"全部"];
        
        for (NSDictionary *subDict in array) {
            NSString *majorName = subDict[@"majorName"];
            if ([majorName isMemberOfClass:[NSNull class]]) {
                majorName = @"未知专业";
            }
            [subNameArray addObject:majorName];
            [subModelArray addObject:subDict];
        }
        [_subHospitalModelArray addObject:subModelArray];
        [_subHospitalNameArray addObject:subNameArray];
    }
    
    for (NSDictionary *dict in _majorModelArray) {
        NSString *majorName = dict[@"majorName"];
        if ([majorName isMemberOfClass:[NSNull class]] || majorName == nil) {
            majorName = @"未知专业";
        }
        [_majorNameArray addObject:majorName];
        
        NSMutableArray *subModelArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *subNameArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        id hbt = dict[@"hbt"];
        NSArray *array = nil;
        if ([hbt isKindOfClass:[NSString class]]) {
            if ([hbt isMemberOfClass:[NSNull class]] || hbt == nil) {
                hbt = @"";
            }
            array = [hbt objectFromJSONString];
        }
        
        if (!array) {
            array = [NSArray array];
        }
        
        NSDictionary *subAllDict = @{@"hospitalsName":@"全部",@"hospitalsrId":@""};
        [subModelArray addObject:subAllDict];
        
        [subNameArray addObject:@"全部"];
        
        for (NSDictionary *subDict in array) {
            NSString *hospitalsName = subDict[@"hospitalsName"];
            if ([hospitalsName isMemberOfClass:[NSNull class]] || hospitalsName == nil) {
                hospitalsName = @"未知医院";
            }
            [subNameArray addObject:hospitalsName];
            [subModelArray addObject:subDict];
        }
        [_subMajorModelArray addObject:subModelArray];
        [_subMajorNameArray addObject:subNameArray];
    }
    [_menu reloadData];
    
}

- (void)loadNurseData
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectnursebyhosandmaj.action",BASEURL];
    NSString *pageNumStr = [NSString stringWithFormat:@"%ld",pageNum];
    NSDictionary * params  = @{@"hospitalName":hospitalNameID,@"majorName":majorNameID,@"latitude":latitude,@"longitude":longitude,@"pageNum":pageNumStr};
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

- (void)searchOrder
{
    NSLog(@"searchOrder");
    HeSearchInfoVC *searchInfoVC = [[HeSearchInfoVC alloc] init];
    searchInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchInfoVC animated:YES];
}

- (void)scanOrder
{
    NSLog(@"scanOrder");
}

- (void)menuReloadData
{
    [self initCategoryData];
    [_menu reloadData];
}

- (IBAction)selectIndexPathAction:(id)sender {
    [_menu selectIndexPath:[DOPIndexPath indexPathWithCol:0 row:2 item:2]];
}

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu
{
    //列数
    return 2;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    //返回各列的主分类数量
    if (column == 0) {
        return _hospitalNameArray.count;
    }else if (column == 1){
        return _majorNameArray.count;
    }
    return 0;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    //返回各列的标题
    if (indexPath.column == 0) {
        return _hospitalNameArray[indexPath.row];
    } else if (indexPath.column == 1){
        return _majorNameArray[indexPath.row];
    }
    return nil;
}

// new datasource

- (NSString *)menu:(DOPDropDownMenu *)menu imageNameForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    //主分类图片
//    if (indexPath.column == 0 || indexPath.column == 1) {
//        return [NSString stringWithFormat:@"ic_filter_category_%ld",indexPath.row];
//    }
    return nil;
}

- (NSString *)menu:(DOPDropDownMenu *)menu imageNameForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    //次分类图标
//    if (indexPath.column == 0 && indexPath.item >= 0) {
//        return [NSString stringWithFormat:@"ic_filter_category_%ld",indexPath.item];
//    }
    return nil;
}

// new datasource

- (NSString *)menu:(DOPDropDownMenu *)menu detailTextForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    //主分类显示数量
//    if (indexPath.column < 2) {
//        return [@(arc4random()%1000) stringValue];
//    }
    return nil;
}

- (NSString *)menu:(DOPDropDownMenu *)menu detailTextForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    //次分类显示数量
    return nil;
//    [@(arc4random()%1000) stringValue];
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column
{
    if (column == 0) {
        //第一列的子分类数量
        return [_subHospitalNameArray[row] count];
    }
    else if (column == 1){
        return [_subMajorNameArray[row] count];
    }
    return 0;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        //第一列的子分类标题
        return _subHospitalNameArray[indexPath.row][indexPath.item];
    }
    else if (indexPath.column == 1){
        return _subMajorNameArray[indexPath.row][indexPath.item];
    }
    return nil;
}

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.item >= 0) {
        //点击次分类
        NSLog(@"点击了 %ld - %ld - %ld 项目",indexPath.column,indexPath.row,indexPath.item);
        if (indexPath.column == 0) {
            
            NSLog(@"点击子医院是: %@",_subHospitalModelArray[indexPath.row][indexPath.item]);
        }
        else if (indexPath.column == 1){
            NSLog(@"点击子分类是: %@",_subMajorModelArray[indexPath.row][indexPath.item]);
        }
    }else {
        //点击主分类
        NSLog(@"点击了 %ld - %ld 项目",indexPath.column,indexPath.row);
        if (indexPath.column == 0) {
            NSLog(@"点击总医院是: %@",_hospitalModelArray[indexPath.row]);
        }
        else if (indexPath.column == 1){
            NSLog(@"点击总分类是: %@",_majorModelArray[indexPath.row]);
        }
        
    }
}


#pragma mark - TableView Delegate

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
    
    static NSString *cellIndentifier = @"HeNurseTableViewCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeNurseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeNurseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSString *nurseHeader = dict[@"nurseHeader"];
    if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
        nurseHeader = @"";
    }
    nurseHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,nurseHeader];
    NSString *nurseHeaderKey = [NSString stringWithFormat:@"%ld%ld_%@",section,row,nurseHeader];
    UIImageView *imageview = [_imageCache objectForKey:nurseHeaderKey];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
