//
//  threeViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/13.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "threeViewController.h"
#import "Person.h"
#import <objc/runtime.h>
@interface threeViewController ()

@property (nonatomic, strong) Person *person;
@property (weak, nonatomic) IBOutlet UITextField *textview;

@end

@implementation threeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [Person new];
    
    NSLog(@"%@",_person.sayName);
    
    NSLog(@"%@",_person.saySex);
    
    Method m1 = class_getInstanceMethod([self.person class], @selector(sayName));
    Method m2 = class_getInstanceMethod([self.person class], @selector(saySex));
    
    method_exchangeImplementations(m1, m2);
}

- (IBAction)sayName:(id)sender {
    
    self.textview.text = [_person sayName];
    
}
- (IBAction)saySex:(id)sender {
    self.textview.text = [_person saySex];;
}

@end
