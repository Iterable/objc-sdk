
#import "ITBNotificationServiceExtension.h"

@interface ITBNotificationServiceExtension ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation ITBNotificationServiceExtension

volatile int displayElements;
volatile int count;

UNNotificationCategory* messageCategory;

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    //IMPORTANT: need to add this to the documentation
    self.bestAttemptContent.categoryIdentifier = [self getCategory:request.content];

    NSDictionary *itblDictionary = [request.content.userInfo objectForKey:@"itbl"];
    BOOL contentHandlerCalled = NO;
    contentHandlerCalled = [self loadAttachment:itblDictionary];
    
    if (!contentHandlerCalled) {
        contentHandler(self.bestAttemptContent);
    }
}

//Load attachment
- (BOOL)loadAttachment:(NSDictionary *) itblDictionary {
    NSString *attachmentUrlString = [itblDictionary objectForKey:@"attachment-url"];

    if (![attachmentUrlString isKindOfClass:[NSString class]])
        return NO;

    NSURL *url = [NSURL URLWithString:attachmentUrlString];
    if (url) {
        [[[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString *tempDict = NSTemporaryDirectory();
                NSString *attachmentID = [[[NSUUID UUID] UUIDString] stringByAppendingString:[response.URL.absoluteString lastPathComponent]];

                if(response.suggestedFilename)
                    attachmentID = [[[NSUUID UUID] UUIDString] stringByAppendingString:response.suggestedFilename];

                NSString *tempFilePath = [tempDict stringByAppendingPathComponent:attachmentID];

                if ([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:tempFilePath error:&error]) {
                    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:attachmentID URL:[NSURL fileURLWithPath:tempFilePath] options:nil error:&error];
                    if (attachment) {
                        self->_bestAttemptContent.attachments = [self->_bestAttemptContent.attachments arrayByAddingObject:attachment];
                    }

                }
            }
            count++;
            //NSLog(@"url: %@",currentUrl);
            if (count >= displayElements) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.contentHandler(self.bestAttemptContent);
                }];
            }

        }] resume];
        
        return YES;
    }

    return NO;
}

- (NSString *)getCategory:(UNNotificationContent *) content {
    NSString *category = content.categoryIdentifier;
    if (!content.categoryIdentifier.length) {
        NSDictionary *itblDictionary = content.userInfo[@"itbl"];
        NSString *messageId = itblDictionary[@"messageId"];
        NSArray *actionButtons = itblDictionary[@"actionButtons"];

        if (!actionButtons) {
            actionButtons = content.userInfo[@"actionButtons"];
        }

        if (actionButtons != nil) {
            NSMutableArray *notificationActionList = [NSMutableArray array];
            for (NSDictionary *actionButton in actionButtons) {
                UNNotificationAction *notificationAction = [self createNotificationActionButton:actionButton];
                [notificationActionList addObject:notificationAction];
            }

            messageCategory = [UNNotificationCategory
                    categoryWithIdentifier:messageId
                                   actions:notificationActionList
                         intentIdentifiers:@[]
                                   options:UNNotificationCategoryOptionNone];

            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
                NSSet<UNNotificationCategory *> * expandedCategories = [categories setByAddingObject:messageCategory];
                [center setNotificationCategories:expandedCategories];
            }];
        }
        category = messageId;
    }

    return category;
}

- (UNNotificationAction *)createNotificationActionButton:(NSDictionary *)buttonDictionary {
    NSString *identifier = buttonDictionary[@"identifier"];
    NSString *title = buttonDictionary[@"title"];
    BOOL destructive = [buttonDictionary[@"destructive"] boolValue];
    BOOL requiresUnlock = [buttonDictionary[@"requiresUnlock"] boolValue];
    NSDictionary *action = buttonDictionary[@"action"];

    //NSDictionary *action = actionButton[@"action"];
    UNNotificationActionOptions actionOptions = UNNotificationActionOptionNone;
    if (destructive) {
        actionOptions |= UNNotificationActionOptionDestructive;
    }
    
    if (![action[@"dismiss"] isEqualToString:@""])
    
    
    if (requiresUnlock) {
        actionOptions |= UNNotificationActionOptionAuthenticationRequired;
    }
    //if ([action[@"type"] isEqualToString:@""])


    return [UNNotificationAction
            actionWithIdentifier:identifier
                           title:title
                         options:actionOptions];
}


- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

- (void)contentComplete {
    self.contentHandler(self.bestAttemptContent);
}

@end
