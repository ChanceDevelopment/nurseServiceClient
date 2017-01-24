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
#import "HeSelectProtectedUserInfoCell.h"

@interface HeSelectProtectUserAddressVC ()<AddProtectUserAddressProtocol>
{
    NSArray *sectionArr;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeSelectProtectUserAddressVC
@synthesize tableView;
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
    [self getDataSource];
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
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
            [dataSource removeAllObjects];
            [dataSource addObjectsFromArray:tempArr];
            
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                CGFloat imageX = (SCREENWIDTH - imageW) / 2.0;
                CGFloat imageY = SCREENHEIGH - imageH - 100;
                UIImageView *imageview = [[UIImageView alloc] initWithImage:noImage];
                imageview.frame = CGRectMake(imageX, imageY, imageW, imageH);
                imageview.center = bgView.center;
                [bgView addSubview:imageview];
                tableView.backgroundView = bgView;
            }
            else{
                tableView.backgroundView = nil;
            }
            
            [tableView reloadData];
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

- (void)addProtectUserAddressWithAddressInfo:(NSDictionary *)addressInfo
{
    NSString *protectedAddress = addressInfo[@"address"];
    if ([protectedAddress isMemberOfClass:[NSNull class]]) {
        protectedAddress = @"";
    }
    NSDictionary *addressDict = @{@"address":protectedAddress};
    [_addressDeleage selectAddressWithAddressInfo:addressDict];
    
    NSArray *viewControllers =  self.navigationController.viewControllers;
    UIViewController *popVC = nil;
    NSInteger targetIndex = [viewControllers count] - 1;
    for (NSInteger index = 0; index < [viewControllers count]; index++) {
        UIViewController *vc = viewControllers[index];
        if ([vc isKindOfClass:[HeSelectProtectUserAddressVC class]]) {
            targetIndex = index;
            break;
        }
    }
    if (targetIndex > 0) {
        targetIndex = targetIndex - 1;
    }
    popVC = viewControllers[targetIndex];
    
    [self.navigationController popToViewController:popVC animated:YES];
}

- (IBAction)addUserAddress:(id)sender
{
    HeAddProtectUserAddressVC *addProtectUserAddressVC = [[HeAddProtectUserAddressVC alloc] init];
    addProtectUserAddressVC.addressDelegate = self;
    addProtectUserAddressVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addProtectUserAddressVC animated:YES];
}

- (void)relocationButtonClick:(UIButton *)button
{
    [tableView reloadData];
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
            return [dataSource count];
            break;
        default:
            break;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    
    
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    switch (section) {
        case 0:
        {
            static NSString *cellIndentifier = @"HeBaseTableViewCell";
            HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            CGFloat addressIconX = 10;
            CGFloat addressIconW = 25;
            CGFloat addressIconH = 25;
            CGFloat addressIconY = (cellSize.height - addressIconH) / 2.0;
            UIImageView *addressIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_address"]];
            addressIcon.frame = CGRectMake(addressIconX, addressIconY, addressIconW, addressIconH);
            [cell addSubview:addressIcon];
            
            NSString *currentAddress = [HeSysbsModel getSysModel].addressResult.address;
            CGFloat addressLabelX = CGRectGetMaxX(addressIcon.frame);
            CGFloat addressLabelY = 0;
            CGFloat addressLabelW = SCREENWIDTH - addressLabelX - 110;
            CGFloat addressLabelH = cellSize.height;
            
            UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressLabelX, addressLabelY, addressLabelW, addressLabelH)];
            addressLabel.numberOfLines = 2;
            addressLabel.backgroundColor = [UIColor clearColor];
            addressLabel.text = currentAddress;
            addressLabel.font = [UIFont systemFontOfSize:13.0];
            addressLabel.textColor = [UIColor blackColor];
            [cell addSubview:addressLabel];
            
            
            CGFloat relocationButtonY = 0;
            CGFloat relocationButtonH = cellSize.height;
            CGFloat relocationButtonW = 80;
            CGFloat relocationButtonX = SCREENWIDTH - relocationButtonW - 10;
            
            UIButton *relocationButton = [[UIButton alloc] initWithFrame:CGRectMake(relocationButtonX, relocationButtonY, relocationButtonW, relocationButtonH)];
            [relocationButton setTitle:@"重新定位" forState:UIControlStateNormal];
            relocationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [relocationButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
            relocationButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [relocationButton addTarget:self action:@selector(relocationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:relocationButton];
            
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_purple_reposition"]];
            image.frame = CGRectMake(0, (cellSize.height - 20) / 2.0, 20, 20);
            [relocationButton addSubview:image];
            
            return cell;
        }
            break;
        case 1:
        {
            static NSString *cellIndentifier = @"HeBaseTableViewCell";
            HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            UIButton *addressBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 25)];
            [addressBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [addressBt setTitle:@"杭州" forState:UIControlStateNormal];
            addressBt.layer.cornerRadius = 4.0;//2.0是圆角的弧度，根据需求自己更改
            addressBt.layer.borderWidth = 1.0f;
            addressBt.titleLabel.font = [UIFont systemFontOfSize:15.0];
            addressBt.layer.borderColor = APPDEFAULTORANGE.CGColor;
            addressBt.backgroundColor = [UIColor clearColor];
            [cell addSubview:addressBt];

            return cell;
        }
            break;
        case 2:
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
            break;
            
        default:
            break;
    }

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
            return 45;
            break;
        case 2:
            return 80;
            break;
        default:
            break;
    }
    
    return 160;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *v = nil;

    v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    v.userInteractionEnabled = YES;
    [v setBackgroundColor:[UIColor colorWithWhite:244.0 / 255.0 alpha:1.0]];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 200.0f, 40)];
    [labelTitle setBackgroundColor:[UIColor clearColor]];
    labelTitle.text = sectionArr[section];
    labelTitle.userInteractionEnabled = YES;
    labelTitle.font = [UIFont systemFontOfSize:13.0];
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
    if (section == 2) {
        NSDictionary *dict = nil;
        @try {
            dict = dataSource[row];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        NSString *protectedAddress = dict[@"protectedAddress"];
        if ([protectedAddress isMemberOfClass:[NSNull class]]) {
            protectedAddress = @"";
        }
        NSDictionary *addressDict = @{@"address":protectedAddress};
        [_addressDeleage selectAddressWithAddressInfo:addressDict];
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
