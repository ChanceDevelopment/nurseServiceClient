//
//  UIImageUploader.h
//  何栋明
//
//  Created by Tony on 15/12/15.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@protocol ReceiveProtocol <NSObject>

- (void)uploadImageResult:(BOOL)result imageAddress:(NSString *)address;

@end

@interface UIImageUploader : NSObject
@property(strong,nonatomic)ASINetworkQueue *uploadQueue;

+ (id)sharedInstance;

- (void)uploadImageWithImageArray:(NSArray *)imageArray upLoadUrl:(NSString *)uploadURL newsReceiver:(id<ReceiveProtocol>)receiver;

-(void)uploadOneFileData:(NSData *)woodImgData imgType:(NSString*)typeStr imgName:(NSString *)fileName upLoadUrl:(NSString *)uploadURL newsReceiver:(id<ReceiveProtocol>)receiver;

//保存还没有上传的图片在本地
- (void)save_unUploadImage:(NSDictionary *)imageDict savePath:(NSString *)filename;
//上传还没有上传的图片
- (void)upload_unFinishImage;
//单张照片上传
- (void)uploadImage:(NSData *)imageData key:(NSString *)uploadKey token:(NSString *)token filename:(NSString *)filename typeId:(NSString *)typeID;

@end
