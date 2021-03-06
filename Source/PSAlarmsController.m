//
//  PSAlarmsController.m
//  Pester
//
//  Created by Nicholas Riley on Fri Oct 11 2002.
//  Copyright (c) 2002 Nicholas Riley. All rights reserved.
//

#import "PSAlarmsController.h"
#import "PSAlarm.h"
#import "PSAlerts.h"
#import "NSString-NJRExtensions.h"
#import "NSTableView-NJRExtensions.h"
#import "NJRTableDelegate.h"

@interface PSAlarmsController (PrivateUndoSupport)

- (void)_restoreAlarms:(NSSet *)selectedAlarms;
- (void)_removeAlarms:(NSSet *)selectedAlarms;

@end

@implementation PSAlarmsController

- (void)alarmsChanged;
{
    reorderedAlarms = [(NJRTableDelegate *)[alarmList delegate] reorderedDataForData: [alarms alarms]];
}

- (id)init;
{
    if ( (self = [super initWithWindowNibName: @"Alarms"]) != nil) {
        alarms = [PSAlarms allAlarms];
        // XXX workaround for bug in 10.2.1, 10.1.5: autosave name set in IB doesn't show up
        [self setWindowFrameAutosaveName: @"Pester alarm list"];
        // Apple documents the NSUserDefaults key, so we can rely on it hopefully.
        if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:
            [@"NSWindow Frame " stringByAppendingString: [[self window] frameAutosaveName]]])
           {
            [[self window] center];
           }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver: self selector: @selector(alarmsChanged) name: PSAlarmsDidChangeNotification object: alarms];
        [notificationCenter addObserver: self selector: @selector(tableViewSelectionDidChange:) name: NSTableViewSelectionDidChangeNotification object: alarmList];
        [notificationCenter addObserver: alarmList selector: @selector(reloadData) name: NSCurrentLocaleDidChangeNotification object: nil];
        [notificationCenter addObserver: alarmList selector: @selector(reloadData) name: NSSystemTimeZoneDidChangeNotification object: nil];
        [alarmList setAutosaveName: @"Alarm list"];
        [alarmList setAutosaveTableColumns: YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [alarmList scrollRowToVisible: 0]; // XXX partial workaround for bug in 10.10 (r. 18292112)
        });
        [self alarmsChanged];
        [[self window] makeFirstResponder: alarmList];
        [[self window] setResizeIncrements: NSMakeSize(1, [alarmList cellHeight])];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver: alarmList];
    [reorderedAlarms release];
    [super dealloc];
}

- (NSUndoManager *)undoManager;
{
    return [[self window] undoManager];
}

- (void)_restoreAlarms:(NSSet *)selectedAlarms;
{
    [alarms restoreAlarms: selectedAlarms];
    [(NJRTableDelegate *)[alarmList delegate] selectItems: selectedAlarms];
    [[self undoManager] setActionName: NSLocalizedString(@"Alarm Removal", "Undo action")];
    [[[self undoManager] prepareWithInvocationTarget: self] _removeAlarms: selectedAlarms];
}

- (void)_removeAlarms:(NSSet *)selectedAlarms;
{
    [alarms removeAlarms: selectedAlarms];
    [[self undoManager] setActionName: NSLocalizedString(@"Alarm Removal", "Undo action")];
    [[[self undoManager] prepareWithInvocationTarget: self] _restoreAlarms: selectedAlarms];
}

- (IBAction)remove:(id)sender;
{
    [self _removeAlarms: [(NJRTableDelegate *)[alarmList delegate] selectedItems]];
}

- (void)selectAlarm:(PSAlarm *)alarm;
{
    NSUInteger row = [reorderedAlarms indexOfObject: alarm];
    if (row == NSNotFound)
        return;

    [alarmList selectRowIndexes: [NSIndexSet indexSetWithIndex: row] byExtendingSelection: NO];
    [alarmList scrollRowToVisible: row];
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return [alarms alarmCount];
}

- (NSString *)stringValueForTableColumnIdentifier:(id)identifier row:(NSInteger)row;
{
    PSAlarm *alarm = [reorderedAlarms objectAtIndex: row];

    if ([identifier isEqualToString: @"message"])
        return [alarm message];
    if ([identifier isEqualToString: @"date"])
        return [alarm shortDateString];
    if ([identifier isEqualToString: @"time"]) {
        if ([alarm date] == nil) return @"«expired»";
        return [alarm timeString];
    }

    return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    NSString *identifier = [tableColumn identifier];

    if ([identifier isEqualToString: @"message"]) {
        PSAlarm *alarm = [reorderedAlarms objectAtIndex: row];

        if ([alarm isRepeating]) {
            NSCell *cell = (NSCell *)[tableColumn dataCellForRow: row];

            return [[alarm message] attributedStringByPrependingFontAwesomeIcon: @"\uf01e" inCell: cell];
        }
    }

    return [self stringValueForTableColumnIdentifier: identifier row: row];
}

#pragma mark NJRTableViewDataSource

- (void)removeSelectedRowsFromTableView:(NSTableView *)aTableView;
{
    [self remove: aTableView];
}

- (NSString *)toolTipForRow:(NSInteger)rowIndex;
{
    PSAlarm *alarm = [reorderedAlarms objectAtIndex: rowIndex];

    return [[alarm prettyDescription] string];
}

#pragma mark NSTableViewNotifications

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
    [removeButton setEnabled: ([alarmList numberOfSelectedRows] != 0)];
}

#pragma mark NSWindowDelegate

// XXX workaround for bug in 10.1.5, 10.2.1 (and earlier?): no autosave on window move
- (void)windowDidMove:(NSNotification *)aNotification
{
    NSString *autosaveName = [[self window] frameAutosaveName];
    // on initial display, we get a notification inside -[NSWindow setFrameAutosaveName]!
    if (autosaveName != nil) {
        [[self window] saveFrameUsingName: autosaveName];
    }
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)sender defaultFrame:(NSRect)defaultFrame;
{
    NSWindow *window = [alarmList window];
    NSRect frame = [window frame];
    NSScrollView *scrollView = [alarmList enclosingScrollView];
    float displayedHeight = [[scrollView contentView] bounds].size.height;
    float heightChange = [[scrollView documentView] bounds].size.height - displayedHeight;
    float heightExcess;

    if (heightChange >= 0 && heightChange <= 1) {
        // either the window is already optimal size, or it's too big
        float rowHeight = [alarmList cellHeight];
        heightChange = (rowHeight * [alarmList numberOfRows]) - displayedHeight;
    }

    frame.size.height += heightChange;

    if ( (heightExcess = [window minSize].height - frame.size.height) > 1 ||
         (heightExcess = [window maxSize].height - frame.size.height) < 1) {
        heightChange += heightExcess;
        frame.size.height += heightExcess;
    }

    frame.origin.y -= heightChange;

    return frame;
}

@end