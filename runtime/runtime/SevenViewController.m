//
//  SevenViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/15.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "SevenViewController.h"
#import "Movie.h"
@interface SevenViewController ()

@end

@implementation SevenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Movie *m = [Movie new];
    m.movieName = @"aaaaaaaa";
    m.movieId = @"1222331";
    m.pic_url = @"llllllllll";
    
    NSString *document  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [document stringByAppendingString:@"/123.txt"];
    
    //模型写入文件
    [NSKeyedArchiver archiveRootObject:m toFile:filePath];
    
    
   //读取
    Movie *movie =  [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    NSLog(@"----%@",movie);
    
   
}



@end
