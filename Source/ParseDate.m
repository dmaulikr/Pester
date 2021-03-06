//
//  ParseDate.m
//  Pester
//
//  Created by Nicholas Riley on 11/28/07.
//  Copyright 2007 Nicholas Riley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseDateInternal.h"

// generated by perl -MExtUtils::Embed -e xsinit -- -o perlxsi.c
#include <EXTERN.h>
#include <perl.h>

EXTERN_C void xs_init (pTHX);

EXTERN_C void boot_DynaLoader (pTHX_ CV* cv);

EXTERN_C void
xs_init(pTHX)
{
    char *file = __FILE__;
    dXSUB_SYS;
    
    /* DynaLoader is a special case */
    newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}
// end generated code

static dispatch_queue_t perl_dispatch_queue;
static NSDateFormatter *dateManipFormatter;
static NSDictionary *localeLanguageCodes;

// write only on (serial) queue
static PerlInterpreter *my_perl;
static BOOL parser_OK = NO;

NSDate *parse_natural_language_date_on_queue(NSString *input) {
    if (!parser_OK) // duplication intentional
        return [NSDate distantPast];

    if (input == nil)
	return nil;

    if ([input rangeOfString: @"|"].length > 0) {
	NSMutableString *sanitized = [[input mutableCopy] autorelease];
	[sanitized replaceOccurrencesOfString: @"|" withString: @""
				      options: NSLiteralSearch
					range: NSMakeRange(0, [sanitized length])];
	input = sanitized;
    }
    
    NSString *temp = [[NSString alloc] initWithFormat: @"my $s = eval {UnixDate(q|%@|, '%%q')}; warn $@ if $@; $s", input];
    // NSLog(@"%@", input);
    SV *d = eval_pv([temp UTF8String], FALSE);
    [temp release];
    if (d == NULL) return nil;
    
    STRLEN s_len;
    char *s = SvPV(d, s_len);
    if (s == NULL || s_len == 0) return nil;
    
    NSDate *date = [dateManipFormatter dateFromString: [NSString stringWithUTF8String: s]];
    // NSLog(@"%@", date);
    
    return date;
}

NSDate *parse_natural_language_date(NSString *input) {
    if (!parser_OK)
        return [NSDate distantPast];
    
    __block NSDate *date;

    dispatch_sync(perl_dispatch_queue, ^{
        date = parse_natural_language_date_on_queue(input);
    });

    return date;
}

BOOL init_perl_on_queue(NSString *moduleSearchPath) {
    const char *argv[] = {"", "-CSD", "-I", "", "-MDate::Manip", "-e", "0"};
    if (moduleSearchPath == nil)
        moduleSearchPath = [[NSBundle mainBundle] resourcePath];
    argv[3] = [moduleSearchPath fileSystemRepresentation];
    int no_argc = 0;
    char **no_argv = 0;
    PERL_SYS_INIT(&no_argc, &no_argv);
    my_perl = perl_alloc();
    if (my_perl == NULL) return NO;

    perl_construct(my_perl);
    if (perl_parse(my_perl, xs_init, 7, (char **)argv, NULL) != 0) goto fail;

    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
    if (perl_run(my_perl) != 0) goto fail;

    return YES;

fail:
    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();
    my_perl = NULL;

    return NO;
}

NSArray *date_parser_supported_locale_language_codes(void) {
    return localeLanguageCodes.allKeys;
}

void init_date_parser_on_queue(NSString *localeLanguageCode) {
    if (my_perl == NULL) {
        static BOOL perl_init_failed = NO;

        if (perl_init_failed || (perl_init_failed = !init_perl_on_queue(nil)))
            return;
    }

    parser_OK = NO;

    if (localeLanguageCode == nil)
        localeLanguageCode = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];

    const char *language = [localeLanguageCodes[localeLanguageCode] UTF8String];
    if (language == NULL)
        return;

    // Date::Manip uses "US" to mean month/day and "non-US" to mean day/month.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle: NSDateFormatterShortStyle];
    BOOL isUS = [[dateFormatter dateFormat] characterAtIndex: 0] == 'M';
    [dateFormatter release];

    int gmtOffsetMinutes = (int)([[NSTimeZone defaultTimeZone] secondsFromGMT]) / 60;
    NSString *temp = [[NSString alloc] initWithFormat:
	  @"Date_Init(\"Language=%s\", \"DateFormat=%s\", \"Printable=1\", \"SetDate=now,%c%02d:%02d\")",
	  language, isUS ? "US" : "non-US",
	  gmtOffsetMinutes < 0 ? '-' : '+', abs(gmtOffsetMinutes) / 60, abs(gmtOffsetMinutes) % 60];
    SV *d = eval_pv([temp UTF8String], FALSE);
    [temp release];
    if (d == NULL) return;

    if (parse_natural_language_date_on_queue(@"20100322t134821") == nil) return;

    parser_OK = YES;
}

void init_date_parser_async(void (^completion_block)(void)) {
    dispatch_async(perl_dispatch_queue, ^{
        init_date_parser_on_queue(nil);
        if (completion_block != NULL)
            dispatch_async(dispatch_get_main_queue(), completion_block);
    });
}

// note: the documentation is misleading here, and this works.
// <http://gcc.gnu.org/ml/gcc-patches/2004-06/msg00385.html>
void initialize(void) __attribute__((constructor));

void initialize(void) {
    dateManipFormatter = [[NSDateFormatter alloc] init];
    [dateManipFormatter setDateFormat: @"yyyyMMddHHmmss"]; // Date::Manip's "%q"

    localeLanguageCodes = [@{
        @"ca": @"Catalan", // weekdays OK
        @"da": @"Danish", // weekdays OK
        @"de": @"German", // OK
        @"en": @"English", // OK
        @"es": @"Spanish", // XXX la siguiente semana / el mes siguiente
        @"fi": @"Finnish", // weekdays OK with patch
        @"fr": @"French", // OK with patch
        @"it": @"Italian", // XXX tra 2 giorni and quite a bit more
        @"nb": @"Norwegian", // weekdays OK
        @"nl": @"Dutch", // OK
        @"pl": @"Polish", // weekdays OK
        @"pt": @"Portuguese", // weekdays OK with patch
        @"ro": @"Romanian", // weekdays OK
        @"ru": @"Russian", // weekdays OK
        @"sv": @"Swedish", // OK with patch
        @"tr": @"Turkish" // weekdays OK with patch
    } retain];
    perl_dispatch_queue = dispatch_queue_create("ParseDate", DISPATCH_QUEUE_SERIAL);
}