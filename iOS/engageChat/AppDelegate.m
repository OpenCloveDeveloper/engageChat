
/*
 *
 * Package Name		: engageChat
 * File Name		: AppDelegate.m
 * Version Name		: 1.1.0
 * Date    			: 20140412
 * Description		: Copyright (c) 2012 OpenClove. All rights reserved.
 *
 *
 */

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    if (backgroundAccepted)
    {
        NSLog(@"VOIP backgrounding accepted");
        
    }
}

- (void)backgroundHandler {
    
    NSLog(@"### -->VOIP backgrounding callback"); // What to do here to extend timeout?
    
    [self.viewController reconnectOPX];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSArray* cfBundleURLSchemes;
    NSString* uscheme = @"";
    NSArray* cfBundleURLTypes = [mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if ([cfBundleURLTypes isKindOfClass:[NSArray class]] && [cfBundleURLTypes lastObject]) {
        NSDictionary* cfBundleURLTypes0 = [cfBundleURLTypes objectAtIndex:0];
        if ([cfBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
            cfBundleURLSchemes = [cfBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
            uscheme = [cfBundleURLSchemes objectAtIndex:0];
        }
    }
    
    if(![[url scheme] isEqualToString:@"http"]&&![[url scheme] isEqualToString:@"https"]&&![[url scheme] isEqualToString:uscheme])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [self.viewController handlePluginCall:[url query]];
    });
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    if(![[url scheme] isEqualToString:@"http"]&&![[url scheme] isEqualToString:@"https"]&&![[url scheme] isEqualToString:@"ovx"])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    
     dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [self.viewController handlePluginCall:[url query]];
    });
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
{
    NSLog(@"DID RECEIVE NOTIFICATION");
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"DID LOCAL NOTIFICATION");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [self.viewController cancelTimerAndAccept];
}

@end
