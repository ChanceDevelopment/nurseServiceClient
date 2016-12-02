//
//  AsynImageView.h
//  AsynImage
//
//  Created by 何栋明 on 13-3-5.
//  Copyright (c) 2013年 哲信信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMBase64.h"
#import "Reachability.h"

@interface AsynImageView : UIImageView
{
    NSURLConnection *connection;
    NSMutableData *loadData;
}

-(id)initWithTag:(NSInteger)tag;

//图片对应的缓存在沙河中的路径
@property (nonatomic, retain) NSString *fileName;

@property(nonatomic, strong)NSString *tagString;
//指定默认未加载时，显示的默认图片
@property (nonatomic, retain) UIImage *placeholderImage;
//请求网络图片的URL
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, assign) BOOL canDownload;//判断图片是否能下载，第一下尝试下载失败之后不再下载，这样有利于界面的流畅
@property (nonatomic, strong) NSString *bigImageURL;
@property (nonatomic, strong) NSString *downloadDateline;
@property (nonatomic, assign) NSInteger imageTag;

@end
