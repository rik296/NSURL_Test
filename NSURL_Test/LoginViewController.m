//
//  LoginViewController.m
//  NSURL_Test
//
//  Created by Rik Tsai on 2018/3/19.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "LoginViewController.h"
#import "UpdateViewController.h"

@interface LoginViewController ()
{
    __weak IBOutlet UITextField *usernameText;
    __weak IBOutlet UITextField *passwordText;
    __weak IBOutlet UIActivityIndicatorView *progressIndicator;
    
    NSMutableString *objectId;
    BOOL isLoginOK;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    objectId = [[NSMutableString alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [progressIndicator setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnAction:(id)sender {
    [self doLogin];
}

- (void)doLogin {
    [progressIndicator setHidden:NO];
    [progressIndicator startAnimating];
    NSString *username = usernameText.text;
    NSString *password = passwordText.text;
    
    NSString *encode_username = [username stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *encode_password = [password stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSLog(@"encode usr : %@", encode_username);
    NSLog(@"encode_pwd : %@", encode_password);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://watch-master-staging.herokuapp.com/api/login?username=%@&password=%@", encode_username, encode_password]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"vqYuKPOkLQLYHhk4QTGsGKFwATT4mBIGREI2m8eD" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"1" forHTTPHeaderField:@"X-Parse-Revocable-Session"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error)
    {
        NSHTTPURLResponse *asHTTPResponse = (NSHTTPURLResponse *)response;
        NSLog(@"The response is: %@", asHTTPResponse);
        
        NSMutableString *message = [[NSMutableString alloc] init];
        NSInteger statusCode = asHTTPResponse.statusCode;
        if (statusCode == 200) {
            isLoginOK = YES;
            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:nil];
            
            // Save Information
            [objectId setString:[forJSONObject objectForKey:@"objectId"]];
            NSString *username = [forJSONObject objectForKey:@"username"];
            NSString *sessionToken = [forJSONObject objectForKey:@"sessionToken"];
            NSNumber *timezone = [forJSONObject objectForKey:@"timezone"];
            
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:[NSString stringWithFormat:@"username+%@", objectId]];
            [[NSUserDefaults standardUserDefaults] setValue:sessionToken forKey:[NSString stringWithFormat:@"sessionToken+%@", objectId]];
            [[NSUserDefaults standardUserDefaults] setValue:timezone forKey:[NSString stringWithFormat:@"timezone+%@", objectId]];
            
            [message appendString:[NSString stringWithFormat:@"Login Successful!\n\n"]];
            [message appendString:[NSString stringWithFormat:@"createdAt : %@\n", [forJSONObject objectForKey:@"createdAt"]]];
            [message appendString:[NSString stringWithFormat:@"username : %@\n", username]];
            [message appendString:[NSString stringWithFormat:@"objectId : %@\n", objectId]];
            [message appendString:[NSString stringWithFormat:@"sessionToken : %@\n", sessionToken]];
            [message appendString:[NSString stringWithFormat:@"timezone : %@\n", timezone]];
            [message appendString:[NSString stringWithFormat:@"updatedAt : %@\n", [forJSONObject objectForKey:@"updatedAt"]]];
            
            [self messageShow:message];
        }
        else {
            isLoginOK = NO;
            [message appendString:[NSString stringWithFormat:@"Login Fail!\n\n"]];
            [message appendString:[NSString stringWithFormat:@"%@\n", asHTTPResponse]];
            [self messageShow:message];
        }
        
    }];
    [task resume];
    
}

-(void)messageShow:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, message.length)];
        [alertController setValue:attrStr forKey:@"attributedMessage"];
        
        alertController.view.frame = [[UIScreen mainScreen] bounds];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                              [progressIndicator setHidden:YES];
                                                              [progressIndicator stopAnimating];
                                                              
                                                              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                              UpdateViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UpdateViewController"];
                                                              vc.objectId = objectId;
                                                              [self.navigationController pushViewController:vc animated:NO];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
