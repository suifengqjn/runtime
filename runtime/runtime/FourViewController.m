//
//  FourViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/15.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FourViewController.h"
#import "Person.h"
#import "Tool.h"
#import <objc/runtime.h>
@interface FourViewController ()

@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) Tool *tool;
@property (weak, nonatomic) IBOutlet UITextField *uitextview;

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //这里也可以使用 [self.person class],不过要先初始化
    Method m1 = class_getInstanceMethod([Person class], @selector(sayName));
    Method m2 = class_getInstanceMethod([Tool class], @selector(changeMethod));
    
    method_exchangeImplementations(m1, m2);
}
- (IBAction)button:(id)sender {
    
    self.person = [Person new];
    self.uitextview.text = [_person sayName];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
