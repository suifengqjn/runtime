//
//  Movie.m
//  runtime
//
//  Created by qianjianeng on 16/4/11.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "Movie.h"
#import <objc/runtime.h>


@implementation Movie

- (void)encodeWithCoder:(NSCoder *)encoder

{
    unsigned int count = 0;
    
    Ivar *ivars = class_copyIvarList([Movie class], &count);
    
    for (int i = 0; i<count; i++) {
        // 取出i位置对应的成员变量
        Ivar ivar = ivars[i];
        // 查看成员变量
        
        const char *name = ivar_getName(ivar);
        // 归档
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [encoder encodeObject:value forKey:key];
        
    }
    
    free(ivars);
    
    
}

- (id)initWithCoder:(NSCoder *)decoder

{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([Movie class], &count);
        for (int i = 0; i<count; i++) {
            // 取出i位置对应的成员变量
            Ivar ivar = ivars[i];
            // 查看成员变量
            const char *name = ivar_getName(ivar);
            // 归档
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [decoder decodeObjectForKey:key];
            // 设置到成员变量身上
            [self setValue:value forKey:key];
            
        }
        free(ivars);
        
    }
    
    return self;
    
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@--%@--%@--%@", _movieName, _movieId, _pic_url, _user];
}


//如果用系统的方法字典转模型，一定要实现这个方法
//- (void)setValue:(id)value forUndefinedKey:(NSString *)key
//{
//    
//}
@end
