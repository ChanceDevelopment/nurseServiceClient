//
//  HeNurseTableViewCell.m
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//  护士列表视图模板

#import "HeNurseTableViewCell.h"
#import "ImageScale.h"

@implementation HeNurseTableViewCell
@synthesize selectButton;
@synthesize userImage;
@synthesize nameLabel;
@synthesize professionLabel;
@synthesize hospitalLabel;
@synthesize tipLabel;
@synthesize addresssLabel;
@synthesize distanceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat buttonBGViewX = 0;
        CGFloat buttonBGViewW = 50;
        CGFloat buttonBGViewH = cellsize.height;
        CGFloat buttonBGViewY = (cellsize.height - buttonBGViewH) / 2.0;
        UIView *buttonBGView = [[UIView alloc] initWithFrame:CGRectMake(buttonBGViewX, buttonBGViewY, buttonBGViewW, buttonBGViewH)];
        buttonBGView.backgroundColor = [UIColor whiteColor];
        [self addSubview:buttonBGView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapges:)];
        [buttonBGView addGestureRecognizer:tap];
        
        CGFloat selectButtonW = 30;
        CGFloat selectButtonH = 30;
        CGFloat selectButtonX = (buttonBGViewW - selectButtonW) / 2.0;
        
        CGFloat selectButtonY = (cellsize.height - selectButtonH) / 2.0;
        
        selectButton = [[UIButton alloc] initWithFrame:CGRectMake(selectButtonX, selectButtonY, selectButtonW, selectButtonH)];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"unselect_box"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_box"] forState:UIControlStateSelected];
        [selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonBGView addSubview:selectButton];
        
        CGFloat userImageX = CGRectGetMaxX(buttonBGView.frame) + 2;
        CGFloat userImageY = 15;
        CGFloat userImageH = cellsize.height - 2 * userImageY;
        CGFloat userImageW = userImageH;
        userImage = [[UIImageView alloc] initWithFrame:CGRectMake(userImageX, userImageY, userImageW, userImageH)];
        userImage.image = [UIImage imageNamed:@"defalut_icon"];
        userImage.layer.cornerRadius = userImage.frame.size.width / 2.0;
        userImage.layer.masksToBounds = YES;
        userImage.layer.borderWidth = 0;
        userImage.layer.borderColor = [UIColor clearColor].CGColor;
        userImage.contentMode = UIViewContentModeScaleAspectFill;
        
        [self addSubview:userImage];
        
        UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:13.0];
        CGFloat nameLabelX = CGRectGetMaxX(userImage.frame) + 5;
        CGFloat nameLabelY = userImageY;
        CGFloat nameLabelW = 80;
        CGFloat nameLabelH = userImageH / 3.0;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
        nameLabel.numberOfLines = 2;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = textFont;
        nameLabel.text = @"小明";
        [self addSubview:nameLabel];
        
        CGFloat professionLabelX = CGRectGetMaxX(nameLabel.frame) + 5;
        CGFloat professionLabelY = userImageY;
        CGFloat professionLabelW = 40;
        CGFloat professionLabelH = userImageH / 3.0;
        
        professionLabel = [[UILabel alloc] initWithFrame:CGRectMake(professionLabelX, professionLabelY, professionLabelW, professionLabelH)];
        professionLabel.backgroundColor = [UIColor clearColor];
        professionLabel.textColor = [UIColor blackColor];
        professionLabel.font = textFont;
        professionLabel.text = @"护士";
        [self addSubview:professionLabel];
        
        CGFloat hospitalLabelX = CGRectGetMaxX(professionLabel.frame);
        CGFloat hospitalLabelY = userImageY;
        CGFloat hospitalLabelW = SCREENWIDTH - 10 - hospitalLabelX;
        
        CGFloat hospitalLabelH = userImageH / 3.0;
        
        hospitalLabel = [[UILabel alloc] initWithFrame:CGRectMake(hospitalLabelX, hospitalLabelY, hospitalLabelW, hospitalLabelH)];
        hospitalLabel.textAlignment = NSTextAlignmentRight;
        hospitalLabel.backgroundColor = [UIColor clearColor];
        hospitalLabel.textColor = [UIColor grayColor];
        hospitalLabel.font = textFont;
        hospitalLabel.text = @"该护士未选定医院";
        [self addSubview:hospitalLabel];
        
        CGFloat tipLabelY = CGRectGetMaxY(nameLabel.frame);
        CGFloat tipLabelX = nameLabelX;
        CGFloat tipLabelW = SCREENWIDTH - tipLabelX - 30;
        CGFloat tipLabelH = userImageH / 3.0;
        
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipLabelX, tipLabelY, tipLabelW, tipLabelH)];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.font = textFont;
        tipLabel.text = @"国家卫委认证 已实名认证";
        [self addSubview:tipLabel];
        
        CGFloat addresssLabelY = CGRectGetMaxY(tipLabel.frame) + 5;
        CGFloat addresssLabelW = (SCREENWIDTH - nameLabelX - 10) / 2.0;
        CGFloat addresssLabelH = userImageH / 3.0;
        CGFloat addresssLabelX = nameLabelX;
        addresssLabel = [[UILabel alloc] initWithFrame:CGRectMake(addresssLabelX, addresssLabelY, addresssLabelW, addresssLabelH)];
        addresssLabel.backgroundColor = [UIColor clearColor];
        addresssLabel.textColor = [UIColor grayColor];
        addresssLabel.font = textFont;
        addresssLabel.text = @"古巴";
        [self addSubview:addresssLabel];
        
        
        CGFloat distanceLabelY = CGRectGetMaxY(tipLabel.frame) + 5;
        CGFloat distanceLabelW = 90;
        CGFloat distanceLabelH = userImageH / 3.0;
        CGFloat distanceLabelX = SCREENWIDTH - distanceLabelW - 10;
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(distanceLabelX, distanceLabelY, distanceLabelW, distanceLabelH)];
        distanceLabel.textAlignment = NSTextAlignmentRight;
        distanceLabel.backgroundColor = [UIColor clearColor];
        distanceLabel.textColor = [UIColor grayColor];
        distanceLabel.font = textFont;
        distanceLabel.font = textFont;
        distanceLabel.text = @"100.29km";
        [self addSubview:distanceLabel];
        
        CGFloat locationIconW = 20;
        CGFloat locationIconH = 20;
        CGFloat locationIconX = 5;
        CGFloat locationIconY = (distanceLabelH - locationIconH) / 2.0;
        
        UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_address"]];
        locationIcon.frame = CGRectMake(locationIconX, locationIconY, locationIconW, locationIconH);
        [distanceLabel addSubview:locationIcon];
        
    }
    return self;
}

- (void)tapges:(UITapGestureRecognizer *)ges
{
    NSLog(@"Ges = %@",ges);
}
//加载该护士服务项目
- (void)selectButtonClick:(UIButton *)button
{
    NSLog(@"selectButtonClick");
    button.selected = !button.selected;
    if (self.loadServiceBlock) {
        self.loadServiceBlock();
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
