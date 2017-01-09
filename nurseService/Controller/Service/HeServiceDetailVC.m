//
//  HeServiceDetailVC.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeServiceDetailVC.h"
#import "DLNavigationTabBar.h"
#import "HeBaseTableViewCell.h"
#import "LBBanner.h"
#import "MLLabel+Size.h"

@interface HeServiceDetailVC ()<UITableViewDelegate,UITableViewDataSource,LBBannerDelegate>

@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)IBOutlet UIView *footerBGView;

@end

@implementation HeServiceDetailVC
@synthesize tableview;
@synthesize footerBGView;

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
        label.text = @"服务详情";
        [label sizeToFit];
        self.title = @"服务详情";
        
    }
    return self;
}

-(DLNavigationTabBar *)navigationTabBar
{
    if (!_navigationTabBar) {
        self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:@[@"服务内容",@"适用人群",@"注意事项"]];
        self.navigationTabBar.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        self.navigationTabBar.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        self.navigationTabBar.sliderBackgroundColor = APPDEFAULTORANGE;
        self.navigationTabBar.buttonNormalTitleColor = [UIColor grayColor];
        self.navigationTabBar.buttonSelectedTileColor = APPDEFAULTORANGE;
        __weak typeof(self) weakSelf = self;
        [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
            [weakSelf navigationDidSelectedControllerIndex:index];
        }];
    }
    return _navigationTabBar;
}

#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index {
    NSLog(@"index = %ld",index);
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
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    CGFloat headerHeight = 180;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    headerView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.tableHeaderView = headerView;
    
    CGFloat bannerHeight = 180;
    NSArray * imageNames = @[@"index1", @"index2"];
    LBBanner * banner = [[LBBanner alloc] initWithImageNames:imageNames andFrame:CGRectMake(0, 0, SCREENWIDTH, bannerHeight)];
    banner.delegate = self;
    
    [headerView addSubview:banner];
    
    
}

- (IBAction)phoneCall:(id)sender
{
    NSLog(@"phoneCall");
}

- (IBAction)favButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    NSLog(@"favButtonClick");
}
//加入预约框
- (IBAction)addToBookItem:(id)sender
{
    NSLog(@"addToBookItem");
}
//立即预约
- (IBAction)bookService:(id)sender
{
    NSLog(@"bookService");
}

#pragma mark LBBannerDelegate
- (void)banner:(LBBanner *)banner didClickViewWithIndex:(NSInteger)index {
    NSLog(@"didClickViewWithIndex:%ld", index);
}

- (void)banner:(LBBanner *)banner didChangeViewWithIndex:(NSInteger)index {
    NSLog(@"didChangeViewWithIndex:%ld", index);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    static NSString *cellIndentifier = @"HeInfoTableViewCell";
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        
    }
    NSDictionary *dict = nil;
    switch (section) {
        case 0:
        {
            CGFloat titleLabelX = 10;
            CGFloat titleLabelY = 0;
            CGFloat titleLabelH = cellsize.height;
            CGFloat titleLabelW = 100;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
            titleLabel.font = [UIFont systemFontOfSize:18.0];
            titleLabel.text = @"新生儿护理";
            [cell addSubview:titleLabel];
            
            
            CGFloat endLabelY = 0;
            CGFloat endLabelH = cellsize.height;
            CGFloat endLabelW = 100;
            CGFloat endLabelX = SCREENWIDTH - endLabelW - 10;
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(endLabelX, endLabelY, endLabelW, endLabelH)];
            endLabel.font = [UIFont systemFontOfSize:15.0];
            endLabel.textColor = [UIColor redColor];
            endLabel.textAlignment = NSTextAlignmentRight;
            endLabel.text = @"￥300.00起";
            [cell addSubview:endLabel];
            
            break;
        }
        case 1:{
            switch (row) {
                case 0:
                {
                    //服务时间
                    cell.textLabel.text = @"服务时间";
                    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    CGFloat titleLabelX = 10;
                    CGFloat titleLabelY = 0;
                    CGFloat titleLabelH = cellsize.height / 2.0;
                    CGFloat titleLabelW = 100;
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    titleLabel.font = [UIFont systemFontOfSize:15.0];
                    titleLabel.text = @"被保护人信息";
                    [cell addSubview:titleLabel];
                    
                    NSString *infoString = @"小明 男 15768580734";
                    CGSize size = [MLLabel getViewSizeByString:infoString maxWidth:SCREENWIDTH - 30 - titleLabelW font:[UIFont systemFontOfSize:15.0] lineHeight:1.2 lines:0];
                    titleLabelW = size.width;
                    titleLabelX = SCREENWIDTH - titleLabelW - 30;
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    nameLabel.textAlignment = NSTextAlignmentRight;
                    nameLabel.font = [UIFont systemFontOfSize:15.0];
                    nameLabel.text = @"小明 男 15768580734";
                    nameLabel.textColor = [UIColor  grayColor];
                    [cell addSubview:nameLabel];
                    
                    titleLabelX = 10;
                    titleLabelW = SCREENWIDTH - titleLabelX - 30;
                    titleLabelY = CGRectGetMaxY(nameLabel.frame);
                    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    addressLabel.textAlignment = NSTextAlignmentRight;
                    addressLabel.font = [UIFont systemFontOfSize:15.0];
                    addressLabel.textColor = [UIColor  grayColor];
                    addressLabel.text = @"中国广东省中山市西区";
                    [cell addSubview:addressLabel];
                    
                    break;
                }
                case 2:
                {
                    UIImage *image_picc = [UIImage imageNamed:@"icon_picc"];
                    CGFloat imageViewX = 5;
                    CGFloat imageViewY = 15;
                    CGFloat imageViewH = cellsize.height - 2 * imageViewY;
                    CGFloat imageViewW = imageViewH / image_picc.size.height * image_picc.size.width;
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_picc"]];
                    imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
                    [cell addSubview:imageView];
                    
                    CGFloat titleLabelX = CGRectGetMaxX(imageView.frame) + 5;
                    CGFloat titleLabelY = 0;
                    CGFloat titleLabelH = cellsize.height;
                    CGFloat titleLabelW = 150;
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
                    titleLabel.textColor = [UIColor grayColor];
                    titleLabel.font = [UIFont systemFontOfSize:13.0];
                    titleLabel.text = @"中国人寿为您保驾护航";
                    [cell addSubview:titleLabel];
                    
                    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_question"]];
                    icon.frame = CGRectMake(SCREENWIDTH - 20 - 10, (cellsize.height - 20) / 2.0, 20, 20);
                    [cell addSubview:icon];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && (row == 2 || row == 1)) {
        return 80;
    }
    return 44;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
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
