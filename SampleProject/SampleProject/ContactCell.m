//
//  ContactCell.m
//  SampleProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import "ContactCell.h"
#import "ImageUtils.h"

@implementation ContactCell
@synthesize profileImage;
@synthesize nameLabel;
@synthesize emailLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareCellForContact:(Contact *)contact
{
    self.nameLabel.text = contact.name;
    self.emailLabel.text = contact.email;
    
    self.profileImage.image = [ImageUtils getCachedImage:contact.imageUrl];
}

- (void)dealloc {
    [profileImage release];
    [nameLabel release];
    [emailLabel release];
    [super dealloc];
}
@end
