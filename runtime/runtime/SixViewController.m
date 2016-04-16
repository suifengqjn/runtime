//
//  SixViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/15.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "SixViewController.h"
#import "Movie.h"
@interface SixViewController ()
@property (nonatomic, retain) NSMutableArray *allDataArray;
@end

@implementation SixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
     self.allDataArray = [NSMutableArray array];
    
    NSDictionary *user = @{ @"name":@"zhangsan",
                            @"age": @(12),
                            @"sex": @"man",
                            };
    
    NSDictionary *dict = @{ @"movieId":@"28678",
                            @"movieName": @"539fU8276",
                            @"pic_url": @"fsdfds",
                            @"user" : user
                            };
    
    
    NSArray *addarr = @[dict ,dict, dict];
    
    NSMutableDictionary *mudict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    
    [mudict setObject:user forKey:@"user"];
    
    for (NSDictionary *item in addarr) {
        
        
        //这种事系统自带的方式
//        Movie *movie = [Movie new];
//        [movie setValuesForKeysWithDictionary:item];
//        [self.allDataArray addObject:movie];
        
        Movie *movie = [Movie objectWithDict:item];
         [self.allDataArray addObject:movie];
        
    }
    
    
    NSLog(@"----%@", _allDataArray);
    
    
}



@end
