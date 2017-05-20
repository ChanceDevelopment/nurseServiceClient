//
//  HeSearchNurseTableCell.h
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//  搜索护士列表视图模板，参考HeSearchNurseTableCell

#import "HeBaseTableViewCell.h"

@interface HeSearchNurseTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UIButton *selectButton;
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *professionLabel;
@property(strong,nonatomic)UILabel *hospitalLabel;
@property(strong,nonatomic)UILabel *tipLabel;
@property(strong,nonatomic)UILabel *addresssLabel;
@property(strong,nonatomic)UILabel *distanceLabel;

@end
