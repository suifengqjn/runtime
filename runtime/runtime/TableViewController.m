//
//  TableViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/12.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "TableViewController.h"
#import "oneViewController.h"
#import "twoViewController.h"
#import "threeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"
#import "SevenViewController.h"
@interface TableViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"runtime";
    //1. 动态变量控制
    //2.动态添加方法
    //3：动态交换两个方法的实现
    //4.拦截并替换方法
    //5：在方法上增加额外功能
    //6.实现NSCoding的自动归档和解档
    //7.实现字典转模型的自动转换
    _dataSource = @[@"动态变量控制",
                    @"动态添加方法",
                    @"动态交换两个方法的实现",
                    @"拦截并替换方法",
                    @"在方法上增加额外功能",
                    @"实现NSCoding的自动归档和解档",
                    @"实现字典转模型的自动转换"
                    ];

    self.tableView.tableFooterView = [UIView new];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellIdentifier";

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //2. 判断是否有可重用的，如果没有，则自己创建
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    
    cell.textLabel.text = _dataSource[indexPath.row];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.获取storyBoard（Main固定，是sb的名字）
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    
    NSInteger index = indexPath.row;
    switch (index) {
        case 0:{
            
             //2.从storyBoard中获取控制器
            oneViewController *oneVC = (oneViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"onevciden"];
            //3.推出
            [self.navigationController pushViewController:oneVC animated:YES];
            break;
        }
        case 1:{

            twoViewController *twoVC = (twoViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"twovciden"];
            [self.navigationController pushViewController:twoVC animated:YES];
            
            break;
        }
        case 2:{
            
            twoViewController *threeVC = (twoViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"threevciden"];
            [self.navigationController pushViewController:threeVC animated:YES];
            
            break;
        }
        case 3:{
            
            FourViewController *threeVC = (FourViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"fourvciden"];
            [self.navigationController pushViewController:threeVC animated:YES];
            
            break;
        }
        case 4:{
            FiveViewController *fiveVC = [FiveViewController new];
            [self.navigationController pushViewController:fiveVC animated:YES];
            
            break;
        }
        case 5:{
            SixViewController *fiveVC = [SixViewController new];
            [self.navigationController pushViewController:fiveVC animated:YES];
            break;
        }
        case 6:{
            
            SevenViewController *fiveVC = [SevenViewController new];
            [self.navigationController pushViewController:fiveVC animated:YES];
            break;
        }

            
        default:
            break;
    }
}

@end
