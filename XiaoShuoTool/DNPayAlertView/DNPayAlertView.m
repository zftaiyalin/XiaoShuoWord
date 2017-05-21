//
//  DNPayAlertView.m
//  DNPayAlertDemo
//
//  Created by dawnnnnn on 15/12/9.
//  Copyright © 2015年 dawnnnnn. All rights reserved.
//

#import "DNPayAlertView.h"

#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kPAYMENT_WIDTH kSCREEN_WIDTH-80

static NSInteger const kPasswordCount = 6;

static CGFloat const kTitleHeight     = 46.f;
static CGFloat const kDotWidth        = 10;
static CGFloat const kKeyboardHeight  = 216;
static CGFloat const kAlertHeight     = 200;
static CGFloat const kCommonMargin    = 100;

@interface DNPayAlertView () <UITextFieldDelegate>{
    
    NSString *xinmima;

}

@property (nonatomic, strong) UIView *paymentAlert;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *line;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UITextField *pwdTextField;

@property (nonatomic, strong) UIWindow *showWindow;

@end

@interface DNPayAlertView ()

@property (nonatomic, strong) NSMutableArray <UILabel *> *pwdIndicators;

@end

@implementation DNPayAlertView

- (instancetype)init {
    self = [super init];
    if (self) {
        xinmima = @"";
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
        
        [self viewAddSubviews];
    }
    return self;
}

- (void)viewAddSubviews {
    [self.view addSubview:self.paymentAlert];
    [self.paymentAlert addSubview:self.titleLabel];
    [self.paymentAlert addSubview:self.closeBtn];
    [self.paymentAlert addSubview:self.line];
    [self.paymentAlert addSubview:self.detailLabel];
    [self.paymentAlert addSubview:self.amountLabel];
    [self.paymentAlert addSubview:self.inputView];
    [self.inputView addSubview:self.pwdTextField];
    
    CGFloat width = self.inputView.bounds.size.width/kPasswordCount;
    for (int i = 0; i < kPasswordCount; i ++) {
        UILabel *dot = [[UILabel alloc]initWithFrame:CGRectMake((width-kDotWidth)/2.f + i*width, (self.inputView.bounds.size.height-kDotWidth)/2.f, kDotWidth, kDotWidth)];
        dot.backgroundColor = [UIColor blackColor];
        dot.layer.cornerRadius = kDotWidth/2.;
        dot.clipsToBounds = YES;
        dot.hidden = YES;
        [self.inputView addSubview:dot];
        [self.pwdIndicators addObject:dot];
        if (i == kPasswordCount-1) {
            continue;
        }
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake((i+1)*width, 0, .5f, self.inputView.bounds.size.height)];
        line.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.];
        [self.inputView addSubview:line];
    }
}


- (void)show {
    UIWindow *newWindow = [[UIWindow alloc]initWithFrame:self.view.bounds];
    newWindow.rootViewController = self;
    [newWindow makeKeyAndVisible];
    self.showWindow = newWindow;
    
    self.paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    self.paymentAlert.alpha = 0;

    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_pwdTextField becomeFirstResponder];
        _paymentAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _paymentAlert.alpha = 1.0;
    } completion:nil];
}

- (void)dismiss {
    [self.pwdTextField resignFirstResponder];
    [UIView animateWithDuration:.7f animations:^{
        self.paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        self.paymentAlert.alpha = 0;
        self.showWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [self.showWindow removeFromSuperview];
        [self.showWindow resignKeyWindow];
        self.showWindow = nil;
    }];
}

#pragma mark - delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length >= kPasswordCount && string.length) {
        return NO;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }

    return YES;
}

#pragma mark - action

- (void)textDidChange:(UITextField *)textField {
    [self setDotWithCount:textField.text.length];
    if (textField.text.length == 6) {
        
        if (self.isTwo) {
            if (xinmima.length == 0) {
                xinmima = textField.text;
                self.amount = self.twoString;
                textField.text = @"";
                [self setDotWithCount:0];
            }else{
                if ([xinmima isEqualToString:textField.text]) {
                    if (self.completeHandle) {
                        self.completeHandle(textField.text);
                    }
                    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.1f];
                }else{
                    if (self.completeHandle) {
                        self.completeHandle(@"两次密码不一致");
                    }
                    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.1f];
                }
                
            }
        }else if(self.isThree){
            if ([AppUnitl getBOOLStringMiMa:textField.text]) {
                self.isTwo = YES;
                self.isThree = NO;
                
                self.amount = self.threeString;
                textField.text = @"";
                [self setDotWithCount:0];
            }else{
                if (self.completeHandle) {
                    self.completeHandle(@"密码输入错误");
                }
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:.1f];
            }
        }else{
            
            
            if ([AppUnitl getBOOLStringMiMa:textField.text]) {
                
                
                if (self.completeHandle) {
                    self.completeHandle(textField.text);
                }
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:.3f];
            }else{
            
                self.detail = @"密码错误";
                self.amount = @"请重新输入正确密码";
                textField.text = @"";
                [self setDotWithCount:0];
            }
            

        }
    }
}

- (void)setDotWithCount:(NSInteger)count {
    for (UILabel *dot in self.pwdIndicators) {
        dot.hidden = YES;
    }
    
    for (int i = 0; i< count; i++) {
        ((UILabel*)[self.pwdIndicators objectAtIndex:i]).hidden = NO;
    }
}


#pragma mark - setter

- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    self.titleLabel.text = _titleStr;
}

- (void)setDetail:(NSString *)detail {
    _detail = detail;
    self.detailLabel.text = _detail;
}

- (void)setAmount:(NSString *)amount {
    _amount = amount;
    self.amountLabel.text = [NSString stringWithFormat:@"%@",amount];
}

#pragma mark - getter

- (UIView *)paymentAlert {
    if (_paymentAlert == nil) {
        _paymentAlert = [[UIView alloc]initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height-kKeyboardHeight-kCommonMargin-kAlertHeight, [UIScreen mainScreen].bounds.size.width-80, kAlertHeight)];
        _paymentAlert.layer.cornerRadius = 5.f;
        _paymentAlert.layer.masksToBounds = YES;
        _paymentAlert.backgroundColor = [UIColor colorWithWhite:1. alpha:.95];
    }
    return _paymentAlert;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kPAYMENT_WIDTH, kTitleHeight)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (UIButton *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setFrame:CGRectMake(0, 0, kTitleHeight, kTitleHeight)];
        [_closeBtn setTitle:@"╳" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _closeBtn;
}

- (UILabel *)line {
    if (_line == nil) {
        _line = [[UILabel alloc]initWithFrame:CGRectMake(0, kTitleHeight, kPAYMENT_WIDTH, .5f)];
        _line.backgroundColor = [UIColor lightGrayColor];
    }
    return _line;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, kTitleHeight+15, kPAYMENT_WIDTH-30, 20)];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.textColor = [UIColor darkGrayColor];
        _detailLabel.font = [UIFont systemFontOfSize:16];
    }
    return _detailLabel;
}

- (UILabel *)amountLabel {
    if (_amountLabel == nil) {
        _amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, kTitleHeight*2, kPAYMENT_WIDTH-30, 25)];
        _amountLabel.textAlignment = NSTextAlignmentCenter;
        _amountLabel.textColor = [UIColor darkGrayColor];
        _amountLabel.font = [UIFont systemFontOfSize:25];
    }
    return _amountLabel;
}

- (UIView *)inputView {
    if (_inputView == nil) {
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(15, _paymentAlert.frame.size.height-(kPAYMENT_WIDTH-30)/6-15, kPAYMENT_WIDTH-30, (kPAYMENT_WIDTH-30)/6)];
        _inputView.backgroundColor = [UIColor whiteColor];
        _inputView.layer.borderWidth = 1.f;
        _inputView.layer.borderColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.].CGColor;
    }
    return _inputView;
}

- (UITextField *)pwdTextField {
    if (_pwdTextField == nil) {
        _pwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _pwdTextField.hidden = YES;
        _pwdTextField.delegate = self;
        _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_pwdTextField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _pwdTextField;
}

- (NSMutableArray *)pwdIndicators {
    if (_pwdIndicators == nil) {
        _pwdIndicators = [[NSMutableArray alloc]init];
    }
    return _pwdIndicators;
}

@end
