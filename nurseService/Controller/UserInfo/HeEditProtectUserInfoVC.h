//
//  HeEditProtectUserInfoVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//  编辑用户信息视图控制器

#import "HeBaseViewController.h"


@interface HeEditProtectUserInfoVC : HeBaseViewController{

}
//用户的信息
@property(strong,nonatomic)NSMutableDictionary *userInfoDict;
//是否编辑
@property(assign,nonatomic)BOOL isEdit;

@end
