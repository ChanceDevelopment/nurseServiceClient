//
//  HeUserCouponCell.h
//  nurseService
//
//  Created by Tony on 2017/1/19.
//  Copyright © 2017年 iMac. All rights reserved.
//  用户优惠券

#import "HeBaseTableViewCell.h"

@interface HeUserCouponCell : HeBaseTableViewCell
//用户优惠券banner图
@property(strong,nonatomic)UIImageView *headImageView;
//优惠券内容
@property(strong,nonatomic)UILabel *contentLabel;
//有效期
@property(strong,nonatomic)UILabel *timeLabel;
//优惠价格
@property(strong,nonatomic)UILabel *priceLabel;
//优惠条件
@property(strong,nonatomic)UILabel *conditionLabel;

@end
