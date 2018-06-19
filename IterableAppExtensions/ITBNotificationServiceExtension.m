
#import "ITBNotificationServiceExtension.h"
#import "IterableConstants.h"

NSString *const IterableButtonTypeDefault      = @"default";
NSString *const IterableButtonTypeDestructive  = @"destructive";
NSString *const IterableButtonTypeTextInput    = @"textInput";

@interface ITBNotificationServiceExtension ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation ITBNotificationServiceExtension

UNNotificationCategory* messageCategory;

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = (UNMutableNotificationContent *) [request.content mutableCopy];

    //IMPORTANT: need to add this to the documentation
    self.bestAttemptContent.categoryIdentifier = [self getCategory:request.content];

    NSDictionary *itblDictionary = request.content.userInfo[ITBL_PAYLOAD_METADATA];
    BOOL contentHandlerCalled = NO;
    contentHandlerCalled = [self loadAttachment:itblDictionary];
    
    if (!contentHandlerCalled) {
        contentHandler(self.bestAttemptContent);
    }
}

//Load attachment
- (BOOL)loadAttachment:(NSDictionary *) itblDictionary {
    NSString *attachmentUrlString = itblDictionary[ITBL_PAYLOAD_ATTACHMENT_URL];

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
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.contentHandler(self.bestAttemptContent);
            }];
            
        }] resume];
        
        return YES;
    }

    return NO;
}

- (NSString *)getCategory:(UNNotificationContent *) content {
    NSString *category = content.categoryIdentifier;
    if (!content.categoryIdentifier.length) {
        NSDictionary *itblDictionary = content.userInfo[ITBL_PAYLOAD_METADATA];
        NSString *messageId = itblDictionary[ITBL_PAYLOAD_MESSAGE_ID];
        NSArray *actionButtons = itblDictionary[ITBL_PAYLOAD_ACTION_BUTTONS];

#ifdef DEBUG
        if (!actionButtons) {
            actionButtons = content.userInfo[ITBL_PAYLOAD_ACTION_BUTTONS];
        }
#endif

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
    NSString *identifier = buttonDictionary[ITBL_BUTTON_IDENTIFIER];
    NSString *title = buttonDictionary[ITBL_BUTTON_TITLE];
    NSString *buttonType = buttonDictionary[ITBL_BUTTON_TYPE];
    if (!buttonType || (![buttonType isEqualToString:IterableButtonTypeTextInput] &&
                        ![buttonType isEqualToString:IterableButtonTypeDestructive])) {
        buttonType = IterableButtonTypeDefault;
    }
    BOOL openApp = YES;
    if (buttonDictionary[ITBL_BUTTON_OPEN_APP]) {
        openApp = [buttonDictionary[ITBL_BUTTON_OPEN_APP] boolValue];
    }
    BOOL requiresUnlock = [buttonDictionary[ITBL_BUTTON_REQUIRES_UNLOCK] boolValue];

    UNNotificationActionOptions actionOptions = UNNotificationActionOptionNone;
    if ([buttonType isEqualToString:IterableButtonTypeDestructive]) {
        actionOptions |= UNNotificationActionOptionDestructive;
    }
    
    if (openApp) {
        actionOptions |= UNNotificationActionOptionForeground;
    }
    
    if (requiresUnlock || openApp) {
        actionOptions |= UNNotificationActionOptionAuthenticationRequired;
    }
    
    if ([buttonType isEqualToString:IterableButtonTypeTextInput]) {
        NSString *inputTitle = buttonDictionary[ITBL_BUTTON_INPUT_TITLE];
        NSString *inputPlaceholder = buttonDictionary[ITBL_BUTTON_INPUT_PLACEHOLDER];
        
        return  [UNTextInputNotificationAction
                 actionWithIdentifier:identifier
                 title:title
                 options:actionOptions
                 textInputButtonTitle:inputTitle
                 textInputPlaceholder:inputPlaceholder];
    }
    else {
        return [UNNotificationAction
                actionWithIdentifier:identifier
                title:title
                options:actionOptions];
    }
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

@end
