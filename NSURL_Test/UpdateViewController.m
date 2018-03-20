//
//  UpdateViewController.m
//  NSURL_Test
//
//  Created by Rik Tsai on 2018/3/19.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "UpdateViewController.h"

#define TIMEZONE_TABLE [NSArray arrayWithObjects :\
@(-12)\
, @(-11)\
, @(-10)\
, @(-9.5)\
, @(-9)\
, @(-8)\
, @(-7)\
, @(-6)\
, @(-5)\
, @(-4.5)\
, @(-4)\
, @(-3.5)\
, @(-3)\
, @(-2)\
, @(-1)\
, @(0)\
, @(1)\
, @(2)\
, @(3)\
, @(3.5)\
, @(4)\
, @(4.5)\
, @(5)\
, @(5.5)\
, @(5.75)\
, @(6)\
, @(6.5)\
, @(7)\
, @(8)\
, @(8.75)\
, @(9)\
, @(9.5)\
, @(10)\
, @(10.5)\
, @(11)\
, @(11.5)\
, @(12)\
, @(12.75)\
, @(13)\
, @(14)\
,nil]

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@implementation NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@interface UpdateViewController ()
{
    __weak IBOutlet UITableView *m_tableView;
    __weak IBOutlet UIToolbar *m_toolBar;
    __weak IBOutlet UIPickerView *m_pickerView;
    
    NSString *objectId;
    NSNumber *currentTimezone;
}
@end

@implementation UpdateViewController

@synthesize objectId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [m_toolBar setHidden:YES];
    [m_pickerView setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    currentTimezone = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"timezone+%@", objectId]];
    
    NSInteger index = 0;
    for (NSNumber *num in TIMEZONE_TABLE) {
        if ([num isEqualToNumber:currentTimezone]) {
            break;
        }
        index++;
    }
    
    [m_pickerView selectRow:index inComponent:0 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateValue {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://watch-master-staging.herokuapp.com/api/users/%@", objectId]];
    
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"sessionToken+%@", objectId]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"vqYuKPOkLQLYHhk4QTGsGKFwATT4mBIGREI2m8eD" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:sessionToken forHTTPHeaderField:@"X-Parse-Session-Token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    [jsonDict setValue:currentTimezone forKey:@"timezone"];
    NSString *jsonString = [jsonDict bv_jsonStringWithPrettyPrint:NO];
    NSData *jsonData = [jsonString dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error)
    {
        NSHTTPURLResponse *asHTTPResponse = (NSHTTPURLResponse *)response;
        NSLog(@"The response is: %@", asHTTPResponse);
          
        NSInteger statusCode = asHTTPResponse.statusCode;
        if (statusCode == 200) {
            [self messageShow:@"Update Successful!"];
        }
        else {
            [self messageShow:@"Update Fail!"];
        }
          
    }];
    [task resume];
}

#pragma mark -
#pragma mark Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"ITEM";
            break;
            
        default:
            return @"";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
            
        default:
            return 1;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    switch (section)
    {
        case 0:
        {
            NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"UpdateCell%ld%ld", (long)section, (long)row];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"timezone";
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", currentTimezone];
            
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    // empty cell
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    switch (section)
    {
        case 0:
        {
            switch (row) {
                case 0:
                    [m_toolBar setHidden:NO];
                    [m_pickerView setHidden:NO];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    [m_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Picker view data source & delegate

- (IBAction)pickerCancelAction:(id)sender
{
    [m_toolBar setHidden:YES];
    [m_pickerView setHidden:YES];
}

- (IBAction)pickerDoneAction:(id)sender
{
    [m_toolBar setHidden:YES];
    [m_pickerView setHidden:YES];
    
    [self updateValue];
    
    [m_tableView reloadData];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    currentTimezone = [TIMEZONE_TABLE objectAtIndex:row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [TIMEZONE_TABLE count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", [TIMEZONE_TABLE objectAtIndex:row]];
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
                                                            
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
