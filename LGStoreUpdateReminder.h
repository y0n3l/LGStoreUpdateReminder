//
//  LGUpdateReminder.h
//
//  Created by y0n3l on 10/10/12.
//
//

#import <Foundation/Foundation.h>

@interface LGStoreUpdateReminder : NSObject {
    NSInteger applicationStoreAppleId;
    NSString* applicationStoreName;
    NSString* ignoredVersion;
    NSMutableData* iTunesLookupData;
    NSString* appstoreVersionNumber;
}

@property (readwrite) NSInteger applicationStoreAppleId;
@property (readwrite, retain) NSString* applicationStoreName;

-(void) checkForAvailableUpdateOnAppStore;

@end
