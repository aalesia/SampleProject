//
//  ContactDetailsViewController.h
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactDetailsViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *profileImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *emailLabel;

@property (retain, nonatomic) Contact *contact;

@end
