//
//  HttpsServerController.m
//  Lighting
//
//  Created by imvt on 2021/12/3.
//

#import "HttpWebController.h"
#import "HTTPServer.h"
#import <WebKit/WebKit.h>
#import "HttpsServerManager.h"

@interface HttpWebController () <WKNavigationDelegate>

@property(nonatomic, strong)WKWebView *webView;
@property(nonatomic, copy)NSString *urlStr;
@property(nonatomic, assign)BOOL loadHttpSuc;

@end

@implementation HttpWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[HttpsServerManager shareInstance] startServer];
    
//    [self loadLocalHttpServer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showNaviViewBackButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[HttpsServerManager shareInstance]stopServer];
}

#pragma mark - < <#expression#> >
- (BOOL)loadLocalHttpServer{
    NSString *port = [HttpsServerManager shareInstance].port;
    if (nil == port) {
        NSLog(@">>> Error:端口不存在");
        return NO;
    }
    NSString *str = [NSString stringWithFormat:@"https://localhost:%@", port];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.webView loadRequest:request];

    return YES;
}

#pragma mark - < webview >
- (WKWebView *)webView{
    if (nil == _webView) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        //初始化偏好设置属性：preferences
        config.preferences = [WKPreferences new];
        //The minimum font size in points default is 0;
        config.preferences.minimumFontSize = 10;
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) configuration:config];
        _webView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_webView];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"Did Finish Load");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"Did Fail Load With Error:\n%@",error);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    //解决：证书不信任问题
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions (serverTrust);
    SecTrustSetExceptions (serverTrust, exceptions);
    CFRelease (exceptions);
    completionHandler (NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
}

@end
