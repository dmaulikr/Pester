//
//  NSDictionary-NJRExtensions.m
//  Pester
//
//  Created by Nicholas Riley on Tue Nov 19 2002.
//  Copyright (c) 2002 Nicholas Riley. All rights reserved.
//

#import "NSDictionary-NJRExtensions.h"


@implementation NSDictionary (NJRExtensions)

- (id)objectForRequiredKey:(NSString *)key;
{
    id obj = [self objectForKey: key];
    NSAssert1(obj != nil, @"Dictionary does not contain object for required key �%@�", key);
    return obj;
}

@end
