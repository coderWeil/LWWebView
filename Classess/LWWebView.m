//
//  LWWebView.m
//  Example
//
//  Created by weil on 2018/12/7.
//  Copyright © 2018 allyoga. All rights reserved.
//

#import "LWWebView.h"

@interface LWWebView ()<WKNavigationDelegate>
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
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        [self p_initSubviews];
        [self p_configBridge];
    }
    return self;
}
- (void)p_initSubviews {
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.alpha = 1.0;
    [self.progressView setProgress:0.1 animated:NO];
    [self addSubview:self.progressView];
    self.scrollView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)lw_setupProgressTrackColor:(UIColor *)color {
    self.progressView.progressTintColor = color;
}
- (void)lw_setupProgressBackColor:(UIColor *)backColor {
    self.progressView.trackTintColor = backColor;
}
- (void)lw_setupAppLink:(NSString *)appLink {
    self.appLink = appLink;
}
- (void)lw_setupURLScheme:(NSString *)urlScheme {
    self.URLScheme = urlScheme;
}

- (void)p_configBridge {
    [WKWebViewJavascriptBridge enableLogging];
    __weak typeof(self) wsf = self;
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:wsf];
    [self.bridge setWebViewDelegate:self];
}

- (void)lw_loadWebViewWithURL:(NSURL *)URL {
     [self loadRequest:[NSURLRequest requestWithURL:URL]];
}
- (void)lw_loadWebViewWithHTML:(NSString *)html baseURL:(nonnull NSURL *)baseURL{
    [self loadHTMLString:html baseURL:baseURL];
}
- (void)lw_loadWebViewWithFileURL:(NSURL *)fileURL allowingURL:(NSURL *)allowingURL {
    if (@available(iOS 9.0, *)) {
        [self loadFileURL:fileURL allowingReadAccessToURL:allowingURL];
    }else {
        [self loadRequest:[NSURLRequest requestWithURL:fileURL]];
    }
}
- (void)lw_reloadWebView {
    self.scrollView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self reload];
}
- (void)lw_reloadWebViewFromOrigin {
    self.scrollView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self reloadFromOrigin];
}

- (void)lw_addRegisterHandler:(NSString *)handlerName handler:(void (^)(id _Nonnull value, WVJBResponseCallback _Nonnull responseCallback))handler {
    [self.bridge registerHandler:handlerName handler:handler];
}
- (void)lw_addCallHandler:(NSString *)handlerName params:(id)params responseCallback:(void (^)(id _Nonnull))responseCallback {
    [self.bridge callHandler:handlerName data:params responseCallback:responseCallback];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self) {
            CGFloat progress = self.estimatedProgress;
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
    }else if ([keyPath isEqualToString:@"URL"]) {
        if (self.loadNewURL) {
            self.loadNewURL(self.URL.absoluteString);
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.progressView.alpha = 0.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if (self.loadSuccess) {
        self.loadSuccess();
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.alpha = 0.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, 5);
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"estimatedProgress"];
    [self removeObserver:self forKeyPath:@"title"];
     [self removeObserver:self forKeyPath:@"URL"];
}
@end
