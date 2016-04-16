//
//  Movie.h
//  runtime
//
//  Created by qianjianeng on 16/4/11.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Item.h"
#import "HGUser.h"
//1. 如果想要当前类可以实现归档与反归档，需要遵守一个协议NSCoding
@interface Movie : NSObject<NSCoding, ModelDelegate>

@property (nonatomic, strong) HGUser * user;
@property (nonatomic, copy) NSString *movieId;
@property (nonatomic, copy) NSString *movieName;
@property (nonatomic, copy) NSString *pic_url;


@end
