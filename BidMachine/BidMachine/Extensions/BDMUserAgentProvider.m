//
//  BDMUserAgentProvider.m
//  BidMachine
//
//  Created by Stas Kochkin on 20/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMUserAgentProvider.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#include <mach/mach.h>
#include <ifaddrs.h>
#include <arpa/inet.h>


@implementation BDMUserAgentProvider

+ (NSString *)userAgent {
    static NSString * kBDMStaticUserAgent;
    if (!kBDMStaticUserAgent) {
        NSString *template = @"Mozilla/5.0 (deviceName; CPU osName osVersion like Mac OS X) AppleWebKit/webKitVersion (KHTML, like Gecko) Mobile/firmware appName/appVersion";
        
        // device name, iPad or iPhone
        if ([template rangeOfString:@"deviceName"].location != NSNotFound) {
            NSString *deviceName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? @"iPad" : @"iPhone";
            template = [template stringByReplacingOccurrencesOfString:@"deviceName" withString:deviceName];
        }
        
        // os name, OS or iPhone OS
        if ([template rangeOfString:@"osName"].location != NSNotFound) {
            NSString *osName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? @"OS" : @"iPhone OS";
            template = [template stringByReplacingOccurrencesOfString:@"osName" withString:osName];
        }
        
        // os version, e.g. 10_3_2
        if ([template rangeOfString:@"osVersion"].location != NSNotFound) {
            NSString *osVersion = [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            if (osVersion.length > 0) {
                template = [template stringByReplacingOccurrencesOfString:@"osVersion" withString:osVersion];
            }
        }
        
        // webkit version, e.g. 603.1.30
        if ([template rangeOfString:@"webKitVersion"].location != NSNotFound) {
            NSBundle *webKitBundle = [NSBundle bundleForClass:NSClassFromString(@"WKWebView")]; // the one WebKit.framework has
            NSString *fullWebKitVersion = [webKitBundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]; // like 8603.1.30.1.33
            
            // If the version is longer than 3 digits then the leading digits represent the version of the OS. Our user agent
            // string should not include the leading digits, so strip them off and report the rest as the version. <rdar://problem/4997547>
            NSRange nonDigitRange = [fullWebKitVersion rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
            if (nonDigitRange.location == NSNotFound && fullWebKitVersion.length > 3)
            fullWebKitVersion = [fullWebKitVersion substringFromIndex:fullWebKitVersion.length - 3];
            if (nonDigitRange.location != NSNotFound && nonDigitRange.location > 3)
            fullWebKitVersion = [fullWebKitVersion substringFromIndex:nonDigitRange.location - 3];
            
            // We include at most three components of the bundle version in the user agent string.
            NSString *bundleVersion = fullWebKitVersion;
            NSScanner *scanner = [NSScanner scannerWithString:bundleVersion];
            NSInteger periodCount = 0;
            while (true) {
                if (![scanner scanUpToString:@"." intoString:NULL] || scanner.isAtEnd) {
                    break;
                }
                if (++periodCount == 3) {
                    bundleVersion = [bundleVersion substringToIndex:scanner.scanLocation];
                    break;
                }
                ++scanner.scanLocation;
            }
            
            if (bundleVersion.length > 0) {
                template = [template stringByReplacingOccurrencesOfString:@"webKitVersion" withString:bundleVersion];
            }
        }
        
        // firmware, e.g. 14E8301, see https://ipsw.me/ (btw the only way to differ betas)
        if ([template rangeOfString:@"firmware"].location != NSNotFound) {
            NSString *firmware = nil;
            int mib[2] = {CTL_KERN, KERN_OSVERSION};
            u_int namelen = sizeof(mib) / sizeof(mib[0]);
            size_t bufferSize = 0;
            sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
            char *buffer = malloc(bufferSize);
            int result = sysctl(mib, namelen, buffer, &bufferSize, NULL, 0);
            if (result == 0) {
                firmware = [[NSString alloc] initWithCString:buffer encoding:NSUTF8StringEncoding];
            }
            free(buffer);
            if (firmware.length > 0) {
                template = [template stringByReplacingOccurrencesOfString:@"firmware" withString:firmware];
            }
        }
        
        // app name
        if ([template rangeOfString:@"appName"].location != NSNotFound) {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
            if (appName.length > 0) {
                template = [template stringByReplacingOccurrencesOfString:@"appName" withString:appName];
            }
        }
        
        // app version
        if ([template rangeOfString:@"appVersion"].location != NSNotFound) {
            NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
            if (appVersion.length > 0) {
                template = [template stringByReplacingOccurrencesOfString:@"appVersion" withString:appVersion];
            }
        }
        kBDMStaticUserAgent = template;
    }
    return kBDMStaticUserAgent;
}

@end
