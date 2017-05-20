//
//  HeCommentCell.h
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//  评论列表视图模板

#import "HeBaseTableViewCell.h"

@interface HeCommentCell : HeBaseTableViewCell
//评论人头像
@property(strong,nonatomic)UIImageView *userImage;
//评论人联系方式
@property(strong,nonatomic)UILabel *phoneLabel;
//评论内容
@property(strong,nonatomic)UILabel *commentContentLabel;
//评论时间
@property(strong,nonatomic)UILabel *timeLabel;
//评论等级
@property(strong,nonatomic)UIView *commentRankView;
@property(assign,nonatomic)NSInteger commentRank;

@end
