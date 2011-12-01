//
//  ContactDetailsViewController.m
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import "ImageUtils.h"

@implementation ContactDetailsViewController
@synthesize profileImage;
@synthesize nameLabel;
@synthesize emailLabel;
@synthesize contact;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    self.navigationItem.title = @"Contact Details";
    
    self.nameLabel.text = self.contact.name;
    self.emailLabel.text = self.contact.email;
    
    self.profileImage.image = [ImageUtils getCachedImage:self.contact.imageUrl];
}

- (void)viewDidUnload
{
    [self setProfileImage:nil];
    [self setNameLabel:nil];
    [self setEmailLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [profileImage release];
    [nameLabel release];
    [emailLabel release];
    [super dealloc];
}
@end
