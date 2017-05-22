//
//  DeleteImageProtocol.h
//  com.mant.iosClient
//
//  Created by 何 栋明 on 13-10-14.
//  Copyright (c) 2013年 何栋明. All rights reserved.
//  图片删除协议

#import <Foundation/Foundation.h>

@protocol DeleteImageProtocol <NSObject>

/*
 @brief 删除图片 
 @param index 图片的索引号
 */
-(void)deleteImageAtIndex:(int)index;

@end
