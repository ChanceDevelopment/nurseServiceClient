//
//  MLLinkClickLabel.h
//  DFCommon
//
//  Created by Allen Zhong on 15/10/10.
//  Copyright (c) 2015年 Datafans, Inc. All rights reserved.
//

#import "MLLinkLabel.h"

@protocol MLLinkClickLabelDelegate <NSObject>

@optional

-(void) onClickOutsideLink:(NSString *) uniqueId;
-(void) onLongPress;

@end

@interface MLLinkClickLabel : MLLinkLabel

@property (nonatomic, assign) id<MLLinkClickLabelDelegate> clickDelegate;

@property (nonatomic, strong) NSString * uniqueId;


@end
