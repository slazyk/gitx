//
//  RecentsWindowController.m
//  GitX
//
//  Created by Ole Zorn on 15.01.11.
//  Copyright 2011 omz:software. All rights reserved.
//

#import "RecentsWindowController.h"
#import "PBRepositoryDocumentController.h"

#import <sys/stat.h>

@implementation RecentsWindowController

@synthesize recentDocumentURLs;

- (void)updateDateLabel:(id)sender {
	NSInteger selectedRow = [tableView selectedRow];
	if (selectedRow >= 0) {
		NSURL *repoURL = [recentDocumentURLs objectAtIndex:selectedRow];
        
        struct stat output;
        if(stat([[repoURL path] UTF8String], &output)) {
            [dateLabel setStringValue:[NSString stringWithFormat:@"Last modified: (unknown)"]];
        } else {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:output.st_mtime];
            NSDateFormatter *f = [NSDateFormatter new];
            [f setDateStyle: NSDateFormatterLongStyle];
            [f setTimeStyle: NSDateFormatterShortStyle];
            [f setDoesRelativeDateFormatting: YES];
            [dateLabel setStringValue:[NSString stringWithFormat:@"Last modified: %@", [f stringFromDate:date]]];
        }
	}

}

- (void)windowDidLoad
{
    [[self window] setContentBorderThickness: 48 forEdge: NSMinYEdge];
	self.recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	
	[tableView setDoubleAction:@selector(openSelectedRepository:)];
	[tableView setTarget:self];
    [self updateDateLabel: self];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *ver = [info objectForKey: @"CFBundleGitVersion"];
    if (ver == nil) {
        ver = [info objectForKey: @"CFBundleVersion"];
    }
    [versionLabel setStringValue: [@"Version " stringByAppendingString: ver]];
}

- (void)reload
{
	self.recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
	[tableView reloadData];
	if ([tableView numberOfRows] > 0) {
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	}
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	//Close our window if another window becomes main 
	//(likely because a repository was opened from elsewhere):
	if ([notification object] != [self window]) {
		[[self window] performClose:self];
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.recentDocumentURLs count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqual:@"Icon"]) {
		NSString *path = [[recentDocumentURLs objectAtIndex:row] path];
		return [[NSWorkspace sharedWorkspace] iconForFile:path];
		//return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
		
	} else if ([[tableColumn identifier] isEqual:@"Title"]) {
		return nil; //will be set in tableView:willDisplayCell:...
	}
	return nil;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqual:@"Title"]) {
		BOOL selected = (row == [aTableView selectedRow]);
		NSURL *URL = [recentDocumentURLs objectAtIndex:row];
		NSString *name = [[URL path] lastPathComponent];
		NSString *path = [[URL path] stringByAbbreviatingWithTildeInPath];
		NSString *title = [NSString stringWithFormat:@"%@\n%@", name, path];
		NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc] initWithString:title] autorelease];
		[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:12.0], NSFontAttributeName, nil] range:NSMakeRange(0, [name length])];
		[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10.0], NSFontAttributeName, nil] range:NSMakeRange([name length], [title length] - [name length])];
		if (!selected) {
			[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [name length])];
			[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor grayColor], NSForegroundColorAttributeName, nil] range:NSMakeRange([name length], [title length] - [name length])];
		} else {
			[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [name length])];
			[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, nil] range:NSMakeRange([name length], [title length] - [name length])];
		}
		[cell setAttributedStringValue:attributedTitle];
	}
}

- (IBAction)openSelectedRepository:(id)sender
{
	NSInteger selectedRow = [tableView selectedRow];
	if (selectedRow >= 0) {
		NSURL *repoURL = [recentDocumentURLs objectAtIndex:selectedRow];
		[[self window] performClose:self];
		[[PBRepositoryDocumentController sharedDocumentController] documentForLocation:repoURL];
	}
}

- (void)dealloc
{
	[recentDocumentURLs release];
	[super dealloc];
}

@end
