//
//  LGUpdateReminder.m
//
//  Created by y0n3l on 10/10/12.
//
//

#import "LGStoreUpdateReminder.h"
#import <Foundation/Foundation.h>


#define kIgnoredVersionKey @"kIgnoredVersionKey"

@interface LGStoreUpdateReminder (internal)
-(NSString*) bundleVersion;
-(NSString*) ignoredVersion;
-(void) setIgnoredVersion:(NSString*)ignoredVersionValue;
@end

@implementation LGStoreUpdateReminder

@synthesize applicationStoreAppleId = _applicationStoreAppleId;
@synthesize applicationStoreName = _applicationStoreName;

-(void) dealloc {
    [_applicationStoreName release];
    _applicationStoreName = nil;
    [ignoredVersion release];
    ignoredVersion = nil;
    [iTunesLookupData release];
    iTunesLookupData = nil;
    [appstoreVersionNumber release];
    appstoreVersionNumber = nil;
    [super dealloc];
}

-(NSString*) bundleVersion {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

-(NSString*) ignoredVersion {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kIgnoredVersionKey];
}

-(void) setIgnoredVersion:(NSString*)ignoredVersionValue {
	[[NSUserDefaults standardUserDefaults] setObject:ignoredVersionValue forKey:kIgnoredVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) checkForAvailableUpdateOnAppStore {
    NSAssert(_applicationStoreAppleId!=0 || _applicationStoreName==nil, @"You must set the applicationAppleId before checking for update");
    NSString* s = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%ld&country=FR", (long)_applicationStoreAppleId];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:s]];
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    NSLog(@"[APPDELEGATE] check update at %@", s);
    [conn start];
}

-(void) connection:(NSURLConnection*)conn didReceiveData:(NSData *)data {
    if (!iTunesLookupData)
        iTunesLookupData = [[NSMutableData dataWithData:data] retain];
    else
        [iTunesLookupData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection*)conn {
    if (iTunesLookupData) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:iTunesLookupData options:0 error:nil];
        //NSLog(@"app props : %@", json);
        NSArray* results = [json objectForKey:@"results"];
        if ([results count]>0) {
            NSDictionary* r = [results objectAtIndex:0];
            appstoreVersionNumber = [[r objectForKey:@"version"] retain];
            if (appstoreVersionNumber && ![[self bundleVersion] isEqualToString:appstoreVersionNumber]
                && ![[self ignoredVersion] isEqualToString:appstoreVersionNumber] ) {
                // a new version is available, it is not ignored.
                NSString* whatsNew = [r objectForKey:@"releaseNotes"];
                NSString* title = [NSString stringWithFormat:@"Version %@ disponible !", appstoreVersionNumber];
                UIAlertView* newVersionAlert = [[UIAlertView alloc] initWithTitle:title message:whatsNew delegate:self cancelButtonTitle:@"Mettre à jour" otherButtonTitles:@"Ne plus rappeler", @"Rappeler plus tard", nil];
                [newVersionAlert show];
            }
        }
    }
    [iTunesLookupData release];
    iTunesLookupData = nil;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            //update the app => go to the appstore
            NSURL*url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/fr/app/%@/id%ld?mt=8&uo=4", _applicationStoreName, (long)_applicationStoreAppleId]];
            [[UIApplication sharedApplication ]openURL:url];
            [url release];
            break;
        }
        case 1: {
            //No reminder anymore => set the current online version as the ignored one.
            [self setIgnoredVersion:appstoreVersionNumber];
            break;
        }
        case 2:
            break;
        default:
            break;
    }
}

@end
