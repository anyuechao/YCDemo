//
//  ViewController.m
//  YCDemo
//
//  Created by DJnet on 2017/3/21.
//  Copyright © 2017年 YueChao An. All rights reserved.
//

#import "ViewController.h"
//#import "Text.cpp"
#

@interface ViewController ()
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ///asa 
    
    //1
    //2
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        for (int i = 0; i < 200; i ++) {
            for (int j = 0; j < 200; j ++) {
                NSLog(@"i=%d,j=%d",i,j);
            }
        }NSLog(@"==================================================================================================================================================================================================================================================================================================================================================================================================================================================================");
    }];
    [timer fire];
    _timer = timer;
      
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
