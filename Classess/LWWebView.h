//
//  LWWebView.h
//  Example
//
//  Created by weil on 2018/12/7.
//  Copyright © 2018 allyoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WKWebViewJavascriptBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWWebView : WKWebView
@property (nonatomic,strong,readonly) WKWebViewJavascriptBridge *bridge;
@property (nonatomic,copy) void(^fetchWebTitleFromWebView)(NSString *title);
@property (nonatomic,copy) void(^jumpToAppStore)(void);
@property (nonatomic,copy) void(^fetchWebViewHandlerWithClick)(NSURL *url);
@property (nonatomic,copy) void(^loadSuccess)(void);
@property (nonatomic,copy) void(^loadFailure)(NSError *error);
@property (nonatomic,copy) void(^loadNewURL)(NSString *url);

- (void)lw_setupURLScheme:(NSString *)urlScheme;
- (void)lw_setupAppLink:(NSString *)appLink;
- (void)lw_loadWebViewWithURL:(NSURL *)URL;
- (void)lw_loadWebViewWithHTML:(NSString *)html baseURL:(NSURL *)baseURL;
- (void)lw_loadWebViewWithFileURL:(NSURL *)fileURL allowingURL:(NSURL *)allowingURL;
- (void)lw_reloadWebView;
- (void)lw_reloadWebViewFromOrigin;
- (void)lw_setupProgressTrackColor:(UIColor *)color;
- (void)lw_setupProgressBackColor:(UIColor *)backColor;
- (void)lw_addRegisterHandler:(NSString *)handlerName handler:(void(^)(id value,WVJBResponseCallback responseCallback))handler;
- (void)lw_addCallHandler:(NSString *)handlerName params:(id)params responseCallback:(void(^)(id responseData))responseCallback;
@end

NS_ASSUME_NONNULL_END
