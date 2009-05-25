//
//  NSWindowCollectionBehavior.h
//  Pester
//
//  Created by Nicholas Riley on 12/8/07.
//  Copyright 2007 Nicholas Riley. All rights reserved.
//

#import <AppKit/AppKit.h>

enum {
    NSWindowCollectionBehaviorDefault = 0,
    NSWindowCollectionBehaviorCanJoinAllSpaces = 1 << 0,
    NSWindowCollectionBehaviorMoveToActiveSpace = 1 << 1
};
typedef unsigned NSWindowCollectionBehavior;

@interface NSWindow (NSWindowCollectionBehavior)
- (void)setCollectionBehavior:(NSWindowCollectionBehavior)behavior;
@end
