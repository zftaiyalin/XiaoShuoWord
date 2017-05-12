//
//  DaiLuViewController.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "DaiLuViewController.h"
#import "Masonry.h"
#import "AES128Util.h"
#import "NSObject+ALiHUD.h"

@interface DaiLuViewController ()

@property(nonatomic,strong) UIButton *wechatBtu;
@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UIButton *tijiaoBtu;
@property(nonatomic,strong) UILabel *jgLabel;
@end

@implementation DaiLuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"带路党";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    
    UMBannerView *bannerView = [UMVideoAd videoBannerPlayerFrame:CGRectMake(0, 64, self.view.frame.size.width, 50) videoBannerPlayCloseCallBackBlock:^(BOOL isLegal){
        NSLog(@"关闭banner");
        NSLog(@"close banner");
    }];
    
    [self.view addSubview:bannerView];
    
    _wechatBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    _wechatBtu.backgroundColor = [UIColor whiteColor];
    [_wechatBtu addTarget:self action:@selector(copyWechat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wechatBtu];
    
    [_wechatBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64+65);
        make.height.mas_equalTo(44);
    }];
    
    
    UILabel *label = [[UILabel alloc]init];
    label.text = [AppUnitl sharedManager].model.wetchat.url;
    label.textColor = [UIColor colorWithHexString:@"#FF6A6A"];
    [_wechatBtu addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       make.edges.equalTo(_wechatBtu).insets(UIEdgeInsetsMake(0, 13, 0, 13));
    }];
    
    
    UIView *textView = [[UIView alloc]init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(_wechatBtu.mas_bottom).offset(15);
        make.height.mas_equalTo(44);
    }];
    
    _textField = [[UITextField alloc]init];
    _textField.placeholder = @"老司机VIP码";
    [textView addSubview:_textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(textView).insets(UIEdgeInsetsMake(0, 13, 0, 13));
    }];
    
    _tijiaoBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    _tijiaoBtu.backgroundColor = [UIColor whiteColor];
    [_tijiaoBtu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_tijiaoBtu setTitle:@"提交" forState:UIControlStateNormal];
    [_tijiaoBtu addTarget:self action:@selector(tijiaolaosiji) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_tijiaoBtu];
    
    [_tijiaoBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(textView).offset(65);
        make.height.mas_equalTo(44);
    }];
    
    
    _jgLabel = [[UILabel alloc]init];
    _jgLabel.text = @"警告⚠️---千万不要删除客户端，不然VIP状态会丢失，如丢失，老司机概不负责!";
    _jgLabel.numberOfLines = 0;
    _jgLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    _jgLabel.hidden = YES;
    _jgLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_jgLabel];
    
    [_jgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(13);
        make.right.equalTo(self.view).offset(-13);
        make.top.equalTo(self.textField.mas_bottom).offset(6);
    }];
    
    if ([AppUnitl sharedManager].isVip) {
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
        [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSString *datesString = [[NSUserDefaults standardUserDefaults] objectForKey:@"date"];
        _textField.text = [[NSString alloc]initWithFormat:@"VIP到期时间: %@",datesString];
        _textField.userInteractionEnabled = NO;
        _tijiaoBtu.hidden = YES;
        _jgLabel.hidden = NO;
    }else{
        _textField.userInteractionEnabled = YES;
        _tijiaoBtu.hidden = NO;
        _jgLabel.hidden = YES;
    }
}

-(void)tijiaolaosiji{
    NSString *decryStr = [AES128Util AES128Decrypt:_textField.text key:[AppUnitl sharedManager].model.video.key];
    NSLog(@"decryStr: %@", decryStr);
    
    if ([decryStr rangeOfString:@"create"].length > 0) {
        
        
        NSArray *dateArray = [decryStr componentsSeparatedByString:@"create"];
        
        NSString *dateNow= dateArray.firstObject;
        NSString *dqDate = dateArray.lastObject;
        
        
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
        [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        
        
        if ([AppUnitl dateTimeDifferenceWithStartTime:dateNow endTime:[formatter1 stringFromDate:[NSDate date]]]) {
                      
            
            NSDate *resDate = [formatter1 dateFromString:dqDate];
            NSLog(@"%@",resDate);
            
            _textField.text = [[NSString alloc]initWithFormat:@"VIP到期时间: %@",dqDate];
            NSLog(@"\n b: %@",dateArray);
            
            _textField.userInteractionEnabled = NO;
            _tijiaoBtu.hidden = YES;
            _jgLabel.hidden = NO;
            
            [[NSUserDefaults standardUserDefaults] setObject:dqDate forKey:@"date"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [AppUnitl sharedManager].isVip = YES;
            
        }else{
            
            [self showErrorText:@"验证码已过期"];
        
        }
        
  
        
    }else{
        
        [self showErrorText:@"错误的验证码"];
    }
    
}

-(void)copyWechat{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [AppUnitl sharedManager].model.wetchat.url;

    UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"提示"message:@"已复制老司机微信号，是否前往寻找老司机？" delegate:self   cancelButtonTitle:@"待会儿" otherButtonTitles:@"前往",nil];
    [infoAlert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *str = @"weixin:/";
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
