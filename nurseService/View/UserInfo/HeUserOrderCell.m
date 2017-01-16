//
//  HeUserOrderCell.m
//  nurseService
//
//  Created by Tony on 2017/1/17.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserOrderCell.h"

@implementation HeUserOrderCell
@synthesize serviceContentL;
@synthesize stopTimeL;
@synthesize orderMoney;
@synthesize addressL;
@synthesize userInfoL;
@synthesize payStatusLabel;
@synthesize orderInfoDict;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize orderType:(NSInteger)orderType orderState:(NSInteger)orderState
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        
        CGFloat bgView_X = 10;
        CGFloat bgView_Y = 5;
        CGFloat bgView_W = SCREENWIDTH - 2 * bgView_X;
        CGFloat bgView_H = cellsize.height - 2 * bgView_Y;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(bgView_X, bgView_Y, bgView_W, bgView_H)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.userInteractionEnabled = YES;
        [self addSubview:bgView];
        [bgView.layer setMasksToBounds:YES];
        bgView.layer.cornerRadius = 4.0;
        
        
        
        CGFloat orderViewX = 10;
        CGFloat orderViewY = 0;
        CGFloat orderViewW = bgView_W - 2 * orderViewX;
        CGFloat orderViewH = 54;
        
        UIView *orderView = [[UIView alloc] initWithFrame:CGRectMake(orderViewX, orderViewY, orderViewW, orderViewH)];
        orderView.backgroundColor = [UIColor whiteColor];
        orderView.userInteractionEnabled = YES;
        [bgView addSubview:orderView];
        
        CGFloat serviceContentLX = 0;
        CGFloat serviceContentLY = 0;
        CGFloat serviceContentLW = orderViewW;
        CGFloat serviceContentLH = orderViewH;
        
        serviceContentL = [[UILabel alloc] initWithFrame:CGRectMake(serviceContentLX, serviceContentLY, serviceContentLW, serviceContentLH)];
        serviceContentL.text = @"产妇护理套餐";
        serviceContentL.userInteractionEnabled = YES;
        serviceContentL.textColor = APPDEFAULTORANGE;
        serviceContentL.font = [UIFont systemFontOfSize:15.0];
        serviceContentL.backgroundColor = [UIColor clearColor];
        [orderView addSubview:serviceContentL];
        
        
        CGFloat payStatusLabelY = 0;
        CGFloat payStatusLabelW = 100;
        CGFloat payStatusLabelH = serviceContentLH;
        CGFloat payStatusLabelX = orderViewW - payStatusLabelW - 5;
        
        payStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(payStatusLabelX, payStatusLabelY, payStatusLabelW, payStatusLabelH)];
        if (orderType == 0) {
            payStatusLabel.text = @"待支付";
        }
        else{
            switch (orderState) {
                case 0:
                {
                    payStatusLabel.text = @"已预约";
                    break;
                }
                case 1:
                {
                    payStatusLabel.text = @"进行中";
                    break;
                }
                case 2:
                {
                    payStatusLabel.text = @"已完成";
                    break;
                }
                default:
                    break;
            }
        }
        
        payStatusLabel.textAlignment = NSTextAlignmentRight;
        payStatusLabel.userInteractionEnabled = YES;
        payStatusLabel.textColor = APPDEFAULTORANGE;
        payStatusLabel.font = [UIFont systemFontOfSize:15.0];
        payStatusLabel.backgroundColor = [UIColor clearColor];
        [orderView addSubview:payStatusLabel];
        
        UIImageView *rightV = [[UIImageView alloc] initWithFrame:CGRectMake(orderViewW - 20, (orderViewH - 20) / 2.0, 20, 20)];
        rightV.backgroundColor = [UIColor clearColor];
        rightV.image = [UIImage imageNamed:@"icon_into_right"];
        rightV.userInteractionEnabled = YES;
//        [orderView addSubview:rightV];
        
//        UITapGestureRecognizer *showOrderDetailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrderDetail)];
//        [orderView addGestureRecognizer:showOrderDetailTap];
        
        CGFloat lineX = 5;
        CGFloat lineY = CGRectGetMaxY(orderView.frame);
        CGFloat lineW = bgView_W - 2 * lineX;
        CGFloat lineH = 1;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
        [bgView addSubview:line];
        line.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        
        CGFloat timeAddressViewX = 0;
        CGFloat timeAddressViewY = CGRectGetMaxY(line.frame);
        CGFloat timeAddressViewW = bgView_W;
        CGFloat timeAddressViewH = 50;
        UIView *timeAddressView = [[UIView alloc] initWithFrame:CGRectMake(timeAddressViewX, timeAddressViewY, timeAddressViewW, timeAddressViewH)];
        timeAddressView.backgroundColor = [UIColor whiteColor];
        [bgView addSubview:timeAddressView];
        
        CGFloat stopTimeLX = 10;
        CGFloat stopTimeLY = 0;
        CGFloat stopTimeLW = 200;
        CGFloat stopTimeLH = timeAddressViewH / 2.0;
        
        stopTimeL = [[UILabel alloc] initWithFrame:CGRectMake(stopTimeLX, stopTimeLY, stopTimeLW, stopTimeLH)];
        stopTimeL.text = @"01/10 周二 08:00";
        stopTimeL.textColor = [UIColor blackColor];
        stopTimeL.font = [UIFont systemFontOfSize:14.0];
        stopTimeL.backgroundColor = [UIColor clearColor];
        [timeAddressView addSubview:stopTimeL];
        
        
        CGFloat orderMoneyY = 0;
        CGFloat orderMoneyW = 100;
        CGFloat orderMoneyX = timeAddressViewW - orderMoneyW - 10;
        CGFloat orderMoneyH = stopTimeLH;
        
        orderMoney = [[UILabel alloc] initWithFrame:CGRectMake(orderMoneyX, orderMoneyY, orderMoneyW, orderMoneyH)];
        orderMoney.text = @"￥335";
        orderMoney.textColor = [UIColor redColor];
        orderMoney.textAlignment = NSTextAlignmentRight;
        orderMoney.font = [UIFont systemFontOfSize:15.0];
        orderMoney.backgroundColor = [UIColor clearColor];
        [timeAddressView addSubview:orderMoney];
        
        CGFloat addressLX = 10;
        CGFloat addressLY = CGRectGetMaxY(stopTimeL.frame);
        CGFloat addressLW = timeAddressViewW - 2 *addressLX;
        CGFloat addressLH = stopTimeLH;
        
        addressL = [[UILabel alloc] initWithFrame:CGRectMake(addressLX, addressLY, addressLW, addressLH)];
        addressL.text = @"广东省中山市西区";
        addressL.textColor = [UIColor blackColor];
        addressL.font = [UIFont systemFontOfSize:13.0];
        addressL.backgroundColor = [UIColor clearColor];
        [timeAddressView addSubview:addressL];
        
        UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(timeAddressViewW - 30, CGRectGetMaxY(stopTimeL.frame), 20, 20)];
        [locationImageView setBackgroundColor:[UIColor clearColor]];
        locationImageView.userInteractionEnabled = YES;
        locationImageView.image = [UIImage imageNamed:@"icon_address"];
        [timeAddressView addSubview:locationImageView];
        
//        UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToLocationView)];
//        locationTap.numberOfTapsRequired = 1;
//        locationTap.numberOfTouchesRequired = 1;
//        [timeAddressView addGestureRecognizer:locationTap];
        
        CGFloat line1X = 5;
        CGFloat line1Y = CGRectGetMaxY(timeAddressView.frame);
        CGFloat line1W = bgView_W - 2 * line1X;
        CGFloat line1H = 1;
        
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(line1X, line1Y, line1W, line1H)];
        [bgView addSubview:line1];
        line1.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        
        CGFloat userTipX = 10;
        CGFloat userTipY = CGRectGetMaxY(line1.frame);
        CGFloat userTipW = 80;
        CGFloat userTipH = 40;
        
        UILabel *userTip = [[UILabel alloc] initWithFrame:CGRectMake(userTipX, userTipY, userTipW, userTipH)];
        userTip.textColor = [UIColor blackColor];
        userTip.text = @"患者信息";
        userTip.font = [UIFont systemFontOfSize:15.0];
        userTip.backgroundColor = [UIColor clearColor];
        [bgView addSubview:userTip];
        
        
        CGFloat userInfoLY = userTipY;
        CGFloat userInfoLX = 10;
        CGFloat userInfoLW = bgView_W - userInfoLX - 10;
        
        CGFloat userInfoLH = userTipH;
        
        userInfoL = [[UILabel alloc] initWithFrame:CGRectMake(userInfoLX, userInfoLY, userInfoLW, userInfoLH)];
        userInfoL.textColor = [UIColor blackColor];
        userInfoL.text = @"小明 男 22岁";
        userInfoL.userInteractionEnabled = YES;
        userInfoL.font = [UIFont systemFontOfSize:15.0];
        userInfoL.textAlignment = NSTextAlignmentRight;
        userInfoL.backgroundColor = [UIColor clearColor];
        [bgView addSubview:userInfoL];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

@end
