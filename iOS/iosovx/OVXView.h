/*
*
* Package Name		: OVXSDK
* File Name         : OVXView.h
* Version Name		: 2.2.0
* Date    			: 20140510
* Description		: Copyright (c) 2012 OpenClove. All rights reserved.
*
*
*/


#import <UIKit/UIKit.h>

@protocol OVXDelegate;
@interface OVXView : UIView <UIWebViewDelegate>
{

//DEPRECATED  PARAMS
//*******************
    
    
    //CONFIG PARAMS -  NEED TO BE SET ONLY ONCE IN THE APP

    NSString *title;
    NSString *API_KEY;
    NSString *API_SECRET;
    
      
    NSString *userId;
    NSString *userName;
    NSString *userLocation;
    NSString *groupId;
    NSString *roomName;
    NSString *roomDescription;
    NSString *mood;
    bool voiceProfile;
   
    
// USED BY SDK AND APP
//*********************

    NSString *screenId;
    NSString *sessionId;
    NSString *layerId;
    NSString *asiUrl;

  
    UIViewController* mainController;
    
}


@property (nonatomic, assign) id<OVXDelegate> delegate;

//DEPRECATED  PARAMS
//*******************

@property (nonatomic, assign) BOOL debug;

    //CONFIG PARAMS

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *API_KEY;
@property (retain, nonatomic) NSString *API_SECRET;

//CALL PARAMS
@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *userLocation;
@property (retain, nonatomic) NSString *groupId;
@property (retain, nonatomic) NSString *roomName;
@property (retain, nonatomic) NSString *mood;
@property (retain, nonatomic) NSString *roomDescription;

@property (nonatomic, assign) BOOL showOVXMenuOnTap;
@property (nonatomic, assign) BOOL enableUserInteraction;
@property (nonatomic, assign) BOOL autoHideOnCallEnd;
@property (nonatomic, assign) BOOL useDataChannel;
@property (nonatomic, assign) BOOL voiceProfile;

//END OF DEPRECATED  PARAMS
//**************************


// USED BY SDK AND APP
//*********************

@property (retain, nonatomic) NSString *screenId;
@property (retain, nonatomic) NSString *sessionId;
@property (retain, nonatomic) NSString *layerId;
@property (retain, nonatomic) NSString *asiUrl;





//FUNCTIONS
+ (id)sharedInstance;
-(void)call;
-(void)exitCall;
-(bool)isCallOn;
-(void)showOVXMenu;
-(void)switchLayer:(NSString *)targetLayer;
-(void) modifyLayout:(NSString *)layout :(NSString*)layerSequence;
-(void)updateVideoOrientation;
-(void)switchCamera;
-(void)ovxAudioMute:(BOOL)mute; // if mute=TRUE, then Mute, else UnMute
-(void)ovxVideoMute:(BOOL)mute; // if mute=TRUE, then Mute, else UnMute
-(void)ovxVideoPause:(BOOL)pause; // if pause=TRUE, then Pause, else Resume
-(void)sendData:(NSString*)msg ofType:(NSString*)type;
-(void)showLoadingView;
-(void)hideLoadingView;
-(UIView*)getLocalCameraView;
-(UIView*)getRemoteView:(NSInteger)id;
-(void)setLayerDisplay:(NSInteger) display withLayer: (NSInteger) layer;
-(void)hideLayerDisplay:(NSInteger) display;
-(void)setActiveCalls:(NSInteger)calls;
-(int)getActiveCalls;
-(void)setLatencyLevel:(float)latency;

-(void)resizeLocalCameraView;

-(BOOL) addOtherUsertoGroupChat: (NSString *)callType :(NSString*)serviceType :(NSString*)otherUserId;
-(BOOL) removeOtherUserFromGroupChat:(NSString*)otherUserId;
-(BOOL) startDirectCall :(NSString *)dialUrl;



//new api
/*  Following OVX parameters can be set using this function:
 
        Key                             Parameter                                    Example
    1. ovx-title                    Title of app                        [ovxView setKeyValue:@"ovx-title" :@"OVX Example" ];
    2. ovx-apiKey                   API Key of application              [ovxView setKeyValue:@"ovx-apiKey" :@"Api Key String" ];
    3. ovx-apiSecret                API secret of application           [ovxView setKeyValue:@"ovx-apiSecret" :@"Api Key Secret" ];
                                                                        // if not provided, takes default value
    4. ovx-userId                   User ID                             [ovxView setKeyValue:@"ovx-userId" :( NSString*)CFUUIDCreateString(NULL, theUuid) ];
    5. ovx-name                     user name                           [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];
    6. ovx-session                  Group Id                            [ovxView setKeyValue:@"ovx-session" :@"abc123" ];
    7. ovx-mood                     mood id  (@"1", @"2", @"3")         [ovxView setKeyValue:@"ovx-mood" :@"1"];
    8. ovx-width                    width of video view                 [ovxView setKeyValue:@"ovx-width" :@"320" ];
    9. ovx-height                   height of video view                [ovxView setKeyValue:@"ovx-height" :@"240" ];
    10. ovx-type                     "video" / "voice"                   [ovxView setKeyValue:@"ovx-type" :@"video" ];
    11. ovx-chat                    "enable" / "disable"                [ovxView setKeyValue:@"ovx-chat" :@"enable" ];
    12. ovx-record                  "enable" / "disable"                [ovxView setKeyValue:@"ovx-record" :@"enable" ];
    13. ovx-debug                   "enable"/ "disable"                [ovxView setKeyValue:@"ovx-debug" :@"enable" ];
    14. ovx-enableUserInteraction   "enable"/ "disable"                [ovxView setKeyValue:@"ovx-enableUserInteraction" :@"enable" ];
    15. ovx-autoHideOnCallEnd       "enable"/ "disable                 [ovxView setKeyValue:@"ovx-autoHideOnCallEnd" :@"enable" ];
    16. ovx-showOvxMenuOnTap"       "enable"/ "disable"                [ovxView setKeyValue:@"ovx-showOVXMenuOnTap" :@"enable" ];
 
 */


-(void) setKeyValue: (NSString *)parameter :(NSString*)value;

-(void) launch;
-(void)ovxVideoRecord:(BOOL)record;
-(NSString *) getRecordedFile;
-(void) showSplitView;
-(void) showCompositeView;
//end of new api


- (int) ovxView_OPXconnect;
- (id) ovxView_OPXSocket;
- (int) ovxView_sendOPXMessage:(NSString*) msgString;


@end



@protocol OVXDelegate
-(void)ovxCallInitiated;
-(void)ovxCallStarted;
-(void)ovxCallTerminated:(NSString *)message;
-(void)ovxCallEnded;
-(void)ovxCallFailed:(NSString *)message;
-(void)ovxReceivedData:(NSString*)data;
-(void)ovxReceivedEvent:(NSString*)event;


- (void) ovxView_didReceiveOPXMessage:(NSDictionary *)rxMessage;
- (void) ovxView_didFailOPXWithError:(NSError *)error;
- (void) ovxView_didCloseOPXWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void) ovxView_didConnectOPX;
- (void) ovxView_didOpenOPX;


@end


/* Deprecated parameters
 
 NSString *BASE_URL;
 NSString *SDK_HANDLER;
 NSString *videoCodec;
 NSString *audioCodec;
 bool webRtcProfile;
 bool useSDKhandler;
 NSString *asiUrl;
 NSString *roomName;
 NSString *roomDescription;
 
 */

/* Depracated Usage 
 
 Following usage is deprecated. Application to call setKeyValue() instead.
    ovxView.title
    ovxView.API_KEY
    ovxView.userId
    ovxView.userName
    ovxView.groupId
    ovxView.mood
    ovxView.showOVXMenuOnTap
    ovxView.enableUserInteraction
    ovxView.autoHideOnCallEnd
 
 */

