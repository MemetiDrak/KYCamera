//
//  ViewController.m
//  KYCameraDemo
//
//  Created by KangYang on 16/1/30.
//  Copyright © 2016年 KangYang. All rights reserved.
//

#import "ViewController.h"
#import "KYCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];
}

- (void)tapGestureAction:(id)sender
{
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:[KYCameraViewController new]];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
