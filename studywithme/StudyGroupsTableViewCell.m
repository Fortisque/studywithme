//
//  StudyGroupsTableViewCell.m
//  studywithme
//
//  Created by Alice J. Liu on 2014-10-25.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "StudyGroupsTableViewCell.h"

@implementation StudyGroupsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editButtonPressed:(id)sender {
}
@end
