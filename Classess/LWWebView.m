//
//  LWWebView.m
//  Example
//
//  Created by weil on 2018/12/7.
//  Copyright © 2018 allyoga. All rights reserved.
//

#import "LWWebView.h"

@interface LWWebView ()<WKNavigationDelegate>
@property (nonatomic,strong,readwrite) WKWebView *webView;
@property (nonatomic,strong,readwrite) WKWebViewJavascriptBridge *bridge;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,copy) NSString *appLink;
@property (nonatomic,copy) NSString *URLScheme;
@end

@implementation LWWebView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_initSubviews];
        [self p_configBridge];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initSubviews];
        [self p_configBridge];
    }
    return self;
}

- (void)p_initSubviews {
    WKWebViewConfiguration *configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    WKPreferences *prefer = [[WKPreferences alloc] init];
    prefer.javaScriptEnabled = YES;
    prefer.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = prefer;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//添加属性观察者
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self addSubview:self.webView];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.alpha = 1.0;
    [self.progressView setProgress:0.1 animated:NO];
    [self addSubview:self.progressView];
}

- (void)lw_setupProgressTrackColor:(UIColor *)color {
    self.progressView.tintColor = color;
}
- (void)lw_setupProgressBackColor:(UIColor *)backColor {
    self.progressView.backgroundColor = backColor;
}
- (void)lw_setupAppLink:(NSString *)appLink {
    self.appLink = appLink;
}
- (void)lw_setupURLScheme:(NSString *)urlScheme {
    self.URLScheme = urlScheme;
}

- (void)p_configBridge {
    [WKWebViewJavascriptBridge enableLogging];
    __weak typeof(self.webView) webView = self.webView;
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    [self.bridge setWebViewDelegate:self];
}

- (void)lw_loadWebViewWithURL:(NSURL *)URL {
     [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}
- (void)lw_loadWebViewWithHTML:(NSString *)html baseURL:(nonnull NSURL *)baseURL{
    [self.webView loadHTMLString:html baseURL:baseURL];
}
- (void)lw_loadWebViewWithFileURL:(NSURL *)fileURL allowingURL:(NSURL *)allowingURL {
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:allowingURL];
}
- (void)lw_reloadWebView {
    [self.webView reload];
}
- (void)lw_reloadWebViewFromOrigin {
    [self.webView reloadFromOrigin];
}

- (void)lw_addRegisterHandler:(NSString *)handlerName handler:(void (^)(id _Nonnull value, WVJBResponseCallback _Nonnull responseCallback))handler {
    [self.bridge registerHandler:handlerName handler:handler];
}
- (void)lw_addCallHandler:(NSString *)handlerName params:(id)params responseCallback:(void (^)(id _Nonnull))responseCallback {
    [self.bridge callHandler:handlerName data:params responseCallback:responseCallback];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webView) {
            CGFloat progress = self.webView.estimatedProgress;
            if (progress >= 0.9) {
                progress = 0.9;
            }
            if (progress < 0.1) {
                progress = 0.1;
            }
            [self.progressView setProgress:progress animated:YES];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        NSString *title = change[NSKeyValueChangeNewKey];
        if (self.fetchWebTitleFromWebView) {
            self.fetchWebTitleFromWebView(title);
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.progressView.alpha = 0.0;
    if (self.loadSuccess) {
        self.loadSuccess();
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.alpha = 0.0;
    if (self.loadFailure) {
        self.loadFailure(error);
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString isEqualToString:self.appLink]) {
        if (self.jumpToAppStore) {
            self.jumpToAppStore();
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }else if([[navigationAction.request.URL scheme] isEqualToString:self.URLScheme]) {
        if (self.fetchWebViewHandlerWithClick) {
            self.fetchWebViewHandlerWithClick(navigationAction.request.URL);
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.webView.frame = self.bounds;
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, 5);
}
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}
@end
