CocoaHTTPServer is a small, lightweight, embeddable HTTP server for Mac OS X or iOS applications.

Sometimes developers need an embedded HTTP server in their app. Perhaps it's a server application with remote monitoring. Or perhaps it's a desktop application using HTTP for the communication backend. Or perhaps it's an iOS app providing over-the-air access to documents. Whatever your reason, CocoaHTTPServer can get the job done. It provides:

-   Built in support for bonjour broadcasting
-   IPv4 and IPv6 support
-   Asynchronous networking using GCD and standard sockets
-   Password protection support
-   SSL/TLS encryption support
-   Extremely FAST and memory efficient
-   Extremely scalable (built entirely upon GCD)
-   Heavily commented code
-   Very easily extensible
-   WebDAV is supported too!

<br/>
Can't find the answer to your question in any of the [wiki](https://github.com/robbiehanson/CocoaHTTPServer/wiki) articles? Try the **[mailing list](http://groups.google.com/group/cocoahttpserver)**.
<br/>
<br/>
Love the project? Wanna buy me a coffee? (or a beer :D) [![donation](http://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BHF2DJRETGV5S)


----------------------------------------------------------------------------------------
other demo: https://github.com/OPTJoker/CocoaHttpServer

swift framework: https://github.com/httpswift/swifter

https server: 
https://developer.apple.com/forums/thread/74152




！！！！！！！！！！！！！！！！配置和注意：！！！！！！！！！！！！！！！！
在HTTPConnection.m的335行开始，这里修改为YES， 之后才支持https

在GCDAsyncSocket.m文件的第7281行左右，注释掉如下代码：
if (value)
{
    NSAssert(NO, @"Security option unavailable - kCFStreamSSLLevel"
                 @" - You must use GCDAsyncSocketSSLProtocolVersionMin & GCDAsyncSocketSSLProtocolVersionMax");

    [self closeWithError:[self otherError:@"Security option unavailable - kCFStreamSSLLevel"]];
    return;
}

或者：
*不用cocoapod管理，因为’注释‘有可能各种原因被覆盖
*按照NSAssert内的提示：" - You must use GCDAsyncSocketSSLProtocolVersionMin & GCDAsyncSocketSSLProtocolVersionMax"
    参考：https://kmyhy.blog.csdn.net/article/details/51820658?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-1.opensearchhbase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-1.opensearchhbase
    原理：创建HTTPConnection的子类来设置GCDAsyncSocketSSLProtocolVersionMin  ...

