//
//  HePaitentInfoVC.m
//  nurseService
//
//  Created by HeDongMing on 2017/1/7.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HePaitentInfoVC.h"
#import "HeBaseTableViewCell.h"

@interface HePaitentInfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSArray *keyDataSource;
@property(strong,nonatomic)NSDictionary *userInfoDetailDict;

@end

@implementation HePaitentInfoVC
@synthesize tableview;
@synthesize dataSource;
@synthesize keyDataSource;
@synthesize userInfoDict;
@synthesize userInfoDetailDict;

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
        label.text = @"患者信息";
        [label sizeToFit];
        
        self.title = @"患者信息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getPaitentInfo];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@"姓名",@"性别",@"身份证号",@"年龄",@"监护人",@"联系电话",@"关系",@"地址",@"病史备注"];
    keyDataSource = @[@"protectedPersonName",@"protectedPersonSex",@"protectedPersonCard",@"protectedPersonAge",@"protectedPersonGuardian",@"protectedPersonPhone",@"protectedPersonNexus",@"protectedAddress",@"protectedPersonNote"];
}

- (void)initView
{
    [super initView];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)getPaitentInfo
{
    [self showHudInView:tableview hint:@"获取中..."];
    NSString *personId = userInfoDict[@"personId"];
    if ([personId isMemberOfClass:[NSNull class]] || personId == nil) {
        personId = @"";
    }
    NSDictionary * params = @{@"personId":personId};
    NSString *url = [NSString stringWithFormat:@"protected/selectprotectedbyid.action"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:url params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *respondDict = [NSMutableDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED) {
            NSLog(@"success");
            userInfoDetailDict = respondDict[@"json"];
            if ([userInfoDetailDict isMemberOfClass:[NSNull class]]) {
                userInfoDetailDict = nil;
            }
            [tableview reloadData];
        }else if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"400"]){
            NSLog(@"faile");
            [self.view makeToast:[NSString stringWithFormat:@"%@",[respondDict valueForKey:@"data"]] duration:1.2 position:@"center"];
        }
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self hideHud];
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
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
    
    static NSString *cellIndentifier = @"HeUserCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    NSString *title = dataSource[row];
    
    CGFloat titleX = 10;
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    CGFloat titleW = 80;
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textAlignment = NSTextAlignmentLeft;
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.text = [NSString stringWithFormat:@"%@",title];
    topicLabel.numberOfLines = 0;
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = textFont;
    topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [cell.contentView addSubview:topicLabel];
    
    textFont = [UIFont systemFontOfSize:15.0];
    CGFloat contentX = CGRectGetMaxX(topicLabel.frame) + 5;
    CGFloat contentY = 0;
    CGFloat contentH = cellSize.height;
    CGFloat contentW = SCREENWIDTH - contentX - 10;
    
    NSString *contentKey = keyDataSource[row];
    id content = userInfoDetailDict[contentKey];
    if ([content isMemberOfClass:[NSNull class]] || content == nil) {
        content = @"";
    }
    if ([contentKey isEqualToString:@"protectedPersonSex"]) {
        NSInteger sex = [content integerValue];
        if (sex == ENUM_SEX_Boy) {
            content = @"男";
        }
        else{
            content = @"女";
        }
    }
    else if([contentKey isEqualToString:@"protectedAddress"]){
        NSArray *protectedAddressArray = [content componentsSeparatedByString:@","];
        NSString *addressStr = nil;
        @try {
            addressStr = protectedAddressArray[2];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        content = addressStr;
    }
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.text = [NSString stringWithFormat:@"%@",title];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font = textFont;
    contentLabel.frame = CGRectMake(contentX, contentY, contentW, contentH);
    contentLabel.text = [NSString stringWithFormat:@"%@",content];
    [cell.contentView addSubview:contentLabel];
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
