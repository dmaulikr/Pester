//
//  NJRMediaPopUpButton.m
//  Pester
//
//  Created by Nicholas Riley on Sat Oct 26 2002.
//  Copyright (c) 2002 Nicholas Riley. All rights reserved.
//

#import "AVAsset-NJRExtensions.h"
#import "BDAlias.h"
#import "NJRMediaPopUpButton.h"
#import "NJRFSObjectSelector.h"
#import "NJRSoundDevice.h"
#import "NSMenuItem-NJRExtensions.h"

#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include <limits.h>

static const int NJRMediaPopUpButtonMaxRecentItems = 10;

NSString * const NJRMediaPopUpButtonMovieChangedNotification = @"NJRMediaPopUpButtonMovieChangedNotification";

@interface NJRMediaPopUpButton (Private)
- (void)_setPath:(NSString *)path;
- (NSMenuItem *)_itemForAlias:(BDAlias *)alias;
- (BOOL)_validateWithPreview:(BOOL)doPreview;
- (void)_startSoundPreview;
- (void)_soundPreviewDidEnd:(NSNotification *)notification;
- (void)_resetPreview;
- (void)_aliasSelected:(NSMenuItem *)sender;
- (void)_beepSelected:(NSMenuItem *)sender;
- (void)_systemSoundSelected:(NSMenuItem *)sender;
@end

@implementation NJRMediaPopUpButton

// XXX handle refreshing sound list on resume
// XXX launch preview on a separate thread (if movies take too long to load, they inhibit the interface responsiveness)

// Recent media layout:
// Most recent media are at TOP of menu (smaller item numbers, starting at [self indexOfItem: otherItem] + 1)
// Most recent media are at END of array (larger indices)

#pragma mark recently selected media tracking

- (NSString *)_defaultKey;
{
    NSAssert([self tag] != 0, NSLocalizedString(@"Can't track recently selected media for popup with tag 0: please set a tag", "Assertion for media popup button if tag is 0"));
    return [NSString stringWithFormat: @"NJRQTMediaPopUpButtonMaxRecentItems tag %ld", (long)[self tag]];
}

- (void)_writeRecentMedia;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: recentMediaAliasData forKey: [self _defaultKey]];
    [defaults synchronize];
}

- (NSMenuItem *)_addRecentMediaAtPath:(NSString *)path withAlias:(BDAlias *)alias;
{
    NSString *title = [[NSFileManager defaultManager] displayNameAtPath: path];
    NSMenu *menu = [self menu];
    NSMenuItem *item;
    if (title == nil || path == nil) return nil;
    item = [menu insertItemWithTitle: title action: @selector(_aliasSelected:) keyEquivalent: @"" atIndex: [menu indexOfItem: otherItem] + 1];
    [item setTarget: self];
    [item setRepresentedObject: alias];
    [item setImageFromPath: path];
    [recentMediaAliasData addObject: [alias aliasData]];
    if ([recentMediaAliasData count] > NJRMediaPopUpButtonMaxRecentItems) {
        [menu removeItemAtIndex: [menu numberOfItems] - 1];
        [recentMediaAliasData removeObjectAtIndex: 0];
    }
    return item;
}

- (void)_addRecentMediaFromAliasesData:(NSArray *)aliasesData;
{
    NSEnumerator *e = [aliasesData objectEnumerator];
    NSData *aliasData;
    BDAlias *alias;
    while ( (aliasData = [e nextObject]) != nil) {
        if ( (alias = [[BDAlias alloc] initWithData: aliasData]) != nil) {
            [self _addRecentMediaAtPath: [alias fullPath] withAlias: alias];
            [alias release];
        }
    }
}

- (void)_validateRecentMedia;
{
    NSEnumerator *e = [recentMediaAliasData reverseObjectEnumerator];
    NSData *aliasData;
    NSMenuItem *item;
    BDAlias *itemAlias;
    NSInteger otherIndex = [self indexOfItem: otherItem];
    NSInteger aliasDataCount = [recentMediaAliasData count];
    NSInteger lastItemIndex = [self numberOfItems] - 1;
    NSInteger recentItemCount = lastItemIndex - otherIndex;
    NSInteger recentItemIndex = otherIndex;
    NSAssert2(recentItemCount == aliasDataCount, @"Counted %d recent menu items, %d of alias data", (int)recentItemCount, (int)aliasDataCount);
    while ( (aliasData = [e nextObject]) != nil) { // go BACKWARD through array while going DOWN menu
        recentItemIndex++;
        item = [self itemAtIndex: recentItemIndex];
        itemAlias = [item representedObject];
    }
}

#pragma mark initialize-release

- (void)_setUp;
{
    NSMenu *menu = [self menu];
    [self removeAllItems];
    [menu setAutoenablesItems: NO];

    NSMenuItem *item = [menu addItemWithTitle: @"Alert sound" action: @selector(_beepSelected:) keyEquivalent: @""];
    [item setTarget: self];
    [menu addItem: [NSMenuItem separatorItem]];

    NSMutableArray *soundFolderPaths = [[NSMutableArray alloc] initWithCapacity: kLastDomainConstant - kSystemDomain + 1];
    for (FSVolumeRefNum domain = kSystemDomain ; domain <= kLastDomainConstant ; domain++) {
	OSStatus err;
	FSRef fsr;
	err = FSFindFolder(domain, kSystemSoundsFolderType, kDontCreateFolder, &fsr);
	if (err != noErr) continue;

	UInt8 path[PATH_MAX];
	err = FSRefMakePath(&fsr, path, PATH_MAX);
	if (err != noErr) continue;

	CFStringRef pathString = CFStringCreateWithFileSystemRepresentation(NULL, (const char *)path);
	if (pathString == NULL) continue;

	[soundFolderPaths addObject: (NSString *)pathString];
	CFRelease(pathString);
    }

    NSArray *audiovisualTypes = AVURLAsset.audiovisualTypes;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSEnumerator *e = [soundFolderPaths objectEnumerator];
    NSString *folderPath;
    while ( (folderPath = [e nextObject]) != nil) {
	if (![fm changeCurrentDirectoryPath: folderPath]) continue;

	NSDirectoryEnumerator *de = [fm enumeratorAtPath: folderPath];
	NSString *path;
	NSString *displayName;
	while ( (path = [de nextObject]) != nil) {
	    BOOL isDir;
	    if (![fm fileExistsAtPath: path isDirectory: &isDir] || isDir) {
		[de skipDescendents]; // [sic]
		continue;
	    }

            NSString *type = [[NSWorkspace sharedWorkspace] typeOfFile: path error: NULL];
            if (type == nil)
                continue;

            BOOL hasConformingType = NO;
            for (NSString *matchingType in audiovisualTypes) {
                if (UTTypeConformsTo((CFStringRef)type, (CFStringRef)matchingType)) {
                    hasConformingType = YES;
                    break;
                }
            }
            if (!hasConformingType)
                continue;

            NSURL *url = [NSURL fileURLWithPath: path];
            AVAsset *asset = [[AVURLAsset alloc] initWithURL: url options: nil];
            BOOL isPlayable = asset.isPlayable;
            [asset release];
            if (!isPlayable) continue;
	    
	    displayName = [fm displayNameAtPath: path];
	    if ([[NSNumber numberWithBool: NO] isEqualTo: [[de fileAttributes] objectForKey: NSFileExtensionHidden]])
		displayName = [displayName stringByDeletingPathExtension];

	    item = [menu addItemWithTitle: displayName
				   action: @selector(_systemSoundSelected:)
			    keyEquivalent: @""];
            [item setTarget: self];
            [item setImageFromPath: path];
	    path = [folderPath stringByAppendingPathComponent: path];
            [item setRepresentedObject: path];
	    [item setToolTip: [[fm componentsToDisplayForPath: path] componentsJoinedByString: @" \u25b8 "]];
        }
    }
    [soundFolderPaths release];
    
    if ([menu numberOfItems] == 2) {
        item = [menu addItemWithTitle: NSLocalizedString(@"Can't locate alert sounds", "Media popup menu item surrogate for alert sound list if no sounds are found") action: nil keyEquivalent: @""];
        [item setEnabled: NO];
    }
	 
    [menu addItem: [NSMenuItem separatorItem]];
    item = [menu addItemWithTitle: NSLocalizedString(@"Other...", "Media popup item to select another sound/movie/image") action: @selector(select:) keyEquivalent: @""];
    [item setTarget: self];
    otherItem = [item retain];

    preview = [[AVPlayer alloc] initWithPlayerItem: nil];
    [self _validateWithPreview: NO];

    recentMediaAliasData = [[NSMutableArray alloc] initWithCapacity: NJRMediaPopUpButtonMaxRecentItems + 1];
    [self _addRecentMediaFromAliasesData: [[NSUserDefaults standardUserDefaults] arrayForKey: [self _defaultKey]]];
    // [self _validateRecentMedia];

    [self registerForDraggedTypes:
        [NSArray arrayWithObjects: NSFilenamesPboardType, NSURLPboardType, nil]];
}

- (id)initWithFrame:(NSRect)frame;
{
    if ( (self = [super initWithFrame: frame]) != nil) {
        [self _setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if ( (self = [super initWithCoder: coder]) != nil) {
        [self _setUp];
    }
    return self;
}

- (void)dealloc;
{
    [recentMediaAliasData release]; recentMediaAliasData = nil;
    [otherItem release];
    [selectedAlias release]; [previousAlias release];
    [preview release];
    [super dealloc];
}

#pragma mark accessing

- (BDAlias *)selectedAlias;
{
    return selectedAlias;
}

- (void)_setAlias:(BDAlias *)alias;
{
    BDAlias *oldAlias = [selectedAlias retain];
    [previousAlias release];
    previousAlias = oldAlias;
    if (selectedAlias != alias) {
        [selectedAlias release];
        selectedAlias = [alias retain];
    }
}

- (void)setAlias:(BDAlias *)alias;
{
    [self _setAlias: alias];
    if ([self _validateWithPreview: NO]) {
        [self selectItem: [self _itemForAlias: selectedAlias]];
    }
}

- (void)_setPath:(NSString *)path;
{
    [self _setAlias: [BDAlias aliasWithPath: path]];
}

- (NSMenuItem *)_itemForAlias:(BDAlias *)alias;
{
    if (alias == nil) return [self itemAtIndex: 0];

    // [self _validateRecentMedia];
    NSString *path = [alias fullPath];

    // selected a system sound?
    NSInteger itemIndex = [[self menu] indexOfItemWithRepresentedObject: path];
    if (itemIndex != -1) {
        // NSLog(@"_itemForAlias: selected system sound");
        return [self itemAtIndex: itemIndex];
    } else {
        NSEnumerator *e = [recentMediaAliasData reverseObjectEnumerator];
        NSData *aliasData;
        NSMenuItem *item;
        int recentIndex = 1;

        while ( (aliasData = [e nextObject]) != nil) {
            // selected a recently selected, non-system sound?
            if ([alias aliasDataIsEqual: aliasData]) {
                NSInteger otherIndex = [self indexOfItem: otherItem];
                NSInteger menuIndex = recentIndex + otherIndex;
                if (menuIndex == otherIndex + 1) return [self itemAtIndex: menuIndex]; // already at top
                // remove item, add (at top) later
                // NSLog(@"_itemForAlias removing item: idx %d + otherItemIdx %d + 1 = %d [%@]", recentIndex, otherIndex, menuIndex, [self itemAtIndex: menuIndex]);
                [self removeItemAtIndex: menuIndex];
                [recentMediaAliasData removeObjectAtIndex: [recentMediaAliasData count] - recentIndex];
                break;
            }
            recentIndex++;
        }

        // create the item
        item = [self _addRecentMediaAtPath: path withAlias: alias];
        [self _writeRecentMedia];
        return item;
    }
}

- (BOOL)canRepeat;
{
    return mediaCanRepeat;
}

- (BOOL)canAdjustVolume;
{
    return mediaCanAdjustVolume;
}

- (BOOL)hasVideo;
{
    return mediaHasVideo;
}

- (float)outputVolume;
{
    return outputVolume;
}

- (void)setOutputVolume:(float)volume withPreview:(BOOL)doPreview;
{
    if (![NJRSoundDevice volumeIsNotMutedOrInvalid: volume]) return;
    outputVolume = volume;
    if (!doPreview) return;
    // NSLog(@"setting volume to %f, preview movie %@", volume, [preview movie]);
    if (preview.currentItem == nil) {
        [self _validateWithPreview: YES];
    } else {
        [self _startSoundPreview];
    }
}

#pragma mark selected media validation

- (void)_invalidateSelection;
{
    [self _setAlias: previousAlias];
    [self selectItem: [self _itemForAlias: [self selectedAlias]]];
    [[NSNotificationCenter defaultCenter] postNotificationName: NJRMediaPopUpButtonMovieChangedNotification object: self];
}

- (void)_startSoundPreview;
{
    if (preview.currentItem == nil)
        return;

    if (outputVolume == 0) {
        [self _resetPreview];
        return;
    }

    preview.volume = outputVolume;

    if (preview.rate != 0)
	return; // don't restart preview if already playing
    
    preview.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_soundPreviewDidEnd:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: preview.currentItem];
    
    [preview play];
}

- (void)_soundPreviewDidEnd:(NSNotification *)notification;
{
    [self _resetPreview];
}

- (void)_resetPreview;
{
    [preview replaceCurrentItemWithPlayerItem: nil];
}

- (BOOL)_validateWithPreview:(BOOL)doPreview;
{
    // prevent _resetPreview from triggering afterward (crashes)
    [[NSNotificationCenter defaultCenter] removeObserver: self
						    name: AVPlayerItemDidPlayToEndTimeNotification
						  object: nil];
    [preview pause];
    if (selectedAlias == nil) {
        [self _resetPreview];
        mediaCanRepeat = YES;
        mediaCanAdjustVolume = NO;
        mediaHasVideo = NO;
        if (doPreview) {
            AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        }
    } else {
        AVAsset *asset = [AVAsset assetWithURL: [selectedAlias fileURL]];
        if (!asset.isPlayable)
            asset = nil;
    
        if ([asset NJR_hasAudio]) {
            mediaCanAdjustVolume = YES;
            if (doPreview) {
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset: asset];
                [preview replaceCurrentItemWithPlayerItem: item];
            } else {
                [self _resetPreview];
            }
        } else {
            [self _resetPreview];
            doPreview = NO;
            if (asset == nil) {
                NSBeginAlertSheet(@"Format not recognized", nil, nil, nil, [self window], nil, nil, nil, nil, NSLocalizedString(@"The item you selected isn't a supported image, sound or movie.\n\nPlease select a different item.", "Message displayed in alert sheet when media document is not recognized by AVFoundation"));
                [self _invalidateSelection];
                return NO;
            }
            if (![asset NJR_hasVideo]) {
                NSBeginAlertSheet(@"No video or audio", nil, nil, nil, [self window], nil, nil, nil, nil, NSLocalizedString(@"'%@' contains neither audio nor video content.\n\nPlease select a different item.", "Message displayed in alert sheet when media document is readable, but has neither audio nor video tracks"), [[NSFileManager defaultManager] displayNameAtPath: [selectedAlias fullPath]]);
                [self _invalidateSelection];
                return NO;
            }
            mediaCanAdjustVolume = NO;
        }
        mediaCanRepeat = ![asset NJR_isStatic];
        mediaHasVideo = [asset NJR_hasVideo];

        if (doPreview) {
            [self _startSoundPreview];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: NJRMediaPopUpButtonMovieChangedNotification object: self];
    return YES;
}

#pragma mark actions

- (IBAction)stopSoundPreview:(id)sender;
{
    [preview pause];
    [self _resetPreview];
}

- (void)_beepSelected:(NSMenuItem *)sender;
{
    [self _setAlias: nil];
    [self _validateWithPreview: YES];
}

- (void)_systemSoundSelected:(NSMenuItem *)sender;
{
    [self _setPath: [sender representedObject]];
    if (![self _validateWithPreview: YES]) {
        [[self menu] removeItem: sender];
    }
}

- (void)_aliasSelected:(NSMenuItem *)sender;
{
    BDAlias *alias = [sender representedObject];
    NSInteger itemIndex = [self indexOfItem: sender], otherIndex = [self indexOfItem: otherItem];
    [self _setAlias: alias];
    if (![self _validateWithPreview: YES]) {
        [[self menu] removeItem: sender];
    } else if (itemIndex > otherIndex + 1) { // move "other" item to top of list
        NSInteger recentIndex = [recentMediaAliasData count] - itemIndex + otherIndex;
        NSMenuItem *item = [[self itemAtIndex: itemIndex] retain];
        NSData *data = [[recentMediaAliasData objectAtIndex: recentIndex] retain];
        // [self _validateRecentMedia];
        [self removeItemAtIndex: itemIndex];
        [[self menu] insertItem: item atIndex: otherIndex + 1];
        [self selectItem: item];
        [item release];
        NSAssert(recentIndex >= 0, @"Recent media index invalid");
        // NSLog(@"_aliasSelected removing item %d - %d + %d = %d of recentMediaAliasData", [recentMediaAliasData count], index, otherIndex, recentIndex);
        [recentMediaAliasData removeObjectAtIndex: recentIndex];
        [recentMediaAliasData addObject: data];
        [self _validateRecentMedia];
        [data release];
    } // else NSLog(@"_aliasSelected ...already at top");
}

- (IBAction)select:(id)sender;
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSString *path = [selectedAlias fullPath];
    NSURL *url = path == nil ? nil : [NSURL fileURLWithPath: [selectedAlias fullPath]];
    openPanel.allowedFileTypes = AVURLAsset.audiovisualTypes;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    openPanel.directoryURL = url; // [sic] - this works with a file URL

    [openPanel beginSheetModalForWindow: [self window] completionHandler:
     ^(NSInteger result) {
         if (result == NSOKButton) {
             NSArray *urls = [openPanel URLs];
             NSAssert1([urls count] == 1, @"%u items returned, only one expected", (unsigned)[urls count]);
             NSURL *url = [urls objectAtIndex: 0];
             NSAssert1([url isFileURL], @"file URL expected, %@ returned", url);
             [self _setPath: [url path]];
             if ([self _validateWithPreview: YES]) {
                 [self selectItem: [self _itemForAlias: selectedAlias]];
             }
         } else {
             // "Other..." item is still selected, revert to previously selected item
             // XXX issue with cancelling, top item in recent menu is sometimes duplicated!?
             [self selectItem: [self _itemForAlias: selectedAlias]];
         }
         // [self _validateRecentMedia];
     }];
}

- (void)setEnabled:(BOOL)flag;
{
    [super setEnabled: flag];
    if (flag) ; // XXX [self startSoundPreview: self]; // need to prohibit at startup
    else [self stopSoundPreview: self];
}

#pragma mark drag feedback

- (void)drawRect:(NSRect)rect;
{
    if (dragAccepted) {
        NSWindow *window = [self window];
        NSRect boundsRect = [self bounds];
        BOOL isFirstResponder = ([window firstResponder] == self);
        // focus ring and drag feedback interfere with one another
        if (isFirstResponder) [window makeFirstResponder: window];
        [super drawRect: rect];
        [[NSColor selectedControlColor] set];
        NSFrameRectWithWidthUsingOperation(NSInsetRect(boundsRect, 2, 2), 3, NSCompositeSourceIn);
        if (isFirstResponder) [window makeFirstResponder: self];
    } else {
        [super drawRect: rect];
    }
}

@end

@implementation NJRMediaPopUpButton (NSDraggingDestination)

- (BOOL)acceptsDragFrom:(id <NSDraggingInfo>)sender;
{
    NSURL *url = [NSURL URLFromPasteboard: [sender draggingPasteboard]];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;

    if (url == nil || ![url isFileURL]) return NO;

    if (![fm fileExistsAtPath: [url path] isDirectory: &isDir]) return NO;

    if (isDir) return NO;
    
    return YES;
}

- (NSString *)_descriptionForDraggingInfo:(id <NSDraggingInfo>)sender;
{
    NSDragOperation mask = [sender draggingSourceOperationMask];
    NSMutableString *s = [NSMutableString stringWithFormat: @"Drag seq %ld source: %@",
        (long)[sender draggingSequenceNumber], [sender draggingSource]];
    NSPasteboard *draggingPasteboard = [sender draggingPasteboard];
    NSArray *types = [draggingPasteboard types];
    NSEnumerator *e = [types objectEnumerator];
    NSString *type;
    [s appendString: @"\nDrag operations:"];
    if (mask & NSDragOperationCopy) [s appendString: @" copy"];
    if (mask & NSDragOperationLink) [s appendString: @" link"];
    if (mask & NSDragOperationGeneric) [s appendString: @" generic"];
    if (mask & NSDragOperationPrivate) [s appendString: @" private"];
    if (mask & NSDragOperationMove) [s appendString: @" move"];
    if (mask & NSDragOperationDelete) [s appendString: @" delete"];
    if (mask & NSDragOperationEvery) [s appendString: @" every"];
    [s appendFormat: @"\nImage: %@ at %@", [sender draggedImage],
        NSStringFromPoint([sender draggedImageLocation])];
    [s appendFormat: @"\nDestination: %@ at %@", [sender draggingDestinationWindow],
        NSStringFromPoint([sender draggingLocation])];
    [s appendFormat: @"\nPasteboard: %@ types:", draggingPasteboard];
    while ( (type = [e nextObject]) != nil) {
        if ([type hasPrefix: @"CorePasteboardFlavorType 0x"]) {
            const char *osTypeHex = [[type substringFromIndex: [type rangeOfString: @"0x" options: NSBackwardsSearch].location] UTF8String];
            OSType osType;
            sscanf(osTypeHex, "%lx", &osType);
            [s appendFormat: @" '%4s'", (char *)&osType];
        } else {
            [s appendFormat: @" '%@'", type];
        }
    }
    return s;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
{
    if ([self acceptsDragFrom: sender] && [sender draggingSourceOperationMask] &
        (NSDragOperationCopy | NSDragOperationLink)) {
        dragAccepted = YES;
        [self setNeedsDisplay: YES];
        // NSLog(@"draggingEntered accept:\n%@", [self _descriptionForDraggingInfo: sender]);
        return NSDragOperationLink;
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender;
{
    dragAccepted = NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;
{
    dragAccepted = NO;
    [self setNeedsDisplay: YES];
    return [self acceptsDragFrom: sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
    if ([sender draggingSource] != self) {
        NSURL *url = [NSURL URLFromPasteboard: [sender draggingPasteboard]];
        if (url == nil) return NO;
        [self _setPath: [url path]];
        if ([self _validateWithPreview: YES]) {
            [self selectItem: [self _itemForAlias: selectedAlias]];
        }
    }
    return YES;
}

@end