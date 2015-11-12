//
//  webViewController.h
//  Google Maps SDK
//
//  Created by Chris on 8/17/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface webViewController : UIViewController
@property (nonatomic, retain) WKWebView *webView;
@property (nonatomic, retain) NSURL *url;

@end
