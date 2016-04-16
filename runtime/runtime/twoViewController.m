//
//  twoViewController.m
//  runtime
//
//  Created by qianjianeng on 16/4/13.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "twoViewController.h"
#import "Person.h"
#import <objc/runtime.h>

@interface twoViewController ()

@property (nonatomic, strong) Person *person;
@property (weak, nonatomic) IBOutlet UITextField *textview;

@end

@implementation twoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [Person new];
    
}

- (void)sayFrom
{
    
    class_addMethod([self.person class], @selector(guess), (IMP)guessAnswer, "v@:");
    if ([self.person respondsToSelector:@selector(guess)]) {
        //Method method = class_getInstanceMethod([self.xiaoMing class], @selector(guess));
        [self.person performSelector:@selector(guess)];
        
    } else{
        NSLog(@"Sorry,I don't know");
    }
    self.textview.text = @"beijing";
}

void guessAnswer(id self,SEL _cmd){
    
    NSLog(@"i am from beijing");
    
}
- (IBAction)answer:(id)sender {
    
    [self sayFrom];
}



@end
