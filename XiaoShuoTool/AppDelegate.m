//
//  AppDelegate.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "AppDelegate.h"
#import "JACenterViewController.h"
#import "UIColor+YYAdd.h"
#import "XiaoshuoViewController.h"
#import "ZFDownloadViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UMVideoAd initAppID:@"452daca28d91e51a" appKey:@"300195c14eacd089" cacheVideo:YES];
    
    //开启非wifi预缓存视频文件
    [UMVideoAd videoDownloadOnUNWifi:YES];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
    //
    
    
    XiaoshuoViewController *firstViewController = [[XiaoshuoViewController alloc] init];
    firstViewController.hidesBottomBarWhenPushed = NO;
    UINavigationController *firstNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:firstViewController];
    
    JACenterViewController *secondViewController =  [[JACenterViewController alloc]init];
    secondViewController.hidesBottomBarWhenPushed = NO;
    UINavigationController *secondNavigationController = [[UINavigationController alloc]
                                                          initWithRootViewController:secondViewController];
    
    ZFDownloadViewController *thirdViewController =  [[ZFDownloadViewController alloc] init];
    thirdViewController.hidesBottomBarWhenPushed = NO;
    UINavigationController *thirdNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:thirdViewController];
    
    
    UIColor *unSelectedTabBarTitleTextColor = [UIColor colorWithRed:114.0/255.0 green:115.0/255.0 blue:116.0/255.0 alpha:1.0f];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:unSelectedTabBarTitleTextColor
                                                                                  ,NSForegroundColorAttributeName ,[UIFont systemFontOfSize:26], NSFontAttributeName, nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor]
                                                                                  ,NSForegroundColorAttributeName,[UIFont systemFontOfSize:26], NSFontAttributeName, nil]
                                             forState:UIControlStateSelected];
    NSArray *titles = @[@"首页", @"歌词", @"下载"];
    //    NSArray *images = @[@"news", @"msg", @"contacts", @"userCenter"];
    
    self.mainVC = [[UITabBarController alloc] init];
    
    self.mainVC.viewControllers = @[firstNavigationController, secondNavigationController, thirdNavigationController];
    
    [self.mainVC.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        //        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
        //                                                      [images objectAtIndex:idx]]];
        //        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_unselected",
        //                                                        [images objectAtIndex:idx]]];
        [item setTitle:titles[idx]];
        //        [item setImage:[unselectedimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        //        [item setSelectedImage:[selectedimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
    }];

    
    self.mainVC.tabBar.translucent = NO;
    
 
    
    self.window.rootViewController = self.mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];
    
    [navigationBarAppearance setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setShadowImage:[[UIImage alloc] init]];
    [navigationBarAppearance setBarTintColor:[UIColor whiteColor]];
    [navigationBarAppearance setTranslucent:NO];
    
    [navigationBarAppearance setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName, nil];
    
    [navigationBarAppearance setTitleTextAttributes:attributes];
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end



