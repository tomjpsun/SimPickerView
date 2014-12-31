//
//  ViewController.m
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDelete:(id)sender
{
    NSIndexPath *sel = [self.simPickerView getSelectedIndexPath];
    [self.simPickerView deleteItemAtIndexPath: sel];
}


- (IBAction)onAdd:(id)sender
{
    NSIndexPath *sel = [self.simPickerView getSelectedIndexPath];
    [self.simPickerView appendItem: @"Ipsum Loram" afterIndexPath: sel];
}

@end