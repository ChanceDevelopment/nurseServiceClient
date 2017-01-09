//
//  HeServiceTableCell.h
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeServiceTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *serviceTitleLabel;
@property(strong,nonatomic)UILabel *peopleLabel;
@property(strong,nonatomic)UILabel *numberLabel;
@property(strong,nonatomic)UIButton *bookButton;
@property(strong,nonatomic)UILabel *priceLabel;

@property (nonatomic,strong)void(^booklBlock)();

@end
