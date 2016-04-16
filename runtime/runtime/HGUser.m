//
//  HGUser.m
//  runtime
//
//  Created by qianjianeng on 16/4/12.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "HGUser.h"

@implementation HGUser

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@--%@--%@--", _name, _age, _sex];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.uid = value;
    }
}
@end
