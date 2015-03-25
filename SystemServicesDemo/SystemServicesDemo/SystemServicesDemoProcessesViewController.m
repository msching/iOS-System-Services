//
//  SystemServicesDemoProcessesViewController.m
//  SystemServicesDemo
//
//  Created by Kramer on 4/4/13.
//  Copyright (c) 2013 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesDemoProcessesViewController.h"
#import "SystemServices.h"

#import "DetailViewController.h"

#define SystemSharedServices [SystemServices sharedServices]

@interface SystemServicesDemoProcessesViewController () {
    // Make an array from all the system processes
    NSMutableArray *_processes;
    NSMutableArray *_userAppProcesses;
    NSMutableArray *_systemProcess;
    NSMutableArray *_tableArray;
}

@end

@implementation SystemServicesDemoProcessesViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.tableView setContentInset:UIEdgeInsetsMake(44,0,19,0)];
    
    [self refresh:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _tableArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_tableArray[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = _tableArray[section];
    NSString *title = nil;
    if (array == _userAppProcesses)
    {
        title =  @"user app";
    }
    else if (array == _systemProcess)
    {
        title =  @"system";
    }
    
    if (array.count > 0)
    {
        return title;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
        
    }
    
    NSArray *processes = _tableArray[indexPath.section];
    NSDictionary *pInfo = [processes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [pInfo objectForKey:@"Name"];
    
    cell.detailTextLabel.text = [pInfo objectForKey:@"PID"];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Navigation logic may go here. Create and push another view controller.
    
    // Create a dictionary from the selected cell
    NSArray *processes = _tableArray[indexPath.section];
    NSDictionary *processData = [processes objectAtIndex:indexPath.row];
    
    NSString *parentProcessName;
    
    // Determine the parent process - if it's more than 0
    if ([[processData objectForKey:@"ParentID"] integerValue] > 0) {
        for (NSDictionary *dicts in _processes) {
            if ([[dicts objectForKey:@"PID"] integerValue] == [[processData objectForKey:@"ParentID"] integerValue]) {
                // Parent process
                parentProcessName = [dicts objectForKey:@"Name"];
                break;
            }
        }
    } else if ([[processData objectForKey:@"ParentID"] integerValue] == -1) {
        parentProcessName = @"Kernel";
    } else {
        parentProcessName = @"Unknown";
    }
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail"];
    
    // Set up the information on the detail view controller
    [detailViewController setTitle:[processData objectForKey:@"Name"]];
    // Set the labels
    [detailViewController setSlblName:[NSString stringWithFormat:@"Name: %@", [processData objectForKey:@"Name"]]];
    [detailViewController setSlblPID:[NSString stringWithFormat:@"PID: %@", [processData objectForKey:@"PID"]]];
    [detailViewController setSlblParentID:[NSString stringWithFormat:@"ParentID: %@", [processData objectForKey:@"ParentID"]]];
    [detailViewController setSlblParentName:[NSString stringWithFormat:@"Parent Name: %@", parentProcessName]];
    [detailViewController setSlblPriority:[NSString stringWithFormat:@"Priority: %@", [processData objectForKey:@"Priority"]]];
    [detailViewController setSlblStartDate:[NSString stringWithFormat:@"Start Date: %@", [processData objectForKey:@"StartDate"]]];
    [detailViewController setSlblStatus:[NSString stringWithFormat:@"Status: %@", [processData objectForKey:@"Status"]]];
    [detailViewController setSlblFlags:[NSString stringWithFormat:@"Flags: %@", [processData objectForKey:@"Flags"]]];
    [detailViewController setSlblPath:[NSString stringWithFormat:@"Path: %@", [processData objectForKey:@"Path"]]];
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)refresh:(id)sender {
    // Set up the tableArray;

    _processes = [NSMutableArray array];
    _userAppProcesses = [NSMutableArray array];
    _systemProcess = [NSMutableArray array];
    
    [_processes addObjectsFromArray:[SystemSharedServices processesInformation]];
    
    // Error check the array
    if (_processes.count < 1) {
        // Invalid array
        [_processes addObject:@{@"Name" : @"Unknown"}];
    }
    
    [_processes sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *p1, NSDictionary *p2) {
        NSDate *d1 = p1[@"StartDate"];
        NSDate *d2 = p2[@"StartDate"];
        return [d1 compare:d2];
    }];
    
    
    for (NSDictionary *pInfo in _processes)
    {
        NSString *path = [pInfo[@"Path"] lowercaseString];
        if (
#if TARGET_IPHONE_SIMULATOR
            [path rangeOfString:@"/library/developer/"].location != NSNotFound
#else
            [path rangeOfString:@"/var/mobile/containers/bundle/application"].location != NSNotFound
#endif
            )
        {
            [_userAppProcesses addObject:pInfo];
        }
        else
        {
            [_systemProcess addObject:pInfo];
        }
    }
    
    _tableArray = [NSMutableArray array];
    if (_userAppProcesses.count > 0) {
        [_tableArray addObject:_userAppProcesses];
    }
    [_tableArray addObject:_systemProcess];
    
    // Reload the tableview
    [self.tableView reloadData];
}
@end
