//
//  HeNurseTableViewCell.h
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//  护士列表视图模板

#import "HeBaseTableViewCell.h"

@interface HeNurseTableViewCell : HeBaseTableViewCell
//预约按钮
@property(strong,nonatomic)UIButton *selectButton;
//护士头像
@property(strong,nonatomic)UIImageView *userImage;
//护士名称
@property(strong,nonatomic)UILabel *nameLabel;
//护士专业
@property(strong,nonatomic)UILabel *professionLabel;
//护士所属医院
@property(strong,nonatomic)UILabel *hospitalLabel;
//提示信息
@property(strong,nonatomic)UILabel *tipLabel;
//护士地址
@property(strong,nonatomic)UILabel *addresssLabel;
//与护士距离
@property(strong,nonatomic)UILabel *distanceLabel;
//加载该护士服务项目
@property (nonatomic,strong)void(^loadServiceBlock)();

@end
