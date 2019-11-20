//
//  ViewController.m
//  ReactiveObjCStudy
//
//  Created by Gabrielx on 2019/11/19.
//  Copyright © 2019 Gabriel Fire Panda. All rights reserved.
//

// 屏幕宽高
#define kScreenHeight                       [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth                        [[UIScreen mainScreen] bounds].size.width

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
@interface ViewController ()
@property(nonatomic,strong) UITextField *usernameTF;
@property(nonatomic,strong) UITextField *passwordTF;
@property(nonatomic,strong) UIButton *loginButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.usernameTF];
    [self.view addSubview:self.passwordTF];
    [self.view addSubview:self.loginButton];
}

- (UITextField *)usernameTF{
    if (!_usernameTF) {
        _usernameTF = [[UITextField alloc]init];
        _usernameTF.placeholder = @"请输入用户名称";
        _usernameTF.backgroundColor = [UIColor orangeColor];
        CGFloat x,y,w,h;
        
        h = 30;
        x = 20;
        w = kScreenWidth-2*x;
        y = (kScreenHeight-h)/2.0f;
        _usernameTF.frame = (CGRect){x,y,w,h};
        
        [_usernameTF.rac_textSignal subscribeNext:^(id x){
          NSLog(@"%@", x);
        }];
        
    }
    return _usernameTF;
}

- (UITextField *)passwordTF{
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.placeholder = @"请输入密码";
        _passwordTF.backgroundColor = [UIColor orangeColor];
        CGFloat x,y,w,h;
        
        h = 30;
        x = 20;
        w = kScreenWidth-2*x;
        y = self.usernameTF.frame.origin.y+self.usernameTF.frame.size.height+10;
        _passwordTF.frame = (CGRect){x,y,w,h};
    }
    return _passwordTF;
}

- (UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitle:@"登录" forState:UIControlStateSelected];
        
        [_loginButton setBackgroundColor:[UIColor blueColor]];
        CGFloat x,y,w,h;
        h = 30;
        x = 20;
        w = kScreenWidth-2*x;
        y = self.passwordTF.frame.origin.y+self.passwordTF.frame.size.height+10;
        _loginButton.frame = (CGRect){x,y,w,h};
    }
    return _loginButton;
}
@end
