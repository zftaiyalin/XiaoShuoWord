//
//  AppDelegate.h
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *mainVC;
@property (strong, nonatomic) JASidePanelController *viewController;

@end

