//
//  HeSelectProtectUserAddressVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeSelectProtectUserAddressVC.h"
#import "HeAddProtectUserAddressVC.h"
#import "HeBaseTableViewCell.h"

@interface HeSelectProtectUserAddressVC ()
{
    NSMutableArray *dataSource;
    NSArray *sectionArr;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HeSelectProtectUserAddressVC
@synthesize tableView;

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
        label.text = @"选择受护地址";
        [label sizeToFit];
        self.title = @"选择受护地址";
        
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
    sectionArr = @[@"当前地址",@"开通地区",@"受护人地址"];
}

- (void)initView
{
    [super initView];
}

- (IBAction)addUserAddress:(id)sender
{
    HeAddProtectUserAddressVC *addProtectUserAddressVC = [[HeAddProtectUserAddressVC alloc] init];
    addProtectUserAddressVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addProtectUserAddressVC animated:YES];
}



#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 5;
            break;
        default:
            break;
    }
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    
    static NSString *cellIndentifier = @"OrderFinishedTableViewCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
//    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:infoDic];
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (section) {
        case 0:
        {
            UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, cellSize.height)];
            addressLabel.backgroundColor = [UIColor clearColor];
            addressLabel.numberOfLines = 0;
            addressLabel.text = @"中国浙江";
            addressLabel.font = [UIFont systemFontOfSize:15.0];
            addressLabel.textColor = [UIColor blackColor];
            [cell addSubview:addressLabel];
        }
            break;
        case 1:
        {
            UIButton *addressBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 50, 25)];
            [addressBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [addressBt setTitle:@"杭州" forState:UIControlStateNormal];
            addressBt.layer.cornerRadius = 4.0;//2.0是圆角的弧度，根据需求自己更改
            addressBt.layer.borderWidth = 1.0f;
            addressBt.layer.borderColor = [[UIColor colorWithRed:152.0 / 255.0 green:67.0 / 255.0 blue:141.0 / 255.0 alpha:1.0] CGColor];
//            [addressBt addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
            addressBt.backgroundColor = [UIColor clearColor];
            [cell addSubview:addressBt];

        }
            break;
        case 2:
        {
            UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cellSize.width-20, 44)];
            userInfoLabel.backgroundColor = [UIColor clearColor];
            userInfoLabel.text = @"艾米 女士 2345678909";
            userInfoLabel.font = [UIFont systemFontOfSize:15.0];
            userInfoLabel.textColor = [UIColor blackColor];
            [cell addSubview:userInfoLabel];
            
            UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, cellSize.width-20, 44)];
            addressLabel.backgroundColor = [UIColor clearColor];
            addressLabel.text = @"中国浙江";
            addressLabel.font = [UIFont systemFontOfSize:15.0];
            addressLabel.textColor = [UIColor blackColor];
            [cell addSubview:addressLabel];
            
        }
            break;
            
        default:
            break;
    }

    return cell;
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
            return 50;
            break;
        case 1:
            return 90;
            break;
        case 2:
            return 90;
            break;
        default:
            break;
    }
    
    return 160;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *v = nil;

    v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    v.userInteractionEnabled = YES;
    [v setBackgroundColor:[UIColor colorWithWhite:244.0 / 255.0 alpha:1.0]];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 200.0f, 30.0f)];
    [labelTitle setBackgroundColor:[UIColor clearColor]];
    labelTitle.text = sectionArr[section];
    labelTitle.userInteractionEnabled = YES;
    labelTitle.font = [UIFont systemFontOfSize:12.0];
    labelTitle.textColor = [UIColor lightGrayColor];
    [v addSubview:labelTitle];
    return v;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSLog(@"row = %ld, section = %ld",row,section);
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
                [tableView reloadData];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
