//
//  YYRedPacketOpenedModel.m
//  FBG
//
//  Created by yy on 2018/5/1.
//  Copyright © 2018年 ButtonRoot. All rights reserved.
//

#import "YYRedPacketOpenedModel.h"

@implementation YYRedPacketOpenedModel

MJCodingImplementation
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"modelId" : @"id"
             };
}

@end