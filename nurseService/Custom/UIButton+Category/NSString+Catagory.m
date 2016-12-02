//
//  NSString+Catagory.m
//  com.mant.iosClient
//
//  Created by Gavin on 13-5-29.
//  Copyright (c) 2013年 何栋明. All rights reserved.
//

#import "NSString+Catagory.h"

@implementation NSString (Catagory)

+(NSString *)trim:(NSString*)string
{
    NSString *trimString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimString;
}

@end
