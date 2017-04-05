//
//  RegularTool.h
//  TimeRent
//
//  Created by Jiada on 17/1/19.
//  Copyright © 2017年 channce. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kTelephoneNumber = 0,
    kEmail,
} RegularType;


@interface RegularTool : NSObject


+ (BOOL)checkTelephoneNumber:(NSString *)telephoneNumber;
+ (BOOL)checkIdentityCard: (NSString *)identityCard;
+ (BOOL)checkEmailStr:(NSString *)emailStr;
+ (BOOL)verifyIDCardNumber:(NSString *)IDCardNumber;
+ (BOOL)checkCardNo:(NSString*)cardNo;
/**
 *  支付宝返回字段解析
 *
 *  @param AllString            字段
 *  @param FirstSeparateString  第一个分离字段的词
 *  @param SecondSeparateString 第二个分离字段的词
 *
 *  @return 返回字典
 */
+(NSDictionary *)VEComponentsStringToDic:(NSString*)AllString withSeparateString:(NSString *)FirstSeparateString AndSeparateString:(NSString *)SecondSeparateString;


@end
