//
//  ViewController.m
//  webtest1
//
//  Created by sean on 2016/1/21.
//  Copyright © 2016年 sean. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ViewController () {
    NSTimer *dateTimer;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Init bridge.
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
    }];
    
    [self loadExamplePage:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Get locale Languages.
    NSString *currentLanguageJsonString = [self getLocaleLanguages];
    [_bridge callHandler:@"LanguagesHandler" data:@{ @"Languages":currentLanguageJsonString }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    
    // Register getDate handler
    [_bridge registerHandler:@"getDate" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self startDateTimer];
    }];
}

#pragma mark - Method

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (NSString *)getLocaleLanguages {
    NSString *currentLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    NSDictionary *dict = @{@"locale":currentLanguage};
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark - Timer and Counter

- (void)startDateTimer {
    [self stopDateTimer];
    dateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDateTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dateTimer forMode:NSDefaultRunLoopMode];
}

- (void)checkDateTimer:(NSTimer *)timer {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    [formatter setDateFormat:@"YYYY-MM-dd HH:MM:ss"];
    NSString *time = [formatter stringFromDate:date];
    [_bridge callHandler:@"timeHandler" data:@{@"time":time}];
}

- (void)stopDateTimer {
    [dateTimer invalidate];
    dateTimer = nil;
}

@end
