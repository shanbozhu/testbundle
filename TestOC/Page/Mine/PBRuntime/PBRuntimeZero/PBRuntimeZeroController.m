//
//  PBRuntimeZeroController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeZeroController.h"


@interface PBRuntimeZeroController ()

@end

/**
 假设此类中的代码不可修改
 */
@implementation PBRuntimeZeroController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PBRuntimeZeroController func];
}

+ (void)func {
    NSLog(@"被执行了2");
}

@end
