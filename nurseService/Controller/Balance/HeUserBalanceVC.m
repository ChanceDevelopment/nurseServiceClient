//
//  HeUserBalanceVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserBalanceVC.h"
#import "HeBaseTableViewCell.h"

@interface HeUserBalanceVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UILabel *balanceLabel;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSArray *iconDataSource;


@end

@implementation HeUserBalanceVC
@synthesize balanceLabel;
@synthesize tableview;
@synthesize dataSource;
@synthesize iconDataSource;
@synthesize userInfo;


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
        label.text = @"我的资金";
        [label sizeToFit];
        self.title = @"我的资金";
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
    dataSource = @[@[@"提现",@"充值",@"绑定支付宝",@"设置支付密码",@"交易明细"]];
    iconDataSource = @[@[@"icon_recharge",@"icon_withdrawals",@"icon_bind_alipay",@"icon_set_paypwd",@"icon_financial_details"]];
}

- (void)initView
{
    [super initView];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    
    CGFloat balanceNum = [userInfo.userBalance floatValue];
    balanceLabel.text = [NSString stringWithFormat:@"%.2f元",balanceNum];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGFloat iconH = 25;
    CGFloat iconW = 25;
    CGFloat iconX = 10;
    CGFloat iconY = (cellSize.height - iconH) / 2.0;
    NSString *image = iconDataSource[section][row];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [cell.contentView addSubview:icon];
    
    NSString *title = dataSource[section][row];
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = iconX + iconW + 10;
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    CGFloat titleW = 200;
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textAlignment = NSTextAlignmentLeft;
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.text = title;
    topicLabel.numberOfLines = 0;
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = textFont;
    topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [cell.contentView addSubview:topicLabel];
    
    
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (sec) {
//        <#statements#>
//    }
//    return 10.0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSLog(@"row = %ld, section = %ld",row,section);
    
    
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
