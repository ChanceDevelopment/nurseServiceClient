//
//  User.m
//  iGangGan
//
//  Created by HeDongMing on 15/12/14.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import "User.h"

@implementation User


- (User *)initUserWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if (dict) {
            NSString *username = [dict objectForKey:@"username"];
            if ([username isMemberOfClass:[NSNull class]] || username == nil) {
                username = @"";
            }
            self.username = username;
            
            NSString *nickname = [dict objectForKey:@"nickName"];
            if ([nickname isMemberOfClass:[NSNull class]] || nickname == nil) {
                nickname = @"";
            }
            self.nickname = nickname;
            
            BOOL isnewappuser = [[dict objectForKey:@"isnewappuser"] boolValue];
            self.isnewappuser = isnewappuser;
            
            BOOL hasMultiUser = [[dict objectForKey:@"hasMultiUser"] boolValue];
            self.hasMultiUser = hasMultiUser;
            
            NSString *truename = [dict objectForKey:@"truename"];
            if ([truename isMemberOfClass:[NSNull class]] || truename == nil) {
                truename = @"";
            }
            self.truename = truename;
            
            NSString *roles = [dict objectForKey:@"roles"];
            if ([roles isMemberOfClass:[NSNull class]] || roles == nil) {
                roles = @"";
            }
            self.roles = roles;
            
            
            NSString *usertoken = [dict objectForKey:@"t_token"];
            if ([usertoken isMemberOfClass:[NSNull class]] || usertoken == nil) {
                usertoken = @"";
            }
            self.usertoken = usertoken;
            
            
            NSString *headurl = [dict objectForKey:@"photo"];
            if ([headurl isMemberOfClass:[NSNull class]] || headurl == nil) {
                headurl = [dict objectForKey:@"userPhoto"];
                if ([headurl isMemberOfClass:[NSNull class]] || headurl == nil) {
                    headurl = @"";
                    
                }
                
            }
            if (![headurl hasPrefix:@"http"]) {
                self.headurl = [NSString stringWithFormat:@"%@%@",HYTIMAGEURL,headurl];
            }
            else{
                self.headurl = [NSString stringWithFormat:@"%@",headurl];
            }
            
            NSString *userID = [dict objectForKey:@"id"];
            if ([userID isMemberOfClass:[NSNull class]] || userID == nil) {
                userID = @"";
            }
            self.userID = userID;
            
            
            id birthdayObj = [dict objectForKey:@"birthday"];
            if ([birthdayObj isMemberOfClass:[NSNull class]] || birthdayObj == nil) {
                NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
                birthdayObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
            }
            long long timestamp = [birthdayObj longLongValue];
            NSString *birthday = [NSString stringWithFormat:@"%lld",timestamp];
            if ([birthday length] > 3) {
                //时间戳
                birthday = [birthday substringToIndex:[birthday length] - 3];
            }
            birthday = [Tool convertTimespToString:[birthday longLongValue] dateFormate:@"YYYY-MM-dd"];
            if ([birthday isMemberOfClass:[NSNull class]] || birthday == nil) {
                birthday = @"";
            }
            self.birthday = birthday;
         
            NSString *schoolName = [dict objectForKey:@"schoolName"];
            if ([schoolName isMemberOfClass:[NSNull class]] || schoolName == nil) {
                schoolName = @"";
            }
            self.schoolName = schoolName;
            
            
            NSString *relation = [dict objectForKey:@"relation"];
            if ([relation isMemberOfClass:[NSNull class]] || relation == nil) {
                relation = @"";
            }
            self.relation = relation;
            
            NSString *className = [dict objectForKey:@"className"];
            if ([className isMemberOfClass:[NSNull class]] || className == nil) {
                className = @"";
            }
            self.className = className;
        }
        
    }
    return self;
}

- (User *)initUserWithUser:(User *)user
{
    self = [super init];
    if (self) {
        if (user) {
            
            NSString *username = user.username;
            if ([username isMemberOfClass:[NSNull class]] || username == nil) {
                username = @"";
            }
            self.username = username;
            
            NSString *nickname = user.nickname;
            if ([nickname isMemberOfClass:[NSNull class]] || nickname == nil) {
                nickname = @"";
            }
            self.nickname = nickname;
            
            NSString *truename = user.truename;
            if ([truename isMemberOfClass:[NSNull class]] || truename == nil) {
                truename = @"";
            }
            self.truename = truename;
            
            self.isnewappuser = user.isnewappuser;
            
            self.hasMultiUser = user.hasMultiUser;
            
            NSString *roles = user.roles;
            if ([roles isMemberOfClass:[NSNull class]] || roles == nil) {
                roles = @"";
            }
            self.roles = roles;
            
            
            NSString *usertoken = user.usertoken;
            if ([usertoken isMemberOfClass:[NSNull class]] || usertoken == nil) {
                usertoken = @"";
            }
            self.usertoken = usertoken;
            
            
            NSString *headurl = user.headurl;
            if ([headurl isMemberOfClass:[NSNull class]] || headurl == nil) {
                headurl = @"";
            }
            self.headurl = headurl;
            
            NSString *userID = user.userID;
            if ([userID isMemberOfClass:[NSNull class]] || userID == nil) {
                userID = @"";
            }
            self.userID = userID;
            
            
            
            self.birthday = user.birthday;
            
            self.schoolName = user.schoolName;
            
            self.relation = user.relation;
            
            self.className = user.className;
            
        }
        
    }
    return self;
}

@end
