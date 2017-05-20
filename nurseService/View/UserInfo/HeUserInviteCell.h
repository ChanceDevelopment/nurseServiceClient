//
//  HeUserInviteCell.h
//  nurseService
//
//  Created by Tony on 2017/1/19.
//  Copyright © 2017年 iMac. All rights reserved.
//  用户的邀请

#import "HeBaseTableViewCell.h"

@interface HeUserInviteCell : HeBaseTableViewCell
//邀请人的头像
@property(strong,nonatomic)UIImageView *userImage;
//邀请人名字
@property(strong,nonatomic)UILabel *nameLabel;

@end
