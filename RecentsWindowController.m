//
//  RecentsWindowController.m
//  GitX
//
//  Created by Ole Zorn on 15.01.11.
//  Copyright 2011 omz:software. All rights reserved.
//

#import "RecentsWindowController.h"
#import "PBRepositoryDocumentController.h"

@implementation RecentsWindowController

@synthesize recentDocumentURLs;

- (void)windowDidLoad
{
	self.recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	
	[tableView setDoubleAction:@selector(openSelectedRepository:)];
	[tableView setTarget:self];
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
		[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12.0], NSFontAttributeName, nil] range:NSMakeRange(0, [name length])];
		[attributedTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0], NSFontAttributeName, nil] range:NSMakeRange([name length], [title length] - [name length])];
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
