//
//  HeBalanceEditVC.h
//  beautyContest
//
//  Created by Tony on 16/10/8.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

//定义枚举类型
typedef enum {
    Balance_Edit_Recharge = 0,//充值
    Balance_Edit_Withdraw,//提现
    Balance_Edit_BindAccount//绑定账号
} Balance_Edit_Type;

@interface HeBalanceEditVC : HeBaseViewController

@property(assign,nonatomic)Balance_Edit_Type banlanceType;
@property(assign,nonatomic)CGFloat maxWithDrawMoney;
@property(strong,nonatomic)NSDictionary *balanceDict;

@end
