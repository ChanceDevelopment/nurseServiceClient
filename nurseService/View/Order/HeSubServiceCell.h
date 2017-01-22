//
//  HeSubServiceCell.h
//  nurseService
//
//  Created by Tony on 2017/1/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeSubServiceCell : HeBaseTableViewCell
@property(strong,nonatomic)UILabel *serviceNameLabel;
@property(strong,nonatomic)UIButton *serviceButton;

@property (nonatomic,strong)void(^selectBlock)();

@end
