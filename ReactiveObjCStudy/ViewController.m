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
#import <MBProgressHUD.h>

typedef void (^xxSignInResponse)(BOOL);

@interface xxSignInService : NSObject

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(xxSignInResponse)completeBlock;

@end

@implementation xxSignInService


- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(xxSignInResponse)completeBlock {

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        BOOL success = [username isEqualToString:@"user"] && [password isEqualToString:@"password"];
        completeBlock(success);
    });
}


@end


@interface ViewController ()
@property(nonatomic,strong) UITextField *usernameTF;
@property(nonatomic,strong) UITextField *passwordTF;
@property(nonatomic,strong) UIButton *loginButton;
@property (strong, nonatomic) xxSignInService *signInService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.signInService = [xxSignInService new];
    [self.view addSubview:self.usernameTF];
    [self.view addSubview:self.passwordTF];
    [self.view addSubview:self.loginButton];
    
    [self bindsignal];
    [self testSignal];
}


-(void)testSignal{
    //创建信号
        RACSignal * single = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"2");
            [subscriber sendNext:@"发送了信号"];//发送信号
            NSLog(@"4");
           [subscriber sendCompleted];//发送完成，订阅自动移除
            //RACDisposable 可用于手动移除订阅
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"5-RACDisposable");
            }];
        }];
        //订阅信号
        NSLog(@"1");
        [single subscribeNext:^(id x) {
            NSLog(@"3");
            NSLog(@"信号的值：%@",x);
        }];
    
    //手动移除订阅
      // [disposable dispose];
}

-(void)bindsignal{
    
    @weakify(self);
    [[self.usernameTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.usernameTF resignFirstResponder];
    }];
    [[self.passwordTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
         @strongify(self);
         [self.passwordTF resignFirstResponder];
     }];
    
    RACSignal *validUsernameSignal = [self.usernameTF.rac_textSignal map:^id (NSString *  text) {
        return @(text.length>3?YES:NO);
    }];
    
    RACSignal *validPasswordSignal = [self.passwordTF.rac_textSignal map:^id (NSString *  text) {
        return @(text.length>3?YES:NO);
    }];
    
    RAC(self.usernameTF,backgroundColor) = [validUsernameSignal map:^id (NSNumber * value) {
        return [value boolValue] ? [UIColor orangeColor] : [UIColor clearColor];
    }];
    
    RAC(self.passwordTF,backgroundColor) = [validPasswordSignal map:^id _Nullable(NSNumber * value) {
         return [value boolValue] ? [UIColor orangeColor] : [UIColor clearColor];
    }];
    
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                                                      reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid){
        return @([usernameValid boolValue] && [passwordValid boolValue]);
    }];
    
    [signUpActiveSignal subscribeNext:^(NSNumber *signupActive) {
        self.loginButton.enabled = [signupActive boolValue];
        self.loginButton .backgroundColor = [signupActive boolValue] ? [UIColor orangeColor] : [UIColor clearColor];
    }];
    
    
      [[[[self.loginButton
      rac_signalForControlEvents:UIControlEventTouchUpInside]
      doNext:^(id x) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        self.loginButton.enabled = NO;
        self.loginButton .backgroundColor = [UIColor clearColor];
      }]
      flattenMap:^id(id x) {
        return [self signInSignal];
      }]
      subscribeNext:^(NSNumber *signedIn) {
           self.loginButton.enabled = YES;
           self.loginButton .backgroundColor = [UIColor orangeColor];
           BOOL success = [signedIn boolValue];
          if (success) {
              NSLog(@"登录成功！");
            
          }else{
              NSLog(@"登录失败！");
          }
          [MBProgressHUD hideHUDForView:self.view animated:YES];
         
      }];
    
}

- (UITextField *)usernameTF{
    if (!_usernameTF) {
        _usernameTF = [[UITextField alloc]init];
        _usernameTF.placeholder = @"请输入用户名称";
        _usernameTF.backgroundColor = [UIColor clearColor];
        CGFloat x,y,w,h;
        
        h = 30;
        x = 20;
        w = kScreenWidth-2*x;
        y = (kScreenHeight-h)/2.0f;
        _usernameTF.frame = (CGRect){x,y,w,h};
    }
    return _usernameTF;
}

- (UITextField *)passwordTF{
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.placeholder = @"请输入密码";
        _passwordTF.backgroundColor = [UIColor clearColor];
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
        [_loginButton setBackgroundColor:[UIColor clearColor]];
        [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        CGFloat x,y,w,h;
        h = 30;
        x = 20;
        w = kScreenWidth-2*x;
        y = self.passwordTF.frame.origin.y+self.passwordTF.frame.size.height+10;
        _loginButton.frame = (CGRect){x,y,w,h};
    }
    return _loginButton;
}


-(RACSignal *)signInSignal {
    
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [self.signInService
     signInWithUsername:self.usernameTF.text
     password:self.usernameTF.text
     complete:^(BOOL success) {
       [subscriber sendNext:@(success)];
       [subscriber sendCompleted];
     }];
    return nil;
  }];
    
}
@end
