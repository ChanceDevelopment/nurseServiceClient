//
//  HeBalanceDetailCell.h
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//  余额详情的视图列表模板

#import "HeBaseTableViewCell.h"

@interface HeBalanceDetailCell : HeBaseTableViewCell
//价格的标签
@property(strong,nonatomic)UILabel *moneyLabel;
//内容的标签
@property(strong,nonatomic)UILabel *contentLabel;
//时间的标签
@property(strong,nonatomic)UILabel *timeLabel;

@end
