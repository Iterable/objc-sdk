//
//  IterableConstants.h
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/9/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

@interface IterableConstants : NSObject

//API Fields
extern NSString *const ITBL_KEY_API_KEY;
extern NSString *const ITBL_KEY_APPLICATION_NAME;
extern NSString *const ITBL_KEY_CAMPAIGN_ID;
extern NSString *const ITBL_KEY_COUNT;
extern NSString *const ITBL_KEY_CURRENT_EMAIL;
extern NSString *const ITBL_KEY_DATA_FIELDS;
extern NSString *const ITBL_KEY_DEVICE;
extern NSString *const ITBL_KEY_EMAIL;
extern NSString *const ITBL_KEY_EMAIL_LIST_IDS;
extern NSString *const ITBL_KEY_EVENT_NAME;
extern NSString *const ITBL_KEY_ITEMS;
extern NSString *const ITBL_KEY_MERGE_NESTED;
extern NSString *const ITBL_KEY_MESSAGE_ID;
extern NSString *const ITBL_KEY_NEW_EMAIL;
extern NSString *const ITBL_KEY_PLATFORM;
extern NSString *const ITBL_KEY_RECIPIENT_EMAIL;
extern NSString *const ITBL_KEY_SDK_VERSION;
extern NSString *const ITBL_KEY_SEND_AT;
extern NSString *const ITBL_KEY_TOKEN;
extern NSString *const ITBL_KEY_TEMPLATE_ID;
extern NSString *const ITBL_KEY_TOTAL;
extern NSString *const ITBL_KEY_UNSUB_CHANNEL;
extern NSString *const ITBL_KEY_UNSUB_MESSAGE;
extern NSString *const ITBL_KEY_USER;
extern NSString *const ITBL_KEY_USER_ID;

//Decvice Dictionary
extern NSString *const ITBL_DEVICE_LOCALIZED_MODEL;
extern NSString *const ITBL_DEVICE_ID_VENDOR;
extern NSString *const ITBL_DEVICE_MODEL;
extern NSString *const ITBL_DEVICE_SYSTEM_NAME;
extern NSString *const ITBL_DEVICE_SYSTEM_VERSION;
extern NSString *const ITBL_DEVICE_USER_INTERFACE;

@end

//API Endpoint Key Constants
#define ENDPOINT_COMMERCE_TRACK_PURCHASE @"commerce/trackPurchase"
#define ENDPOINT_DISABLE_DEVICE @"users/disableDevice"
#define ENDPOINT_GET_INAPP_MESSAGES @"inApp/getMessages"
#define ENDPOINT_INAPP_CONSUME @"events/inAppConsume"
#define ENDPOINT_PUSH_TARGET @"push/target"
#define ENDPOINT_REGISTER_DEVICE_TOKEN @"users/registerDeviceToken"
#define ENDPOINT_TRACK @"events/track"
#define ENDPOINT_TRACK_INAPP_CLICK @"events/trackInAppClick"
#define ENDPOINT_TRACK_INAPP_OPEN @"events/trackInAppOpen"
#define ENDPOINT_TRACK_PUSH_OPEN @"events/trackPushOpen"
#define ENDPOINT_UPDATE_USER @"users/update"
#define ENDPOINT_UPDATE_EMAIL @"users/updateEmail"
#define ENDPOINT_UPDATE_SUBSCRIPTIONS @"users/updateSubscriptions"

//MISC
#define ITBL_KEY_GET @"GET"
#define ITBL_KEY_POST @"POST"

#define ITBL_KEY_APNS @"APNS"
#define ITBL_KEY_APNS_SANDBOX @"APNS_SANDBOX"
#define ITBL_KEY_PAD @"Pad"
#define ITBL_KEY_PHONE @"Phone"
#define ITBL_KEY_UNSPECIFIED @"Unspecified"

#define ITBL_PLATFORM_IOS @"iOS"


#define ITBL_DEEPLINK_IDENTIFIER @"/a/[a-zA-Z0-9]+"


//In-App Constants
#define ITERABLE_IN_APP_CLICK_URL @"urlClick"

#define ITERABLE_IN_APP_TITLE @"title"
#define ITERABLE_IN_APP_BODY @"body"
#define ITERABLE_IN_APP_IMAGE @"mainImage"
#define ITERABLE_IN_APP_BUTTON_INDEX @"buttonIndex"
#define ITERABLE_IN_APP_BUTTONS @"buttons"
#define ITERABLE_IN_APP_MESSAGE @"inAppMessages"

#define ITERABLE_IN_APP_TYPE @"displayType"
#define ITERABLE_IN_APP_TYPE_TOP @"TOP"
#define ITERABLE_IN_APP_TYPE_BOTTOM @"BOTTOM"
#define ITERABLE_IN_APP_TYPE_CENTER @"MIDDLE"
#define ITERABLE_IN_APP_TYPE_FULL @"FULL"
#define ITERABLE_IN_APP_TEXT @"text"
#define ITERABLE_IN_APP_TEXT_FONT @"font"
#define ITERABLE_IN_APP_TEXT_COLOR @"color"

#define ITERABLE_IN_APP_BACKGROUND_COLOR @"backgroundColor"
#define ITERABLE_IN_APP_BUTTON_ACTION @"action"
#define ITERABLE_IN_APP_CONTENT @"content"

//In-App HTML Constants
#define ITERABLE_IN_APP_BACKGROUND_ALPHA @"backgroundAlpha"
#define ITERABLE_IN_APP_HTML @"html"
#define ITERABLE_IN_APP_HREF @"href"
#define ITERABLE_IN_APP_DISPLAY_SETTINGS @"inAppDisplaySettings"


typedef void (^ITEActionBlock)(NSString *);
