//
//  HeCommentCell.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeCommentCell.h"

@implementation HeCommentCell
@synthesize userImage;
@synthesize phoneLabel;
@synthesize commentContentLabel;
@synthesize timeLabel;
@synthesize commentRankView;
@synthesize commentRank;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat userImageX = 10;
        CGFloat userImageY = 15;
        CGFloat userImageH = cellsize.height - 2 * userImageY - 10;
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
        
        phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
        phoneLabel.backgroundColor = [UIColor clearColor];
        phoneLabel.textColor = [UIColor blackColor];
        phoneLabel.font = textFont;
        phoneLabel.text = @"13790730692";
        [self addSubview:phoneLabel];
        
        CGFloat commentContentLabelH = 20;
        CGFloat commentContentLabelX = CGRectGetMaxX(userImage.frame) + 5;
        CGFloat commentContentLabelY = CGRectGetMaxY(userImage.frame) - commentContentLabelH;
        CGFloat commentContentLabelW = SCREENWIDTH - commentContentLabelX - 10;
        
        commentContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentContentLabelX, commentContentLabelY, commentContentLabelW, commentContentLabelH)];
        commentContentLabel.backgroundColor = [UIColor clearColor];
        commentContentLabel.textColor = [UIColor blackColor];
        commentContentLabel.font = textFont;
        commentContentLabel.numberOfLines = 2;
        commentContentLabel.text = @"非常专业，宝宝的病一下子就好了";
        [self addSubview:commentContentLabel];
        
        
        CGFloat timeLabelH = 30;
        CGFloat timeLabelY = cellsize.height - timeLabelH;
        CGFloat timeLabelW = 150;
        CGFloat timeLabelX = SCREENWIDTH - timeLabelW - 10;
        
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
        
        commentRankView = [[UIView alloc] initWithFrame:CGRectMake(commentRankViewX, commentRankViewY, commentRankViewW, commentRankViewH)];
        [self addSubview:commentRankView];
        
    }
    return self;
}

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
