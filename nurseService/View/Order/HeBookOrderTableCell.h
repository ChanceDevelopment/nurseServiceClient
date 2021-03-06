//
//  HeBookOrderTableCell.h
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//  已预约订单模板，属性意义参考HeOrderTableViewCell

#import "HeBaseTableViewCell.h"

@interface HeBookOrderTableCell : HeBaseTableViewCell
@property (nonatomic,strong)UILabel *serviceContentL;
@property (nonatomic,strong)UILabel *stopTimeL;
@property (nonatomic,strong)UILabel *orderMoney;
@property (nonatomic,strong)UILabel *addressL;
@property (nonatomic,strong)UILabel *userInfoL;
@property (nonatomic,strong)UILabel *payStatusLabel;

@property (nonatomic,strong)void(^showOrderDetailBlock)();
@property (nonatomic,strong)void(^locationBlock)();
@property (nonatomic,strong)void(^showUserInfoBlock)();
@property (nonatomic,strong)void(^cancleServiceBlock)();

@property(strong,nonatomic)NSDictionary *orderInfoDict;

//0:预约框  1:已预约  2:进行中  3:已完成
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize orderType:(NSInteger)orderType;

@end
