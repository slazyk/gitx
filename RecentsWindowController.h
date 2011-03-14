//
//  RecentsWindowController.h
//  GitX
//
//  Created by Ole Zorn on 15.01.11.
//  Copyright 2011 omz:software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RecentsWindowController : NSWindowController {

	NSArray *recentDocumentURLs;
	IBOutlet NSTableView *tableView;
    IBOutlet NSTextField *dateLabel;
    IBOutlet NSTextField *versionLabel;
}

@property (nonatomic, retain) NSArray *recentDocumentURLs;

- (IBAction)openSelectedRepository:(id)sender;
- (void)reload;
- (IBAction)updateDateLabel:(id)sender;

@end
