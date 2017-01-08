//
//  HeNurseTableViewCell.h
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeNurseTableViewCell : HeBaseTableViewCell
@property(strong,nonatomic)UIButton *selectButton;
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *professionLabel;
@property(strong,nonatomic)UILabel *hospitalLabel;
@property(strong,nonatomic)UILabel *tipLabel;
@property(strong,nonatomic)UILabel *addresssLabel;
@property(strong,nonatomic)UILabel *distanceLabel;

@end
