//
//  HeCommentCell.h
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeCommentCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *phoneLabel;
@property(strong,nonatomic)UILabel *commentContentLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UIView *commentRankView;

@end
