//
//  MContainerViewController.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MContainerViewController.h"

@interface MContainerViewController ()

@end

@implementation MContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [self.view setBackgroundColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
                [self.view setBackgroundColor: [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:45.0/255.0 alpha:1.0]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (self.isViewLoaded && self.view.window) //on screen
    {
    }
    else //not on screen.
    {
    }
}

@end
