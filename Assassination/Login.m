//
//  Login.m
//  Assassination
//
//  Created by Hikari Senju on 4/21/14.
//  Copyright (c) 2014 Hikari Senju. All rights reserved.
//

#import "Login.h"
#import "ViewController.h"
#import <Parse/Parse.h>

@interface Login ()

- (void)processFieldEntries;
- (void)textInputChanged:(NSNotification *)note;
- (BOOL)shouldEnableDoneButton;

@end

@implementation Login

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.name];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.password];
	self.done.enabled = NO;
    self.name.placeholder = @"Name";
    self.password.placeholder = @"Password";
    self.password.secureTextEntry = YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[self.name becomeFirstResponder];
	[super viewWillAppear:animated];
}

-  (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.name];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.password];
}

- (IBAction)done:(id)sender {
	[self.name resignFirstResponder];
	[self.password resignFirstResponder];
	[self processFieldEntries];
}

- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if (self.name.text != nil &&
		self.name.text.length > 0 &&
		self.password.text != nil &&
		self.password.text.length > 0) {
		enableDoneButton = YES;
	}
	return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note {
	self.done.enabled = [self shouldEnableDoneButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.name) {
		[self.password becomeFirstResponder];
	}
	if (textField == self.password) {
		[self.password resignFirstResponder];
		[self processFieldEntries];
	}
	return YES;
}

- (void)processFieldEntries {

	NSString *username = self.name.text;
	NSString *password = self.password.text;
	NSString *noUsernameText = @"username";
	NSString *noPasswordText = @"password";
	NSString *errorText = @"No ";
	NSString *errorTextJoin = @" or ";
	NSString *errorTextEnding = @" entered";
	BOOL textError = NO;

	if (username.length == 0 || password.length == 0) {
		textError = YES;
        
		if (password.length == 0) {
			[self.password becomeFirstResponder];
		}
		if (username.length == 0) {
			[self.name becomeFirstResponder];
		}
	}
    
	if (username.length == 0) {
		textError = YES;
		errorText = [errorText stringByAppendingString:noUsernameText];
	}
    
	if (password.length == 0) {
		textError = YES;
		if (username.length == 0) {
			errorText = [errorText stringByAppendingString:errorTextJoin];
		}
		errorText = [errorText stringByAppendingString:noPasswordText];
	}
    
	if (textError) {
		errorText = [errorText stringByAppendingString:errorTextEnding];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}
    
	self.done.enabled = NO;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];

    
	[PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
		[activityView stopAnimating];
        
		if (user) {
            [self performSegueWithIdentifier: @"LoginDone" sender: self];
		} else {
			// Didn't get a user.
			NSLog(@"%s didn't get a user!", __PRETTY_FUNCTION__);
            
			// Re-enable the done button if we're tossing them back into the form.
			self.done.enabled = [self shouldEnableDoneButton];
			UIAlertView *alertView = nil;
            
			if (error == nil) {
				// the username or password is probably wrong.
				alertView = [[UIAlertView alloc] initWithTitle:@"Couldn’t log in:\nThe username or password were wrong." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			} else {
				// Something else went horribly wrong:
				alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			}
			[alertView show];
			// Bring the keyboard back up, because they'll probably need to change something.
			[self.name becomeFirstResponder];
		}
	}];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
