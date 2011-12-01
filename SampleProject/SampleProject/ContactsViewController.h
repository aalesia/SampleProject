//
//  ContactsViewController.h
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCell.h"

#import "Utilities.h"
#import "Contact.h"

@interface ContactsViewController : UIViewController
{
    NSMutableArray *contactsArray;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet ContactCell *tableCell;

- (void)syncContacts;

@end
