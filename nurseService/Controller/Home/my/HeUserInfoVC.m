//
//  HeUserInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserInfoVC.h"
#import "HeBaseTableViewCell.h"

#define SEXACTIONTAG 600
#define ALERTTAG 200

@interface HeUserInfoVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UIImageView *portrait;
    NSInteger currentSelectRow;
    BOOL haveSelectUserImage;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *dataSource;

@property(strong,nonatomic)UIView *dismissView;
@property(strong,nonatomic)User *userInfoModel;

@end

@implementation HeUserInfoVC
@synthesize tableview;
@synthesize dataSource;
@synthesize dismissView;
@synthesize userInfoModel;

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
        label.text = @"个人信息";
        [label sizeToFit];
        self.title = @"个人信息";
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
    dataSource = @[@"头像",@"用户名",@"联系电话",@"邀请码",@"性别",@"邮箱"];
    haveSelectUserImage = NO;
    userInfoModel = [HeSysbsModel getSysModel].user;
}

- (void)initView
{
    [super initView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor clearColor];
    [Tool setExtraCellLineHidden:tableview];
    tableview.delegate = self;
    tableview.dataSource = self;
    [self.view addSubview:tableview];
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
    
    //头像
    CGFloat imageDia = 60;              //直径
    CGFloat imageX = SCREENWIDTH - imageDia - 30 ;
    CGFloat imageY = 10;
    portrait = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageDia, imageDia)];
    portrait.userInteractionEnabled = YES;
    portrait.image = [UIImage imageNamed:@"defalut_icon"];
    portrait.layer.borderWidth = 0.0;
    portrait.contentMode = UIViewContentModeScaleAspectFill;
    portrait.layer.cornerRadius = imageDia / 2.0;
    portrait.layer.masksToBounds = YES;
    
    NSString *userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userInfoModel.userHeader];
    [portrait sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
}

- (IBAction)commitUserInfo:(id)sender
{
    //判断用户是否已经签到
    [self showHudInView:tableview hint:@"修改中..."];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/updateUserInfo.action",BASEURL];
    
    NSString *userHeader = @"";
    if (haveSelectUserImage) {
        UIImage *imageData = portrait.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        userHeader = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    }
    NSString *userNick = userInfoModel.userNick;
    NSString *userPhone = userInfoModel.userPhone;
    NSString *userSex = userInfoModel.userSex;
    NSString *userEmail = userInfoModel.userEmail;
    NSDictionary *params = @{@"userId":userId,@"userHeader":userHeader,@"userNick":userNick,@"userPhone":userPhone,@"userSex":userSex,@"userEmail":userEmail};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"respondString:%@",respondString);
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
           
            [self showHint:@"修改成功"];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.8];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserInfoNotification object:nil];
            
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
        
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewdDataSource UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    HeBaseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSString *title = dataSource[row];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    CGFloat contentLabelX = 80;
    CGFloat contentLabelY = 0;
    CGFloat contentLabelW = SCREENWIDTH - contentLabelX - 30;
    CGFloat contentLabelH = cellSize.height;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:15.0];
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.frame = CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH);
    [cell addSubview:contentLabel];
    
    NSString *content = nil;
    switch (row) {
        case 0:
        {
            contentLabel.hidden = YES;
            [cell addSubview:portrait];
            break;
        }
        case 1:
        {
            content = userInfoModel.userNick;
            break;
        }
        case 2:
        {
            content = userInfoModel.userPhone;
            break;
        }
        case 3:
        {
            content = userInfoModel.userInvitationcode;
            break;
        }
        case 4:
        {
            content = @"女";
            if ([userInfoModel.userSex integerValue] == ENUM_SEX_Boy) {
                content = @"男";
            }
            break;
        }
        case 5:
        {
            content = userInfoModel.userEmail;
            break;
        }
            
        default:
            break;
    }
    contentLabel.text = content;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 0) {
        return 80;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    currentSelectRow = row;
    if (row == 0) {
        [self editUserHead];
        return;
    }
    if (row == 3) {
        //邀请码不可编辑
        return;
    }
    if (row == 4) {
        //性别
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"请选择性别"                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
            //添加Button
            [alertController addAction: [UIAlertAction actionWithTitle: @"男" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                userInfoModel.userSex = @"1";
                [tableview reloadData];
            }]];
            [alertController addAction: [UIAlertAction actionWithTitle: @"女" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                userInfoModel.userSex = @"2";
                [tableview reloadData];
            }]];
            [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController: alertController animated: YES completion: nil];
        }
        else{
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"请选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
            actionsheet.tag = SEXACTIONTAG;
            [actionsheet showInView:self.view];
        }
        return;
    }
    
    NSString *title = dataSource[row];
    [self inputContentWithTitle:title];
    
}

- (void)dismissViewGes:(UITapGestureRecognizer *)ges
{
    
    UIView *mydismissView = ges.view;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    [alertview removeFromSuperview];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)inputContentWithTitle:(NSString *)title
{
    [self.view addSubview:dismissView];
    dismissView.hidden = NO;
    
    CGFloat viewX = 10;
    CGFloat viewY = 100;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = 150;
    UIView *shareAlert = [[UIView alloc] init];
    shareAlert.frame = CGRectMake(viewX, viewY, viewW, viewH);
    shareAlert.backgroundColor = [UIColor whiteColor];
    shareAlert.layer.cornerRadius = 5.0;
    shareAlert.layer.borderWidth = 0;
    shareAlert.layer.masksToBounds = YES;
    shareAlert.tag = ALERTTAG;
    shareAlert.layer.borderColor = [UIColor clearColor].CGColor;
    shareAlert.userInteractionEnabled = YES;
    
    CGFloat labelH = 40;
    CGFloat labelY = 0;
    
    UIFont *shareFont = [UIFont systemFontOfSize:13.0];
    
    UILabel *messageTitleLabel = [[UILabel alloc] init];
    messageTitleLabel.font = [UIFont systemFontOfSize:18.0];;
    messageTitleLabel.textColor = [UIColor blackColor];
    messageTitleLabel.textAlignment = NSTextAlignmentCenter;
    messageTitleLabel.backgroundColor = [UIColor clearColor];
    messageTitleLabel.text = title;
    messageTitleLabel.frame = CGRectMake(0, 5, viewW, labelH);
    [shareAlert addSubview:messageTitleLabel];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logoImage"]];
    logoImage.frame = CGRectMake(20, 5, 30, 30);
    [shareAlert addSubview:logoImage];
    
    
    labelY = labelY + labelH + 10;
    UITextField *textview = [[UITextField alloc] init];
    textview.tag = 10;
    textview.backgroundColor = [UIColor whiteColor];
    textview.placeholder = @"请输入";
    textview.font = shareFont;
    textview.delegate = self;
    textview.frame = CGRectMake(10, labelY, shareAlert.frame.size.width - 20, labelH);
    textview.layer.borderWidth = 1.0;
    textview.layer.cornerRadius = 5.0;
    textview.layer.masksToBounds = YES;
    textview.layer.borderColor = [UIColor colorWithWhite:0xcc / 255.0 alpha:1.0].CGColor;
    [shareAlert addSubview:textview];
    
    NSString *content = nil;
    switch (currentSelectRow) {
        case 1:
        {
            content = userInfoModel.userNick;
            break;
        }
        case 2:
        {
            content = userInfoModel.userPhone;
            break;
        }
        case 3:
        {
            content = userInfoModel.userInvitationcode;
            break;
        }
        case 4:
        {
            break;
        }
        case 5:
        {
            content = userInfoModel.userEmail;
            break;
        }
        default:
            break;
    }
    if ([content isEqualToString:@""]) {
        content = nil;
    }
    textview.text = content;
    
    CGFloat buttonDis = 10;
    CGFloat buttonW = (viewW - 3 * buttonDis) / 2.0;
    CGFloat buttonH = 40;
    CGFloat buttonY = labelY = labelY + labelH + 10;
    CGFloat buttonX = 10;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [shareButton setTitle:@"确定" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tag = 1;
    [shareButton.titleLabel setFont:shareFont];
    //    [shareButton setBackgroundColor:APPDEFAULTORANGE];
    //    [shareButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:shareButton.frame.size] forState:UIControlStateHighlighted];
    [shareButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [shareAlert addSubview:shareButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX + buttonDis + buttonW, buttonY, buttonW, buttonH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 0;
    [cancelButton.titleLabel setFont:shareFont];
    //    [cancelButton setBackgroundColor:APPDEFAULTORANGE];
    //    [cancelButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:cancelButton.frame.size] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    [shareAlert addSubview:cancelButton];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [shareAlert.layer addAnimation:popAnimation forKey:nil];
    [self.view addSubview:shareAlert];
}

- (void)alertbuttonClick:(UIButton *)button
{
    UIView *mydismissView = dismissView;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    UIView *subview = [alertview viewWithTag:10];
    if (button.tag == 0) {
        [alertview removeFromSuperview];
        return;
    }
    UITextField *textview = nil;
    if ([subview isMemberOfClass:[UITextField class]]) {
        textview = (UITextField *)subview;
    }
    NSString *password = textview.text;
    [alertview removeFromSuperview];
    switch (currentSelectRow) {
        case 1:
        {
            userInfoModel.userNick = password;
            break;
        }
        case 2:
        {
            userInfoModel.userPhone = password;
            break;
        }
        case 5:
        {
            userInfoModel.userEmail = password;
            break;
        }

        default:
            break;
    }
    [tableview reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == SEXACTIONTAG) {
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"男");
                userInfoModel.userSex = @"1";
                break;
            }
            case 1:
            {
                NSLog(@"女");
                userInfoModel.userSex = @"2";
                break;
            }
            default:
                break;
        }
    }
    
    else if (actionSheet.tag == 2){
        switch (buttonIndex) {
            case 0:
            {
                [self pickerPhotoLibrary];
                break;
            }
            case 1:{
                //查看大图
                [self pickerCamer];
                break;
            }
            case 2:
                //取消
                break;
            default:
                break;
        }
    }
    [tableview reloadData];
}

- (void)editUserHead
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
}

#pragma mark -
#pragma mark ImagePicker method
//从相册中打开照片选择画面(图片库)：UIImagePickerControllerSourceTypePhotoLibrary
//启动摄像头打开照片摄影画面(照相机)：UIImagePickerControllerSourceTypeCamera

//按下相机触发事件
-(void)pickerCamer
{
    //照相机类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断属性值是否可用
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        //UIImagePickerController是UINavigationController的子类
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        //设置可以编辑
        imagePicker.allowsEditing = YES;
        //设置类型为照相机
        imagePicker.sourceType = sourceType;
        //进入照相机画面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//当按下相册按钮时触发事件
-(void)pickerPhotoLibrary
{
    //图片库类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *photoAlbumPicker = [[UIImagePickerController alloc] init];
    photoAlbumPicker.delegate = self;
    photoAlbumPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置可以编辑
    photoAlbumPicker.allowsEditing = YES;
    //设置类型
    photoAlbumPicker.sourceType = sourceType;
    //进入图片库画面
    [self presentViewController:photoAlbumPicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark imagePickerController method
//当拍完照或者选取好照片之后所要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    CGSize sizeImage = image.size;
    float a = [self getSize:sizeImage];
    if (a>0) {
        CGSize size = CGSizeMake(sizeImage.width/a, sizeImage.height/a);
        image = [self scaleToSize:image size:size];
    }
    
    //    [self initButtonWithImage:image];
    
    //    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    
    UIImageJPEGRepresentation(image, 0.6);
    
    [self dismissViewControllerAnimated:YES completion:^{
        haveSelectUserImage = YES;
        [portrait setImage:image];
    }];
    
}


//相应取消动作
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(float)getSize:(CGSize)size
{
    float a = size.width / 480.0;
    if (a > 1) {
        return a;
    }
    else
        return -1;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
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
