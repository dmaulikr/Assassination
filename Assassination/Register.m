//
//  Register.m
//  Assassination
//
//  Created by Hikari Senju on 4/21/14.
//  Copyright (c) 2014 Hikari Senju. All rights reserved.
//

#import "Register.h"
#import "ViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface Register ()

@property (nonatomic, strong) MBProgressHUD *hud;

- (void)processFieldEntries;
- (void)textInputChanged:(NSNotification *)note;
- (BOOL)shouldEnableDoneButton;

@end

@implementation Register

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.email];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.password];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordconfirm];
    self.email.placeholder = @"Email";
    self.password.placeholder = @"Password";
    self.passwordconfirm.placeholder = @"Password Again";
    self.password.secureTextEntry = YES;
    self.passwordconfirm.secureTextEntry = YES;
    self.done.enabled = NO;
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[self.email becomeFirstResponder];
	[super viewWillAppear:animated];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.email];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.password];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordconfirm];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.email) {
		[self.password becomeFirstResponder];
	}
	if (textField == self.password) {
		[self.passwordconfirm becomeFirstResponder];
        [self processFieldEntries];
	}
    
	return YES;
}

#pragma mark - ()

- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if (self.email.text != nil &&
		self.email.text.length > 0 &&
		self.password.text != nil &&
		self.password.text.length > 0 &&
		self.passwordconfirm.text != nil &&
		self.passwordconfirm.text.length > 0 &&
        [self.password.text compare:self.passwordconfirm.text] == NSOrderedSame) {
		enableDoneButton = YES;
	}
	return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note {
	self.done.enabled = [self shouldEnableDoneButton];
}

- (IBAction)done:(id)sender {
    [self.email resignFirstResponder];
	[self.password resignFirstResponder];
	[self.passwordconfirm resignFirstResponder];
    [self processFieldEntries];
}

- (void)processFieldEntries {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    self.hud.labelText = NSLocalizedString(@"Registering", nil);
    self.hud.dimBackground = YES;
    
	NSString *name = self.email.text;
	NSString *password = self.password.text;
	NSString *email = self.email.text;
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
	PFUser *user = [PFUser user];
	user.username = name;
	user.password = password;
    user.email = email;
    [user setObject:uuid forKey:@"uuid"];
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
            [MBProgressHUD hideHUDForView:self.view.superview animated:NO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			self.done.enabled = [self shouldEnableDoneButton];
            [activityView stopAnimating];
			[self.email becomeFirstResponder];
			return;
		}
        
        [activityView stopAnimating];
        [MBProgressHUD hideHUDForView:self.navigationController.presentedViewController.view animated:NO];
        [self performSegueWithIdentifier: @"RegisterDone" sender: self];
        
	}];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
