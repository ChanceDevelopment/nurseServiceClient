//
//  BrowserView.h
//  com.mant.iosClient
//
//  Created by 何 栋明 on 14-2-17.
//  Copyright (c) 2014年 何栋明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeBaseViewController.h"

@interface BrowserView : HeBaseViewController<UIWebViewDelegate>
@property(strong,nonatomic)NSString *htmlContent;

-(id)initWithWebSite:(NSString*)string;

@end
