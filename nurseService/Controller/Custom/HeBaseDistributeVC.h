//
//  HeBaseDistributeVC.h
//  huayoutong
//
//  Created by Tony on 16/3/9.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeBaseViewController.h"
#import "SAMTextView.h"
#import "UIImageUploader.h"
#import "DeleteImageProtocol.h"

@protocol DistributeProtocol <NSObject>

- (void)distributeSucceed;

@end

@interface HeBaseDistributeVC : HeBaseViewController<DeleteImageProtocol,ReceiveProtocol,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property(strong,nonatomic)UIScrollView *scrollView;
@property(strong,nonatomic)SAMTextView *distributeTF;
@property(strong,nonatomic)UIView *headerBGView;
@property(strong,nonatomic)UIButton *addPictureButton;
@property(strong,nonatomic)NSMutableArray *pictureArray;
@property(assign,nonatomic)id<DistributeProtocol>updateDelegate;
@property(strong,nonatomic)NSString *defaultTextString;
@property(strong,nonatomic)UIView *distributeImageBG;
@property(strong,nonatomic)UIView *footview;
@property(strong,nonatomic)NSMutableArray *uploadImageAddressArray;

@end
