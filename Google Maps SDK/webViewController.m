//
//  webViewController.m
//  Google Maps SDK
//
//  Created by Chris on 8/17/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import "webViewController.h"
#import <WebKit/WebKit.h>

@interface webViewController ()
{
    NSURLRequest* urlReq;
}

@end

@implementation webViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    WKWebViewConfiguration *theConfiguration =[[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
    urlReq = [[NSURLRequest alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Unhide the navbar so that user can navigate back to mapView
    self.navigationController.navigationBarHidden = NO;
    
    urlReq = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:urlReq];
    self.view = self.webView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
