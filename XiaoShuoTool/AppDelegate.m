//
//  AppDelegate.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "AppDelegate.h"
#import "JACenterViewController.h"
#import "XiaoshuoViewController.h"
#import "ZFDownloadViewController.h"
#import "SearchViewController.h"
#import "AES128Util.h"
#import "YYModel.h"
#import "AppModel.h"
#import "AppUnitl.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UMVideoAd initAppID:@"452daca28d91e51a" appKey:@"300195c14eacd089" cacheVideo:YES];
    
    //开启非wifi预缓存视频文件
    [UMVideoAd videoDownloadOnUNWifi:YES];
    
    NSError *error = nil;
    NSURL *xcfURL = [NSURL URLWithString:@"http://opmams01o.bkt.clouddn.com/videoPlayer.json"];
    NSString *htmlString = [NSString stringWithContentsOfURL:xcfURL encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%@", htmlString);
    AppModel *model = [AppModel yy_modelWithJSON:htmlString];
    NSLog(@"%@", model);
    
    AppUnitl.sharedManager.model = model;
    
    NSString *plainText = @"https://www.youjizz.com/most-popular/";
    NSString *key = @"zftshishuaige";
    NSString *encryStr = [AES128Util AES128Encrypt:plainText key:key];
    NSLog(@"encryStr: %@", encryStr);
    NSString *decryStr = [AES128Util AES128Decrypt:encryStr key:key];
    NSLog(@"decryStr: %@", decryStr);
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
    SearchViewController *firstViewController = [[SearchViewController alloc] init];
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
    NSArray *titles = @[@"搜索", @"历史", @"更多"];
    NSArray *images = @[@"souye", @"sousuo", @"wod"];
    
    self.mainVC = [[UITabBarController alloc] init];
    
    self.mainVC.viewControllers = @[firstNavigationController, secondNavigationController, thirdNavigationController];
    
    [self.mainVC.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                              [images objectAtIndex:idx]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_unselected",
                                                                [images objectAtIndex:idx]]];
        [item setTitle:titles[idx]];
        [item setImage:[unselectedimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item setSelectedImage:[selectedimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
    }];
    
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont   systemFontOfSize:10]}   forState:UIControlStateNormal];
    
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];

    
    UITabBar *tabBar = self.mainVC.tabBar;
    //修改字体颜色
    tabBar.tintColor = [UIColor redColor];
    
    self.mainVC.tabBar.translucent = NO;
    
 
    
    self.window.rootViewController = self.mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
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



