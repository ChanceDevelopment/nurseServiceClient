//
//  HeProtectedUserInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeSelectProtectedUserInfoVC.h"
#import "HeProtectUserInfoTableCell.h"
#import "HeEditProtectUserInfoVC.h"
#import "AFHttpTool.h"
#import "HeEditProtectUserInfoVC.h"
#import "HeSelectProtectedUserInfoCell.h"

@interface HeSelectProtectedUserInfoVC ()
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeSelectProtectedUserInfoVC
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
        label.text = @"受护人信息";
        [label sizeToFit];
        self.title = @"受护人信息";
        
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
    [dataSource removeAllObjects];
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
    return dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    HeSelectProtectedUserInfoCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeSelectProtectedUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *name = [dict valueForKey:@"protectedPersonName"];
    NSString *sex = [[dict valueForKey:@"protectedPersonSex"] isEqualToString:@"1"] ? @"男" : @"女";
    NSString *protectedPersonAge = [dict valueForKey:@"protectedPersonAge"];
    
    CGFloat baseInfoLabelX = 10;
    CGFloat baseInfoLabelY = 10;
    CGFloat baseInfoLabelW = SCREENWIDTH - 2 * baseInfoLabelX;
    CGFloat baseInfoLabelH = 30;
    UILabel *baseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(baseInfoLabelX, baseInfoLabelY, baseInfoLabelW, baseInfoLabelH)];
    baseInfoLabel.backgroundColor = [UIColor clearColor];
    baseInfoLabel.textColor = [UIColor blackColor];
    baseInfoLabel.font = [UIFont systemFontOfSize:15.0];
    baseInfoLabel.text = [NSString stringWithFormat:@"%@  %@  %@",name,sex,protectedPersonAge];
    [cell addSubview:baseInfoLabel];
    
    NSString *protectedAddress = dict[@"protectedAddress"];
    if ([protectedAddress isMemberOfClass:[NSNull class]]) {
        protectedAddress = @"";
    }
    
    CGFloat addressInfoLabelX = 10;
    CGFloat addressInfoLabelY = CGRectGetMaxY(baseInfoLabel.frame);
    CGFloat addressInfoLabelW = SCREENWIDTH - 2 * baseInfoLabelX;
    CGFloat addressInfoLabelH = 30;
    UILabel *addressInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressInfoLabelX, addressInfoLabelY, addressInfoLabelW, addressInfoLabelH)];
    addressInfoLabel.backgroundColor = [UIColor clearColor];
    addressInfoLabel.textColor = [UIColor blackColor];
    addressInfoLabel.font = [UIFont systemFontOfSize:15.0];
    addressInfoLabel.text = protectedAddress;
    [cell addSubview:addressInfoLabel];
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    return 80;
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
            
            NSArray *tempArr = [respondDict valueForKey:@"json"];
            if ([tempArr isMemberOfClass:[NSNull class]] || tempArr == nil) {
                tempArr = [NSArray array];
            }
            [dataSource addObjectsFromArray:tempArr];
            
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
