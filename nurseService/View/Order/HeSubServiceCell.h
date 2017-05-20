//
//  HeSubServiceCell.h
//  nurseService
//
//  Created by Tony on 2017/1/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeSubServiceCell : HeBaseTableViewCell
//服务名称
@property(strong,nonatomic)UILabel *serviceNameLabel;
//服务按钮
@property(strong,nonatomic)UIButton *serviceButton;
//选择事件
@property (nonatomic,strong)void(^selectBlock)();

@end
