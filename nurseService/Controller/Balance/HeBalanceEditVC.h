//
//  HeBalanceEditVC.h
//  beautyContest
//
//  Created by Tony on 16/10/8.
//  Copyright © 2016年 iMac. All rights reserved.
//  用户资金编辑视图控制前

#import "HeBaseViewController.h"

//定义枚举类型
typedef enum {
    Balance_Edit_Recharge = 0,//充值
    Balance_Edit_Withdraw,//提现
    Balance_Edit_BindAccount//绑定账号
} Balance_Edit_Type;

@interface HeBalanceEditVC : HeBaseViewController

//资金操作类型 0：充值 1：提现  2：绑定账号
@property(assign,nonatomic)Balance_Edit_Type banlanceType;
//最大的提现现金
@property(assign,nonatomic)CGFloat maxWithDrawMoney;
//用户资金的信息
@property(strong,nonatomic)NSDictionary *balanceDict;

@end
