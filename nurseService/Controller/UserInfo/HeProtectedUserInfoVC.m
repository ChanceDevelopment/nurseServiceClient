//
//  HeProtectedUserInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeProtectedUserInfoVC.h"
#import "HeProtectUserInfoTableCell.h"
#import "HeEditProtectUserInfoVC.h"
#import "AFHttpTool.h"
#import "HeEditProtectUserInfoVC.h"

@interface HeProtectedUserInfoVC ()
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeProtectedUserInfoVC
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
        label.text = @"被受护人信息";
        [label sizeToFit];
        self.title = @"被受护人信息";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getDataSource];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = APPDEFAULTTABLEBACKGROUNDCOLOR;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserInfo:) name:kAddProtectedUserInfoNotification object:nil];
}

- (void)initView
{
    [super initView];
}

- (void)addUserInfo:(NSNotification *)notification
{
    NSLog(@"addUserInfo");
    [self getDataSource];
}

- (IBAction)addProtectUserInfo:(id)sender
{
    HeEditProtectUserInfoVC *editProtectUserInfoVC = [[HeEditProtectUserInfoVC alloc] init];
    editProtectUserInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editProtectUserInfoVC animated:YES];
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeProtectUserInfoTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeProtectUserInfoTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeProtectUserInfoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *name = [dict valueForKey:@"protectedPersonName"];
    NSString *sex = [[dict valueForKey:@"protectedPersonName"] isEqualToString:@"1"] ? @"男" : @"女";
    NSString *phone = [dict valueForKey:@"protectedPersonPhone"];
    BOOL isDefault = [[dict valueForKey:@"protectedDefault"] isEqualToString:@"1"] ? YES : NO;
    
    cell.baseInfoLabel.text = [NSString stringWithFormat:@"%@  %@  %@",name,sex,phone];
    cell.addressLabel.text = [dict valueForKey:@"protectedAddress"];
    cell.defaultLabel.text = isDefault ? @"默认信息" : @"设为默认";
    cell.selectBt.selected = isDefault ? YES : NO;
    
    cell.deleteBlock = ^(){
        NSLog(@"deleteBlock");
        [self deletProtectedUserInfoWithId:[dict valueForKey:@"protectedPersonId"]];
    };
    cell.editBlock = ^(){
        NSLog(@"edit");
        HeEditProtectUserInfoVC *heEditProtectUserInfoVC = [[HeEditProtectUserInfoVC alloc] init];
        heEditProtectUserInfoVC.hidesBottomBarWhenPushed = YES;
        heEditProtectUserInfoVC.userInfoDict = dict;
        [self.navigationController pushViewController:heEditProtectUserInfoVC animated:YES];
        
    };

    return  cell;
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
    [_selectDelegate selectUserInfoWithDict:dict];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getDataSource{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];

    NSString *requestUrl = [NSString stringWithFormat:@"%@/protected/selectprotectedbyuserid.action",BASEURL];
    NSDictionary * params  = @{@"userid": userid};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");
            NSArray *tempArr = [NSArray arrayWithArray:[respondDict valueForKey:@"json"]];
            if (dataSource.count > 0) {
                [dataSource addObjectsFromArray:tempArr];
                [tableview reloadData];
            }
        }else{
            NSString *errorInfo = [respondDict valueForKey:@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
            NSLog(@"faile");
        }
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}

- (void)deletProtectedUserInfoWithId:(NSString *)userId{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/address/deladdressbyid.action",BASEURL];

    NSDictionary * params  = @{@"addressid": userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");
            [self showHint:[respondDict valueForKey:@"data"]];
            [self getDataSource];
        }else{
            NSString *errorInfo = [respondDict valueForKey:@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
            NSLog(@"faile");
        }
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
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
