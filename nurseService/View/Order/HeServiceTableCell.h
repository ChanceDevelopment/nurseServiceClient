//
//  HeServiceTableCell.h
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//  服务列表视图模板

#import "HeBaseTableViewCell.h"

@interface HeServiceTableCell : HeBaseTableViewCell
//用户头像
@property(strong,nonatomic)UIImageView *userImage;
//服务项目的标题
@property(strong,nonatomic)UILabel *serviceTitleLabel;
//服务适用人群
@property(strong,nonatomic)UILabel *peopleLabel;
//服务次数
@property(strong,nonatomic)UILabel *numberLabel;
//预订按钮
@property(strong,nonatomic)UIButton *bookButton;
//服务价格
@property(strong,nonatomic)UILabel *priceLabel;

//预订方法
@property (nonatomic,strong)void(^booklBlock)();

@end
