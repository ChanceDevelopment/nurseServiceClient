//
//  HeUserCouponCell.h
//  nurseService
//
//  Created by Tony on 2017/1/19.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeUserCouponCell : HeBaseTableViewCell
@property(strong,nonatomic)UILabel *contentLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UILabel *priceLabel;
@property(strong,nonatomic)UILabel *conditionLabel;

@end
