//
//  HeServiceCommentCell.h
//  nurseService
//
//  Created by Tony on 2017/1/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeServiceCommentCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *phoneLabel;
@property(strong,nonatomic)UILabel *commentContentLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UIView *commentRankView;
@property(assign,nonatomic)NSInteger commentRank;

@property(strong,nonatomic)UILabel *serviceLabel;

@end
