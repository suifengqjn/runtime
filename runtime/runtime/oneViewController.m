//
//  oneViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/13.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "oneViewController.h"
#import "Person.h"
#import <objc/runtime.h>
@interface oneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (nonatomic, strong) Person *person;
@end

@implementation oneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person = [Person new];
    _person.name = @"xiaoming";
    NSLog(@"XiaoMing first answer is %@",self.person.name);
    
}


- (void)sayName
{
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList([self.person class], &count);
    for (int i = 0; i<count; i++) {
        Ivar var = ivar[i];
        const char *varName = ivar_getName(var);
        NSString *proname = [NSString stringWithUTF8String:varName];
        
        if ([proname isEqualToString:@"_name"]) {   //这里别忘了给属性加下划线
            object_setIvar(self.person, var, @"daming");
            break;
        }
    }
    NSLog(@"XiaoMing change name  is %@",self.person.name);
    self.textfield.text = self.self.person.name;
}

- (IBAction)changename:(id)sender {
    [self sayName];
}

@end
