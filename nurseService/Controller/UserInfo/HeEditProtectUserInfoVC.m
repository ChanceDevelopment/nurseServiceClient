//
//  HeProtectedUserInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeEditProtectUserInfoVC.h"
#import "HeProtectUserInfoTableCell.h"
#import "HeEditProtectUserInfoVC.h"
#import "HeBaseTableViewCell.h"
#import "FTPopOverMenu.h"
#import "HeSelectProtectUserAddressVC.h"

@interface HeEditProtectUserInfoVC ()<UITextFieldDelegate,UIActionSheetDelegate,SelectAddressProtocol>
{
    //用户性别 男 1 女 2
    ENUM_SEXType userSex;
    NSMutableDictionary *postUserInfo;
    NSString *releation;
    NSString *userAddress;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *dataSource;

@end

@implementation HeEditProtectUserInfoVC
@synthesize tableview;
@synthesize dataSource;
@synthesize userInfoDict;
@synthesize isEdit;

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
        label.text = @"编辑信息";
        [label sizeToFit];
        self.title = @"编辑信息";
        
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
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = APPDEFAULTTABLEBACKGROUNDCOLOR;
    postUserInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    dataSource = @[@"姓名",@"性别",@"身份证号",@"年龄",@"联系电话",@"关系",@"地址",@"病史备注"];
    releation = @"自己";
    userSex = ENUM_SEX_Girl;
    id protectedPersonSex = userInfoDict[@"protectedPersonSex"];
    if ([protectedPersonSex isMemberOfClass:[NSNull class]] || protectedPersonSex == nil) {
        protectedPersonSex = @"";
    }
    if ([protectedPersonSex integerValue] == 1) {
        userSex = ENUM_SEX_Boy;
    }
    
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    tableview.tableFooterView = footerView;
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, 30)];
    tipLabel.font = [UIFont systemFontOfSize:13.0];
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.text = @"例：青霉素过敏、咽喉炎、长期感冒低热、肥胖";
    tipLabel.backgroundColor = [UIColor clearColor];
    [footerView addSubview:tipLabel];
}


- (IBAction)saveProtectUserInfo:(id)sender
{
    if (isEdit) {
        [self editProtectedUserInfo];
    }else{
        [self addProtectedUserInfo];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFocused]) {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textField.text:%@",textField.text);
    NSString *temp = textField.text;
    if (isEdit) {
        switch (textField.tag) {
            case 100:
                [userInfoDict setObject:temp forKey:@"protectedPersonName"];
                break;
            case 101:
                [userInfoDict setObject:temp forKey:@"protectedPersonSex"];
                break;
            case 102:
                [userInfoDict setObject:temp forKey:@"protectedPersonCard"];
                break;
            case 103:
                [userInfoDict setObject:temp forKey:@"protectedPersonAge"];
                break;
//            case 104:
//                [userInfoDict setObject:temp forKey:@"personGuardian"];
//                break;
            case 104:
                [userInfoDict setObject:temp forKey:@"protectedPersonPhone"];
                break;
            case 105:
                [userInfoDict setObject:temp forKey:@"protectedPersonNexus"];
                break;
            case 106:
                [userInfoDict setObject:temp forKey:@"protectedAddress"];
                break;
            case 107:
                [userInfoDict setObject:temp forKey:@"protectedPersonNote"];
                break;
            default:
                break;
        }
        
    }else{
        NSString *infoKey = [NSString stringWithFormat:@"key%ld",textField.tag];
        [postUserInfo setObject:temp forKey:infoKey];
    }
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
    }
    UIFont *textFont = [UIFont systemFontOfSize:15.0];
    NSString *title = dataSource[row];
    
    CGFloat titleX = 10;
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    if (row == [dataSource count] - 1) {
        titleH = 30;
    }
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
    
    textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat contentFieldY = 0;
    CGFloat contentFieldX = 80;
    CGFloat contentFieldW = cellSize.width - contentFieldX - 10;
    CGFloat contentFieldH = cellSize.height;
    
    
    UITextField *contentField = [[UITextField alloc] initWithFrame:CGRectMake(contentFieldX, contentFieldY, contentFieldW, contentFieldH)];
    contentField.delegate = self;
    contentField.font = textFont;
    contentField.textAlignment = NSTextAlignmentRight;
    contentField.tag = row + 100;
    
    NSString *infoKey = [NSString stringWithFormat:@"key%ld",contentField.tag];
    NSString *temp = [postUserInfo objectForKey:infoKey];
    contentField.text = temp;
    
    NSString *placeholder = @"";
    UIFont *contentFont = [UIFont systemFontOfSize:16.0];
    switch (row) {
        case 0:
        {
            //姓名
            placeholder = @"受保护人姓名";
            if (isEdit) {
                contentField.text  = [userInfoDict objectForKey:@"protectedPersonName"];
            }
            
            break;
        }
        case 1:
        {
            //性别
            CGFloat contentLabelX = 90;
            CGFloat contentLabelW = SCREENWIDTH - contentLabelX - 10;
            CGFloat contentLabelY = 0;
            CGFloat contentLabelH = cellSize.height;
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
            contentLabel.textAlignment = NSTextAlignmentRight;
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.font = contentFont;
            [cell addSubview:contentLabel];
            if (userSex == ENUM_SEX_Boy) {
                contentLabel.text = @"男";
            }
            else{
                contentLabel.text = @"女";
            }
            
            contentField.hidden = YES;
            if (isEdit) {
                contentField.text  = [[userInfoDict objectForKey:@"protectedPersonSex"] isEqualToString:@"1"] ? @"男" : @"女";
            }
            break;
        }
        case 2:
        {
            //身份证号
            placeholder = @"请输入身份证号";
            if (isEdit) {
                contentField.text  = [userInfoDict objectForKey:@"protectedPersonCard"];
            }
            contentField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case 3:
        {
            //年龄
            placeholder = @"请输入年龄";
            if (isEdit) {
                contentField.text  = [userInfoDict objectForKey:@"protectedPersonAge"];
            }
            contentField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
//        case 4:
//        {
//            //年龄
//            placeholder = @"请输监护人";
//            if (isEdit) {
//                NSString *protectedPersonGuardian = [userInfoDict objectForKey:@"personGuardian"];
//                if ([protectedPersonGuardian isMemberOfClass:[NSNull class]] || protectedPersonGuardian == nil) {
//                    protectedPersonGuardian = [userInfoDict objectForKey:@"protectedPersonGuardian"];
//                    if ([protectedPersonGuardian isMemberOfClass:[NSNull class]] || protectedPersonGuardian == nil) {
//                        protectedPersonGuardian = @"";
//                    }
//                }
//                contentField.text  = protectedPersonGuardian;
//                
//            }
//            
//            break;
//        }
        case 4:
        {
            //联系电话
            placeholder = @"请输入联系电话";
            if (isEdit) {
                contentField.text  = [userInfoDict objectForKey:@"protectedPersonPhone"];
            }
            contentField.keyboardType = UIKeyboardTypePhonePad;
            break;
        }
        case 5:
        {
            //关系
            CGFloat contentLabelX = 90;
            CGFloat contentLabelW = SCREENWIDTH - contentLabelX - 10;
            CGFloat contentLabelY = 0;
            CGFloat contentLabelH = cellSize.height;
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
            contentLabel.textAlignment = NSTextAlignmentRight;
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.font = contentFont;
            contentLabel.text = releation;
            [cell addSubview:contentLabel];
            
            contentField.hidden = YES;
            if (isEdit) {
                releation = [userInfoDict objectForKey:@"protectedPersonNexus"];
                if ([releation isMemberOfClass:[NSNull class]] || releation == nil) {
                    releation = @"";
                }
                contentLabel.text = releation;
                contentField.text  = releation;
            }
            break;
        }
        case 6:
        {
            //地址
            CGFloat contentLabelX = 50;
            CGFloat contentLabelW = SCREENWIDTH - contentLabelX - 10;
            CGFloat contentLabelY = 0;
            CGFloat contentLabelH = cellSize.height;
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
            contentLabel.textAlignment = NSTextAlignmentRight;
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.font = contentFont;
            [cell addSubview:contentLabel];
            
            contentField.hidden = YES;
            //地址不可编辑，取到专门的页面编辑
            contentField.enabled = NO;
            if (isEdit) {
                contentField.hidden = NO;
                contentField.text  = [userInfoDict objectForKey:@"protectedAddress"];
            }
            else{
                if (!userAddress) {
                    userAddress = [HeSysbsModel getSysModel].addressResult.address;
                }
                contentLabel.text = userAddress;
                contentField.text = userAddress;
                [postUserInfo setObject:userAddress forKey:@"key106"];
            }
            break;
        }
        case 7:
        {
            //病史备注
            placeholder = @"请输入备注信息";
            contentFieldX = 10;
            contentFieldW = SCREENWIDTH - 2 * contentFieldX;
            contentField.frame = CGRectMake(contentFieldX, contentFieldY, contentFieldW, contentFieldH);
            contentField.textAlignment = NSTextAlignmentLeft;
            
            if (isEdit) {
                contentField.text  = [userInfoDict objectForKey:@"protectedPersonNote"];
            }
            break;
        }
            
        default:
            break;
    }
    contentField.placeholder = placeholder;
    [cell addSubview:contentField];
    
    
    return cell;
}

- (void)selectRelation:(id)sender
{
    NSArray *menuArray = @[@"自己",@"爸爸",@"妈妈",@"亲戚",@"朋友",@"孩子",@"其他"];
    [FTPopOverMenu showForSender:sender
                        withMenu:menuArray
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           releation = menuArray[selectedIndex];
                           if (!releation) {
                               releation = @"自己";
                           }
                           [userInfoDict setObject:releation forKey:@"protectedPersonNexus"];
                           [tableview reloadData];
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (row == [dataSource count] - 1) {
        return 100;
    }
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    switch (row) {
        case 1:{
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
            actionsheet.tag = 100;
            [actionsheet showInView:cell];
            break;
        }
        case 5:
        {
            //选择关系
            [self selectRelation:cell];
            break;
        }
        case 6:{
            //选择地址
            HeSelectProtectUserAddressVC *selectAddressVC = [[HeSelectProtectUserAddressVC alloc] init];
            selectAddressVC.addressDeleage = self;
            selectAddressVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:selectAddressVC animated:YES];
            break;
        }
        default:
            break;
    }
    NSLog(@"row = %ld , section = %ld",row,section);
}

- (void)selectAddressWithAddressInfo:(NSDictionary *)addressDcit
{
    NSString *address = addressDcit[@"address"];
    if (isEdit) {
        [userInfoDict setObject:address forKey:@"protectedAddress"];
    }
    else{
        userAddress = address;
    }
    [tableview reloadData];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if (buttonIndex + 1 == 1) {
            userSex = ENUM_SEX_Boy;
        }
        else{
            userSex = ENUM_SEX_Girl;
        }
        NSLog(@"userSex = %ld",buttonIndex);
        if (userSex == ENUM_SEX_Boy) {
            [postUserInfo setObject:@"男" forKey:@"key101"];
        }
        else{
            [postUserInfo setObject:@"女" forKey:@"key101"];
        }
        if (isEdit) {
            NSString *sex = [NSString stringWithFormat:@"%d",userSex];
            [userInfoDict setObject:sex forKey:@"protectedPersonSex"];
        }
        [tableview reloadData];
    }
}

//编辑
- (void)editProtectedUserInfo{

    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/protected/updateprotectedbyid.action",BASEURL];
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *sex = @"";
    if (userSex == ENUM_SEX_Boy) {
        sex = @"1";
    }else{
        sex = @"2";
    }

    NSString *name = [userInfoDict objectForKey:@"protectedPersonName"];
    if ([name isEqualToString:@""] || name == nil) {
        [self showHint:@"请填写受护人姓名"];
        return;
    }
    NSString *card = [userInfoDict objectForKey:@"protectedPersonCard"];
    if ([card isEqualToString:@""] || card == nil) {
        [self showHint:@"请填写受护人身份证"];
        return;
    }
    if ([card length] > 18) {
        [self showHint:@"请输入正确的身份证号"];
        return;
    }
    NSString *age = [userInfoDict objectForKey:@"protectedPersonAge"];
    if ([age isEqualToString:@""] || age == nil) {
        [self showHint:@"请输入受护人年龄"];
        return;
    }
    if ([age integerValue] <= 0 || [age integerValue] > 1000) {
        [self showHint:@"请输入正确的年龄"];
        return;
    }
//    NSString *dian = [userInfoDict objectForKey:@"personGuardian"];
//    if ([dian isEqualToString:@""] || dian == nil) {
//        dian = [userInfoDict objectForKey:@"protectedPersonGuardian"];
//        if ([dian isEqualToString:@""] || dian == nil) {
//            dian = @"";
//            [self showHint:@"请填写监护人"];
//            return;
//        }
//    }
    NSString *phone = [userInfoDict objectForKey:@"protectedPersonPhone"];
    if ([phone isEqualToString:@""] || phone == nil) {
        [self showHint:@"请输入联系电话"];
        return;
    }
    if (![Tool isMobileNumber:phone]) {
        [self showHint:@"请输入正确的手机号码"];
        return;
    }
    NSString *address = [userInfoDict objectForKey:@"protectedAddress"];
    if ([address isEqualToString:@""] || address == nil) {
        [self showHint:@"请输入地址"];
        return;
    }
    
    NSString *protectedPersonGuardian = [userInfoDict objectForKey:@"personGuardian"];
    if ([protectedPersonGuardian isMemberOfClass:[NSNull class]] || protectedPersonGuardian == nil) {
        protectedPersonGuardian = [userInfoDict objectForKey:@"protectedPersonGuardian"];
        if ([protectedPersonGuardian isMemberOfClass:[NSNull class]] || protectedPersonGuardian == nil) {
            protectedPersonGuardian = @"";
        }
    }
//    @"personGuardian": protectedPersonGuardian,
    NSDictionary * params  = @{@"userId": userid,
                               @"personId": [userInfoDict objectForKey:@"protectedPersonId"],
                               @"personName": [userInfoDict objectForKey:@"protectedPersonName"],
                               @"personSex": sex,
                               @"personCard": [userInfoDict objectForKey:@"protectedPersonCard"],
                               @"personAge": [userInfoDict objectForKey:@"protectedPersonAge"],
                               
                               @"personPhone": [userInfoDict objectForKey:@"protectedPersonPhone"],
                               @"personnexus": [userInfoDict objectForKey:@"protectedPersonNexus"],
                               @"addressId": [userInfoDict objectForKey:@"protectedAddressId"],  //关联受护地址id
                               @"personNote": [userInfoDict objectForKey:@"protectedPersonNote"],
                               @"address": [userInfoDict objectForKey:@"protectedAddress"],
                               @"isdefault": [userInfoDict objectForKey:@"protectedDefault"],
                               @"longitude": [[[HeSysbsModel getSysModel] userLocationDict] objectForKey:@"longitude"],
                               @"latitude": [[[HeSysbsModel getSysModel] userLocationDict] objectForKey:@"latitude"]};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict objectForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");
            [self showHint:@"修改成功"];
//            [self.view makeToast:ERRORREQUESTTIP duration:1.5 position:@"center"];
            
            [self performSelector:@selector(backToRootView) withObject:nil afterDelay:1.5];
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
        [self showHint:ERRORREQUESTTIP];
//        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}

//添加
- (void)addProtectedUserInfo{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/protected/addprotected.action",BASEURL];
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *name = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key100"]];
    NSString *sex = @"2";
    if (userSex == ENUM_SEX_Boy) {
        sex = @"1";
    }
    NSString *card = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key102"]];
    NSString *age = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key103"]];
    NSString *phone = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key104"]];
//    NSString *dian = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key104"]];
    NSString *nexus = releation;
    NSString *address = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key106"]];
    NSString *note = [NSString stringWithFormat:@"%@",[postUserInfo objectForKey:@"key107"]];
    NSString *longitude = [NSString stringWithFormat:@"%@",[[[HeSysbsModel getSysModel] userLocationDict] objectForKey:@"longitude"]];
    NSString *latitude = [NSString stringWithFormat:@"%@",[[[HeSysbsModel getSysModel] userLocationDict] objectForKey:@"latitude"]];
    
    if ([name isEqualToString:@""] || name == nil) {
        [self showHint:@"请填写受护人姓名"];
        return;
    }
    if ([card isEqualToString:@""] || card == nil) {
        [self showHint:@"请填写受护人身份证"];
        return;
    }
    if ([card length] > 18) {
        [self showHint:@"请输入正确的身份证号"];
        return;
    }
    if ([age isEqualToString:@""] || age == nil) {
        [self showHint:@"请输入受护人年龄"];
        return;
    }
    if ([age integerValue] <= 0 || [age integerValue] > 1000) {
        [self showHint:@"请输入正确的年龄"];
        return;
    }
    
//    if ([dian isEqualToString:@""] || dian == nil) {
//        [self showHint:@"请填写监护人"];
//        return;
//    }
    if ([phone isEqualToString:@""] || phone == nil) {
        [self showHint:@"请输入联系电话"];
        return;
    }
    if (![Tool isMobileNumber:phone]) {
        [self showHint:@"请输入正确的手机号码"];
        return;
    }
    
    if ([address isEqualToString:@""] || address == nil) {
        [self showHint:@"请输入地址"];
        return;
    }
//    @"personGuardian": dian,
    NSDictionary * params  = @{@"personName": name,
                               @"personSex": sex,
                               @"personCard": card,
                               @"personAge": age,
                               
                               @"personPhone": phone,
                               @"personnexus": nexus,
                               @"address": address,
                               @"personNote": note,
                               @"addressId": @"",
                               @"isdefault": @"0",
                               @"userId": userid,
                               @"longitude": longitude,
                               @"latitude": latitude};
    [self showHudInView:tableview hint:@"添加中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");

            [[NSNotificationCenter defaultCenter] postNotificationName:kAddProtectedUserInfoNotification object:nil];
            [self showHint:@"成功添加"];

            [self performSelector:@selector(backToRootView) withObject:nil afterDelay:0.8];
        }else{
            NSString *errorInfo = [respondDict valueForKey:@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
            NSLog(@"faile");
        }
    } failure:^(NSError* err){
        [self hideHud];
        NSLog(@"err:%@",err);
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToRootView{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddProtectedUserInfoNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
