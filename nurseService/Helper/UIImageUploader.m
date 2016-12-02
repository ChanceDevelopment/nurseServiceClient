//
//  UIImageUploader.m
//  何栋明
//
//  Created by Tony on 15/12/15.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import "UIImageUploader.h"
#import "AFHTTPRequestOperationManager.h"


@implementation UIImageUploader
@synthesize uploadQueue;

+ (id)sharedInstance
{
    static UIImageUploader *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


//上传图片到自己的图片服务器
- (void)localServer_uploadImageToserverWithImageDict:(NSDictionary *)imageDict
{
    NSString *uploadUrl = nil;
    NSDictionary *params = nil;
    NSData *woodImgData = nil;
    NSString *fileName = nil;
    NSString *typeStr = @"image/png";
    NSString *serverReceiveKey = @"image";
    AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [client POST:uploadUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        /*
         32          此方法参数
         33          1. 要上传的[二进制数据]
         34          2. 对应网站上[upload.php中]处理文件的[字段"file1"]
         35          3. 要保存在服务器上的[文件名]
         36          4. 上传文件的[mimeType]
         */
        [formData appendPartWithFileData:woodImgData name:serverReceiveKey fileName:fileName mimeType:typeStr];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //            [self hideHud];
        NSString *responseString = operation.responseString;
        NSDictionary *respondDict = [responseString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"code"] integerValue];
        if (statueCode == REQUESTCODE_SUCCEED) {
            
            return;
        }
        else{
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)uploadImageWithImageArray:(NSArray *)imageArray upLoadUrl:(NSString *)uploadURL newsReceiver:(id<ReceiveProtocol>)receiver
{
    for (int i = 0; i < [imageArray count]; i++) {
        UIImage *image = [imageArray objectAtIndex:i];
        NSData *woodImgData = UIImagePNGRepresentation(image);
        NSString *typeStr = @"image/png";
        
        NSDate *senddate=[NSDate date];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYYMMddhhmmss"];
        NSString *timeStr   = [dateformatter stringFromDate:senddate];
        NSString *imageStr = [NSString stringWithFormat:@"%@sell_headImage.png",timeStr];
        NSArray *array = [imageStr componentsSeparatedByString:@":"];
        NSMutableString *mutableString = [[NSMutableString alloc] initWithCapacity:0];
        for (NSString *str in array) {
            [mutableString appendString:str];
        }
        [self uploadOneFileData:woodImgData imgType:typeStr imgName:mutableString upLoadUrl:uploadURL newsReceiver:receiver];
    }
}
//提交上传
-(void)uploadOneFileData:(NSData *)woodImgData imgType:(NSString*)typeStr imgName:(NSString *)fileName upLoadUrl:uploadURL  newsReceiver:(id<ReceiveProtocol>)receiver{
    if (woodImgData) {
        //上传图片文件
        
        AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
        [client POST:uploadURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            /*
             32          此方法参数
             33          1. 要上传的[二进制数据]
             34          2. 对应网站上[upload.php中]处理文件的[字段"file1"]
             35          3. 要保存在服务器上的[文件名]
             36          4. 上传文件的[mimeType]
             */
            [formData appendPartWithFileData:woodImgData name:@"pic" fileName:fileName mimeType:typeStr];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //            [self hideHud];
            NSString *responseString = operation.responseString;
            NSString *fileName = responseString;
            if ([fileName isMemberOfClass:[NSNull class]] || fileName == nil) {
                //                [self showHint:@"上传头像失败"];
                [receiver uploadImageResult:NO imageAddress:nil];
            }
            else{
                [receiver uploadImageResult:YES imageAddress:responseString];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [receiver uploadImageResult:NO imageAddress:nil];
            //            [self hideHud];
            //            [self showHint:ERRORREQUESTTIP];
        }];
        
//        NSURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:uploadURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            
//            /*
//             32          此方法参数
//             33          1. 要上传的[二进制数据]
//             34          2. 对应网站上[upload.php中]处理文件的[字段"file1"]
//             35          3. 要保存在服务器上的[文件名]
//             36          4. 上传文件的[mimeType]
//             */
//            [formData appendPartWithFileData:woodImgData name:@"pic" fileName:fileName mimeType:typeStr];
//        }];
//        // 3. operation包装的urlconnetion
//        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
////            [self hideHud];
//            NSString *responseString = operation.responseString;
//            NSString *fileName = responseString;
//            if ([fileName isMemberOfClass:[NSNull class]] || fileName == nil) {
////                [self showHint:@"上传头像失败"];
//                [receiver uploadImageResult:NO imageAddress:nil];
//            }
//            else{
//                [receiver uploadImageResult:YES imageAddress:responseString];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [receiver uploadImageResult:NO imageAddress:nil];
////            [self hideHud];
////            [self showHint:ERRORREQUESTTIP];
//        }];
//        [client.operationQueue addOperation:op];
    }
}

@end
