//
//  HeServiceCommentCell.m
//  nurseService
//
//  Created by Tony on 2017/1/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeServiceCommentCell.h"

@implementation HeServiceCommentCell
@synthesize userImage;
@synthesize phoneLabel;
@synthesize commentContentLabel;
@synthesize timeLabel;
@synthesize commentRankView;
@synthesize commentRank;
@synthesize serviceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        //评论人头像
        CGFloat userImageX = 10;
        CGFloat userImageY = 10;
        CGFloat userImageH = 70;
        CGFloat userImageW = userImageH;
        userImage = [[UIImageView alloc] initWithFrame:CGRectMake(userImageX, userImageY, userImageW, userImageH)];
        userImage.layer.cornerRadius = userImageW / 2.0;
        userImage.layer.masksToBounds = YES;
        userImage.layer.borderWidth = 0;
        userImage.layer.borderColor = [UIColor clearColor].CGColor;
        userImage.contentMode = UIViewContentModeScaleAspectFill;
        userImage.image = [UIImage imageNamed:@"defalut_icon"];
        [self addSubview:userImage];
        
        UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:15.0];
        CGFloat nameLabelX = CGRectGetMaxX(userImage.frame) + 5;
        CGFloat nameLabelY = userImageY;
        CGFloat nameLabelW = 100;
        CGFloat nameLabelH = 20;
        //评论人联系方式
        phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
        phoneLabel.backgroundColor = [UIColor clearColor];
        phoneLabel.textColor = [UIColor blackColor];
        phoneLabel.font = textFont;
        phoneLabel.text = @"13790730692";
        [self addSubview:phoneLabel];
        
        CGFloat serviceLabelH = 20;
        CGFloat serviceLabelX = CGRectGetMaxX(userImage.frame) + 5;
        CGFloat serviceLabelY = CGRectGetMaxY(userImage.frame) - serviceLabelH;
        CGFloat serviceLabelW = SCREENWIDTH - serviceLabelX - 10;
        //评论的服务项目
        serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(serviceLabelX, serviceLabelY, serviceLabelW, serviceLabelH)];
        serviceLabel.backgroundColor = [UIColor clearColor];
        serviceLabel.textColor = [UIColor grayColor];
        serviceLabel.font = textFont;
        serviceLabel.numberOfLines = 1;
        serviceLabel.text = @"服务项目";
        [self addSubview:serviceLabel];
        
        CGFloat commentContentLabelH = 30;
        CGFloat commentContentLabelX = CGRectGetMinX(userImage.frame) + 5;
        CGFloat commentContentLabelY = CGRectGetMaxY(userImage.frame);
        CGFloat commentContentLabelW = SCREENWIDTH - commentContentLabelX - 10;
        //评论内容
        commentContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentContentLabelX, commentContentLabelY, commentContentLabelW, commentContentLabelH)];
        commentContentLabel.backgroundColor = [UIColor clearColor];
        commentContentLabel.textColor = [UIColor blackColor];
        commentContentLabel.font = textFont;
        commentContentLabel.numberOfLines = 1;
        commentContentLabel.text = @"非常专业，宝宝的病一下子就好了";
        [self addSubview:commentContentLabel];
        
        
        CGFloat timeLabelH = 30;
        CGFloat timeLabelY = cellsize.height - timeLabelH;
        CGFloat timeLabelW = 150;
        CGFloat timeLabelX = SCREENWIDTH - timeLabelW - 10;
        //评论时间
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = textFont;
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.numberOfLines = 1;
        timeLabel.text = @"2017/01/09";
        [self addSubview:timeLabel];
        
        
        CGFloat commentRankViewH = 20;
        CGFloat commentRankViewY = userImageY;
        CGFloat commentRankViewW = 120;
        CGFloat commentRankViewX = SCREENWIDTH - commentRankViewW - 10;
        //评论等级
        commentRankView = [[UIView alloc] initWithFrame:CGRectMake(commentRankViewX, commentRankViewY, commentRankViewW, commentRankViewH)];
        [self addSubview:commentRankView];
        
    }
    return self;
}
//设置评论等级
- (void)setCommentRank:(NSInteger)_commentRank
{
    commentRank = _commentRank;
    NSArray *subArray = commentRankView.subviews;
    for (UIView *subView in subArray) {
        [subView removeFromSuperview];
    }
    [self commentWithRank:commentRank];
}
- (void)commentWithRank:(NSInteger)rank
{
    //rank评论等级，最高五星rank = 5
    if (rank >= 5) {
        rank = 5;
    }
    CGFloat starX = 0;
    CGFloat starY = 0;
    CGFloat starH = 20;
    CGFloat starW = 20;
    CGFloat starDistance = 5;
    
    for (NSInteger index = 0; index < 5; index++) {
        NSString *starName = @"icon_star_normal";
        if (index + 1 <= rank) {
            //黄色星星
            starName = @"icon_star_yellow";
        }
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(starX, starY, starW, starH)];
        icon.image = [UIImage imageNamed:starName];
        starX = starX + starW + starDistance;
        [commentRankView addSubview:icon];
    }
}

@end
