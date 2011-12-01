//
//  ContactsViewController.m
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactDetailsViewController.h"

@implementation ContactsViewController
@synthesize tableView = _tableView;
@synthesize tableCell = _tableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Contacts";
    
    contactsArray = [[NSMutableArray alloc] initWithArray:[Contact fetchArray]];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(refreshTableView) 
                                                 name:NOTIFICATION_DATA_UPDATED
                                               object:nil];
    [self syncContacts];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_DATA_UPDATED
                                                  object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setTableCell:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [_tableView release];
    [_tableCell release];
    [super dealloc];
}

#pragma mark - Instance Methods

- (void)syncContacts
{
    NSLog(@"called sync contacts");
    
    void (^contacts)(void) = ^{Contact *contact = [Contact alloc];                                    
        [contact syncContacts];
        [contact release]; };
    
    [Utilities makeCallInBackgroundForBlock:contacts];
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [contactsArray removeAllObjects];
        
        [contactsArray addObjectsFromArray:[Contact fetchArray]];
        
        [_tableView reloadData];
    });
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailsViewController *contactDetailsViewController = [[ContactDetailsViewController alloc] 
                                                                  initWithNibName:@"ContactDetailsViewController" 
                                                                  bundle:nil];
    
    contactDetailsViewController.contact = [contactsArray objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:contactDetailsViewController
                                         animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contactsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactViewCell";
    
    ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = _tableCell;
        self.tableCell = nil;
    }
    
    Contact *contact = [contactsArray objectAtIndex:indexPath.row];
    
    [cell prepareCellForContact:contact];
    
    return cell;
}

@end
