//
//  WebViewController.h
//  Tuan
//
//  Created by 夏 华 on 12-7-6.
//  Copyright (c) 2012年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

static int addStatusBarHeight;
@interface TopNaviViewController : UIViewController<UIGestureRecognizerDelegate>

+(int)getStatusBarHeight;
@property (nonatomic, strong) NSString *topNaviTitle;
@property (nonatomic, strong)UIView *topNaviView_topClass;
@property (nonatomic, strong)UILabel *topNaviText;
@property (nonatomic, strong)NSString *commonJson;   //js页面传过来的数据

//拨打电话的公共方法
-(void)json_dialPhone:(NSString *)jsonString;

@end
