//
//  AdvertisingViewController.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/18.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "AdvertisingViewController.h"

@interface AdvertisingViewController ()

@end

@implementation AdvertisingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
   
}
-(void)popView{
     [UMVideoAd videoCloseVideoPlayer];
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [UMVideoAd videoPlay:self videoPlayFinishCallBackBlock:^(BOOL isFinishPlay){
        if (isFinishPlay) {
            NSLog(@"视频播放结束");
            
        }else{
            NSLog(@"中途退出");
            [MobClick event:@"中途关闭广告"];
            [self performSelector:@selector(popView) withObject:nil afterDelay:0.5];
        }
        
    } videoPlayConfigCallBackBlock:^(BOOL isLegal){
        NSString *message = @"";
        if (isLegal) {
            message = @"此次播放有效";
            [MobClick event:@"有效播放广告"];
            [[AppUnitl sharedManager] addMyintegral:[AppUnitl sharedManager].model.video.ggintegral];
            //            NSString *string = [[NSString alloc]initWithFormat:@"获取%d积分,当前积分%d",[AppUnitl sharedManager].model.video.ggintegral,[[AppUnitl sharedManager] getMyintegral]];
            //            [self showSuccessText:string];
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [self dismissLoading];
            //            });
            [self performSelector:@selector(popView) withObject:nil afterDelay:0.5];
            
        }else{
            
            message = @"此次播放无效";
            //            [self showErrorText:message];
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [self dismissLoading];
            //            });
           [self performSelector:@selector(popView) withObject:nil afterDelay:0.5];
        }
        //                UIImage *image = [MobiVideoAd oWVideoImage];
        NSLog(@"是否有效：%@",message);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
