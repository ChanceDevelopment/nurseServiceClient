//
//  HeServiceTableCell.m
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeServiceTableCell.h"

@implementation HeServiceTableCell
@synthesize userImage;
@synthesize serviceTitleLabel;
@synthesize peopleLabel;
@synthesize numberLabel;
@synthesize bookButton;
@synthesize priceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        
        CGFloat userImageX = 10;
        CGFloat userImageY = 15;
        CGFloat userImageH = cellsize.height - 2 * userImageY;
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
        CGFloat nameLabelW = SCREENWIDTH - nameLabelX - 80;
        CGFloat nameLabelH = userImageH / 3.0;
        
        serviceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
        serviceTitleLabel.backgroundColor = [UIColor clearColor];
        serviceTitleLabel.textColor = [UIColor blackColor];
        serviceTitleLabel.font = [UIFont systemFontOfSize:17.0];
        serviceTitleLabel.text = @"新生儿护理";
        [self addSubview:serviceTitleLabel];
        
        CGFloat peopleLabelX = nameLabelX;
        CGFloat peopleLabelY = CGRectGetMaxY(serviceTitleLabel.frame);
        CGFloat peopleLabelW = 100;
        CGFloat peopleLabelH = userImageH / 3.0;
        
        peopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(peopleLabelX, peopleLabelY, peopleLabelW, peopleLabelH)];
        peopleLabel.backgroundColor = [UIColor clearColor];
        peopleLabel.textColor = [UIColor blackColor];
        peopleLabel.font = [UIFont systemFontOfSize:13.0];
        peopleLabel.text = @"0 - 1周岁";
        [self addSubview:peopleLabel];
        
        CGFloat numberLabelX = nameLabelX;
        CGFloat numberLabelY = CGRectGetMaxY(peopleLabel.frame);
        CGFloat numberLabelW = 150;
        CGFloat numberLabelH = userImageH / 3.0;
        
        numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(numberLabelX, numberLabelY, numberLabelW, numberLabelH)];
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.textColor = [UIColor grayColor];
        numberLabel.font = [UIFont systemFontOfSize:15.0];
        numberLabel.text = @"服务次数: 0次";
        [self addSubview:numberLabel];
        
        
        
        CGFloat selectButtonW = 50;
        CGFloat selectButtonX = SCREENWIDTH - 10 - selectButtonW;
        CGFloat selectButtonH = 25;
        CGFloat selectButtonY = (cellsize.height - selectButtonH) / 2.0;
        
        bookButton = [[UIButton alloc] initWithFrame:CGRectMake(selectButtonX, selectButtonY, selectButtonW, selectButtonH)];
        [bookButton setTitle:@"预约" forState:UIControlStateNormal];
        bookButton.layer.cornerRadius = 3.0;
        bookButton.layer.masksToBounds = YES;
        bookButton.layer.borderWidth = 1.0;
        bookButton.layer.borderColor = APPDEFAULTORANGE.CGColor;
        [bookButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
        [bookButton addTarget:self action:@selector(bookButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        bookButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:bookButton];
    
        
        
        CGFloat priceLabelY = CGRectGetMaxY(bookButton.frame) + 2;
        CGFloat priceLabelW = 80;
        CGFloat priceLabelX = SCREENWIDTH - priceLabelW - 10;
        CGFloat priceLabelH = 20;
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = [UIColor redColor];
        priceLabel.font = [UIFont systemFontOfSize:17.0];
        priceLabel.text = @"￥300.00";
        [self addSubview:priceLabel];
        
        
        
    }
    return self;
}

- (void)bookButtonClick:(id)sender
{
    if (self.booklBlock) {
        self.booklBlock();
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
