//
//  HeBaseDistributeVC.m
//  huayoutong
//
//  Created by Tony on 16/3/9.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//  发布页面的基类

#import "HeBaseDistributeVC.h"
#import "ScanPictureView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"

#define MAXUPLOADIMAGE 3
#define MAX_column  4
#define MAX_row 3

@interface HeBaseDistributeVC ()<TZImagePickerControllerDelegate>
@property(strong,nonatomic)NSMutableArray *selectedAssets;
@property(strong,nonatomic)NSMutableArray *selectedPhotos;

@end

@implementation HeBaseDistributeVC
@synthesize distributeTF;
@synthesize headerBGView;
@synthesize addPictureButton;
@synthesize pictureArray;
@synthesize defaultTextString;
@synthesize distributeImageBG;
@synthesize scrollView;
@synthesize footview;
@synthesize uploadImageAddressArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    if (!pictureArray) {
        pictureArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!uploadImageAddressArray) {
        uploadImageAddressArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!_selectedPhotos) {
        _selectedPhotos = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

- (void)initView
{
    [super initView];
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH)];
        scrollView.userInteractionEnabled = YES;
    }
    
    [self.view addSubview:scrollView];
    
    if (!headerBGView) {
        headerBGView = [[UIView alloc] init];
    }
    
    headerBGView.frame = CGRectMake(0, 0, SCREENWIDTH, 120);
    headerBGView.backgroundColor = [UIColor whiteColor];
    headerBGView.userInteractionEnabled = YES;
    
    if (!distributeTF) {
        distributeTF = [[SAMTextView alloc] init];
    }
    
    distributeTF.frame = CGRectMake(10, 10, SCREENWIDTH - 20, 100);
    distributeTF.layer.borderWidth = 1.0;
    distributeTF.layer.cornerRadius = 5.0;
    distributeTF.layer.masksToBounds = YES;
    distributeTF.returnKeyType = UIReturnKeyDone;
    distributeTF.layer.borderColor = APPDEFAULTORANGE.CGColor;
    distributeTF.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    distributeTF.textColor = [UIColor blackColor];
    distributeTF.delegate = self;
    distributeTF.backgroundColor = [UIColor whiteColor];
    distributeTF.showsHorizontalScrollIndicator = NO;
    distributeTF.showsVerticalScrollIndicator = NO;
    
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish:)];
    finishButton.title = @"完成";
    NSArray *bArray = [NSArray arrayWithObjects:finishButton, nil];
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];//创建工具条对象
    tb.items = bArray;
    tb.hidden = YES;
    distributeTF.inputAccessoryView = tb;//将工具条添加到UITextView的响应键盘
    
    if (!addPictureButton) {
        self.addPictureButton = [[UIButton alloc] init];
    }
    
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"icon_add_photo"] forState:UIControlStateNormal];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"icon_add_photo_violet"] forState:UIControlStateHighlighted];
    addPictureButton.tag = -1;
    addPictureButton.frame = CGRectMake(0, 0, 70, 70);
    [addPictureButton addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:headerBGView];
    [headerBGView addSubview:distributeTF];
    
    
    CGFloat buttonH = 70;
    CGFloat buttonW = 70;
    
    
    CGFloat buttonHDis = (SCREENWIDTH - 20 - MAX_column * buttonW) / (MAX_column - 1);
    CGFloat buttonVDis = 10;
    
    //    addPictureButton.frame = CGRectMake(10, headerBGView.frame.origin.y + headerBGView.frame.size.height + 5, addPictureButton.frame.size.width, addPictureButton.frame.size.height);
    //    [self.view addSubview:addPictureButton];
    
    CGFloat distributeX = 10;
    CGFloat distributeY = distributeTF.frame.origin.y + distributeTF.frame.size.height + 10;
    CGFloat distributeW = SCREENWIDTH - 20;
    CGFloat distributeH = buttonH;
    
    UIView *subdisview = [[UIView alloc] initWithFrame:CGRectMake(0, distributeY, SCREENWIDTH, distributeH + 20)];
    [scrollView addSubview:subdisview];
    subdisview.backgroundColor = [UIColor whiteColor];
    
    int row = [Tool getRowNumWithTotalNum:[pictureArray count]];
    int column = [Tool getColumnNumWithTotalNum:[pictureArray count]];
    distributeH = row * buttonH + (row - 1) * buttonVDis;
    distributeImageBG = [[UIView alloc] initWithFrame:CGRectMake(distributeX, distributeY, distributeW, distributeH)];
    [distributeImageBG setBackgroundColor:[UIColor whiteColor]];
    [distributeImageBG addSubview:addPictureButton];
    [scrollView addSubview:distributeImageBG];
    distributeImageBG.userInteractionEnabled = YES;
    [self updateImageBG];
    
    if (!footview) {
        footview = [[UIView alloc] initWithFrame:CGRectMake(5, distributeImageBG.frame.origin.y + distributeImageBG.frame.size.height + 15, SCREENWIDTH, 60)];
    }
    
    
    footview.backgroundColor = [UIColor whiteColor];
//    UILabel *tiplabel = [[UILabel alloc] init];
//    tiplabel.backgroundColor = [UIColor clearColor];
//    tiplabel.textColor = [UIColor grayColor];
//    tiplabel.frame = CGRectMake(10, 10, SCREENWIDTH - 20, 40);
//    tiplabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
//    tiplabel.numberOfLines = 0;
//    tiplabel.text = @"温馨提示:请发布健康向上的内容，禁止发布色情内容，否则我们会追究法律责任。";
//    [footview addSubview:tiplabel];
    [scrollView addSubview:footview];
}

//刷新所选的图片区域视图，因为用户所选的图片随时发生变化
- (void)updateImageBG
{
    for (UIView *subview in distributeImageBG.subviews) {
        [subview removeFromSuperview];
    }
    CGFloat buttonH = 70;
    CGFloat buttonW = 70;
    
    CGFloat buttonHDis = (SCREENWIDTH - 20 - MAX_column * buttonW) / (MAX_column - 1);
    CGFloat buttonVDis = 10;
    
    int row = [Tool getRowNumWithTotalNum:[pictureArray count]];
    int column = [Tool getColumnNumWithTotalNum:[pictureArray count]];
    for (int i = 0; i < row; i++) {
        if ((i + 1) * MAX_column <= [pictureArray count]) {
            column = MAX_column;
        }
        else{
            column = [pictureArray count] % MAX_column;
        }
        for (int j = 0; j < column; j++) {
            
            CGFloat buttonX = (buttonW + buttonHDis) * j;
            CGFloat buttonY = (buttonH + buttonVDis) * i;
            
            NSInteger picIndex = i * MAX_column + j;
            AsynImageView *asynImage = [pictureArray objectAtIndex:picIndex];
            asynImage.tag = picIndex;
            asynImage.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            asynImage.layer.borderColor = [UIColor clearColor].CGColor;
            asynImage.layer.borderWidth = 0;
            asynImage.layer.masksToBounds = YES;
            asynImage.contentMode = UIViewContentModeScaleAspectFill;
            asynImage.userInteractionEnabled = YES;
            [distributeImageBG addSubview:asynImage];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
            tapGes.numberOfTapsRequired = 1;
            tapGes.numberOfTouchesRequired = 1;
            [asynImage addGestureRecognizer:tapGes];
        }
    }
    
    
    if ([pictureArray count] < MAXUPLOADIMAGE) {
        
        NSInteger last_i = -1;
        NSInteger last_j = -1;
        row = [Tool getRowNumWithTotalNum:[pictureArray count] + 1];
        for (int i = 0; i < row; i++) {
            if ((i + 1) * MAX_column <= [pictureArray count] + 1) {
                column = MAX_column;
            }
            else{
                column = ([pictureArray count] + 1) % MAX_column;
            }
            last_i = i;
            for (int j = 0; j < column; j++) {
                last_j = j;
            }
        }
        if (last_i == -1 || last_j == -1) {
            addPictureButton.hidden = YES;
        }
        else{
            addPictureButton.hidden = NO;
        }
        
        CGFloat buttonX = (buttonW + buttonHDis) * last_j;
        CGFloat buttonY = (buttonH + buttonVDis) * last_i;
        CGFloat buttonW = addPictureButton.frame.size.width;
        CGFloat buttonH = addPictureButton.frame.size.height;
        
        addPictureButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        CGFloat distributeX = distributeImageBG.frame.origin.x;
        CGFloat distributeY = distributeImageBG.frame.origin.y;
        CGFloat distributeW = distributeImageBG.frame.size.width;
        CGFloat distributeH = addPictureButton.frame.origin.y + addPictureButton.frame.size.height;
        
        distributeImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
    }
    else{
        
        CGFloat distributeX = distributeImageBG.frame.origin.x;
        CGFloat distributeY = distributeImageBG.frame.origin.y;
        CGFloat distributeW = distributeImageBG.frame.size.width;
        CGFloat distributeH = (buttonH + buttonVDis) * (MAX_row - 1) + buttonH;
        
        distributeImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
        addPictureButton.hidden = YES;
    }
    [distributeImageBG addSubview:addPictureButton];
    
    CGSize footsize = footview.frame.size;
    footview.frame = CGRectMake(5, distributeImageBG.frame.origin.y + distributeImageBG.frame.size.height + 5, SCREENWIDTH, footsize.height);
    scrollView.contentSize = CGSizeMake(0, footview.frame.origin.y + footview.frame.size.height + 50);
    
}

-(void)finish:(id)sender
{
    
}

//删除所选图片的代理方法
-(void)deleteImageAtIndex:(int)index
{
    [pictureArray removeObjectAtIndex:index];
    [self updateImageBG];
}

//上传图片的回调方法
- (void)uploadImageResult:(BOOL)result imageAddress:(NSString *)address
{
    if (result) {
        [uploadImageAddressArray addObject:address];
    }
    else{
        [uploadImageAddressArray addObject:@""];
    }
    if ([uploadImageAddressArray count] == [pictureArray count]) {
        //图片上传完成
            }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    textView.frame = textView.frame;
}

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
    NSInteger selectIndex = tap.view.tag + 1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AsynImageView *asyImage in pictureArray) {
        if (asyImage.highlightedImage == nil) {
            [array addObject:asyImage];
        }
    }
    
    ScanPictureView *scanPictureView = [[ScanPictureView alloc] initWithArray:array selectButtonIndex:selectIndex];
    scanPictureView.deleteDelegate = self;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTintColor:[UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    scanPictureView.navigationItem.backBarButtonItem = backButton;
    scanPictureView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanPictureView animated:YES];
}

-(void)addPictureButtonClick:(id)sender
{
    if ([distributeTF isFirstResponder]) {
        [distributeTF resignFirstResponder];
    }
    
    if (addPictureButton.tag == 1) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AsynImageView *asyImage in pictureArray) {
            if (asyImage.highlightedImage == nil) {
                [array addObject:asyImage];
            }
        }
        int index = 1;
        
        ScanPictureView *scanPictureView = [[ScanPictureView alloc] initWithArray:array selectButtonIndex:index];
        scanPictureView.deleteDelegate = self;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        [backButton setTintColor:[UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
        self.navigationItem.backBarButtonItem = backButton;
        scanPictureView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:scanPictureView animated:YES];
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 1;
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                if (ISIOS7) {
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        [self pickerCamer];
                    }
                }
                else{
                    [self pickerCamer];
                }
                
                
                break;
            }
            case 0:
            {
                if (ISIOS7) {
                    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
                        //无权限
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    else{
                        [self mutiplepickPhotoSelect];
                    }
                }
                else{
                    [self mutiplepickPhotoSelect];
                }
                break;
            }
            case 2:
            {
                break;
            }
            default:
                break;
        }
    }
}

- (void)handleSelectPhoto
{
    [pictureArray removeAllObjects];
    for (UIImage *image in _selectedPhotos) {
        AsynImageView *asyncImage = [[AsynImageView alloc] init];
        [asyncImage setImage:image];
        asyncImage.bigImageURL = nil;
        [pictureArray addObject:asyncImage];
        [self updateImageBG];
    }
    
}

- (void)mutiplepickPhotoSelect{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXUPLOADIMAGE delegate:self];
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    // Set the appearance
    // 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // Set allow picking video & photo & originalPhoto or not
    // 设置是否可以选择视频/图片/原图
    // imagePickerVc.allowPickingVideo = NO;
    // imagePickerVc.allowPickingImage = NO;
    // imagePickerVc.allowPickingOriginalPhoto = NO;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark TZImagePickerControllerDelegate



/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
}

/// User finish picking video,
/// 用户选择好了视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    [_selectedPhotos addObjectsFromArray:@[coverImage]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
    
    /*
     // open this code to send video / 打开这段代码发送视频
     [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
     // Export completed, send video here, send by outputPath or NSData
     // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
     
     }];
     */
    
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
        //        imagePicker.allowsEditing = YES;
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
    //    photoAlbumPicker.allowsEditing = YES;
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
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize sizeImage = image.size;
    float a = [self getSize:sizeImage];
    if (a>0) {
        CGSize size = CGSizeMake(sizeImage.width/a, sizeImage.height/a);
        image = [self scaleToSize:image size:size];
    }
    
    //    [self initButtonWithImage:image];
    
    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    UIImageJPEGRepresentation(image, 0.6);
    [asyncImage setImage:image];
    
    asyncImage.bigImageURL = nil;
    [pictureArray addObject:asyncImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateImageBG];
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

-(void)initButtonWithImage:(UIImage *)image
{
    
    CGSize sizeImage = image.size;
    CGFloat width = sizeImage.width;
    CGFloat hight = sizeImage.height;
    CGFloat standarW = width;
    CGRect frame = CGRectMake(0, hight - width, standarW, standarW);
    
    if (width > hight) {
        standarW = hight;
        
        frame = CGRectMake(0, 0, standarW, standarW);
    }
    //截取图片
    UIImage *jiequImage = [self imageFromImage:image inRect:frame];
    //    CGSize jiequSize = jiequImage.size;
    
    
    addPictureButton.tag = 1;
    [addPictureButton setImage:jiequImage forState:UIControlStateNormal];
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
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
