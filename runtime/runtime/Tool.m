//
//  Tool.m
//  runtime
//
//  Created by qianjianeng on 16/4/16.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "Tool.h"

@interface Tool ()

@property (nonatomic, assign) NSInteger count;

@end


@implementation Tool

+ (instancetype)sharedManager {
    static Tool *_sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sInstance = [[Tool alloc] init];
    });
    
    return _sInstance;
}

- (NSString *)changeMethod
{
    return @"haha,你的方法被我替换掉了";
}


- (void)addCount
{
    _count += 1;
    
    NSLog(@"点击次数------%ld", _count);
}
@end
