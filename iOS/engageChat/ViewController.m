
/*
 *
 * Package Name		: engageChat
 * File Name		: ViewController.m
 * Version Name		: 1.3.1
 * Date    			: 20140506
 * Description		: Copyright (c) 2012 OpenClove. All rights reserved.
 *
 *
 */

#import "ViewController.h"
#import "ovxView.h"



@interface ViewController ()

@end

@implementation ViewController

@synthesize logview;
@synthesize username;
@synthesize peerUsername;
@synthesize ovxSessId;
@synthesize usernameField, peernameField, displaynameField;
@synthesize actionButton, endCallButton, inviteButton, inviteFriendButton;
        
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];


	// Do any additional setup after loading the view, typically from a nib.
    
    /* Initiate OpenClove Video Exchange Service -- ovxView */
    
    ovxView = [OVXView sharedInstance];
    ovxView.delegate = self;
    [self configureOVXPlayer];

    
    /* Add the ovxView to the current View, and keep it Hidden */
    [self.view addSubview:ovxView];
    ovxView.hidden = TRUE;
    
    /* Default audio/video mute is FALSE */
    audiomute = FALSE;
    videomute = FALSE;
    msgTimer = nil;
    inviteRecvdTimer = nil;
    inviteSentTimer = nil;
    
    startcall=FALSE;
    endcall=FALSE;

    
    
}


- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"engageChat did become active notification");
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    NSLog(@"engageChat did enter foreground notification");
}

-(void) opxInitiateRegister
{
    /* Get Username from stored Default */
    username = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"];
    
    if((username == nil) || (username.length<3))
    {
        if (usernameField.text)
            username = [[NSString alloc] initWithString:usernameField.text];
        else
            username = @"";
        
    }
    else
        usernameField.text = username;
    
    /* Connect to the OpenClove Peer Exchange Service to Register */
    
    if([ovxView ovxView_OPXSocket])
        [self sendOpxRegister];
    else
        [ovxView ovxView_OPXconnect];
}

-(void) configureOVXPlayer
{
    //menu title
    
    
    [ovxView setKeyValue:@"ovx-title" :@"Engage Chat" ];
    
    [ovxView setKeyValue:@"ovx-apiKey" :@"jmbyzaurgsq2qfqgyrt6ct8m" ];
    [ovxView setKeyValue:@"ovx-maxParticipants" :@"2"];
    
    /*Now we will assign a User ID and Name. In this example, we allocate a unique ID for this App and Device, and pick the IOS Device Name as the User Name.  The User ID and User Name can be entirely whatever your Application provides.  The User ID MUST be unique across all your applications using the same API_KEY  */
    
    CFUUIDRef theUuid = CFUUIDCreate(NULL);
    ovxView.userId = ( NSString*)CFUUIDCreateString(NULL, theUuid);
    [ovxView setKeyValue:@"ovx-userId" :( NSString*)CFUUIDCreateString(NULL, theUuid)];
    
  
    [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];
    
    
    /* Group ID is associated with the common live video room.  All calls placed with the same Group ID originating from the same API_KEY will be part of the same Video room.  For example, you could have one group ID for your entire Application, so all users using the same Application when they join Live Board, they will be in the same video room.  Another example, could be where each Section of a Book can be a different Group ID, and hence creating a separate room for each Section of the Book.
     
     You could also apply your own logic to create private rooms, and other contextual rooms by assigning a unique Group ID and sharing it with appropriate Users and contexts.
     
     */
    
    NSString *grpId = [self generateNonce];
    grpId = [grpId stringByReplacingOccurrencesOfString:@"=" withString:@""];
    grpId = [grpId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    grpId = [grpId stringByReplacingOccurrencesOfString:@"/" withString:@""];
    grpId = [grpId stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    grpId= [grpId lowercaseString]; // Here we will use a single group ID for the entire demo App
    ovxSessId = [[NSString alloc] initWithString:grpId];
    
    [ovxView setKeyValue:@"ovx-session" :grpId ];
    
    // this refers to the Themeing of video frames, background, etc. of the Live Board video room.  Contact support@openclove.com for more details on the Themes available.
    [ovxView setKeyValue:@"ovx-mood" :@"1"];
    
    
    /* Now lets set a default size and location of the Video Window on your device.  This is where the video will first start.  After that you can pinch to re-size, and drag to move it around the Screen. */
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        /* default view size is 640X480. For iphone/ipod you have to resize it to 320X240 */
        
        // ovxView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [ovxView setFrame:CGRectMake(0, 140, 320, 240)];
        [ovxView setKeyValue:@"ovx-width" :@"320" ];  //width of video view
        [ovxView setKeyValue:@"ovx-height" :@"240" ];
        
        
    }else
    {
        [ovxView setFrame:CGRectMake(300, 140, 640, 480)];
        [ovxView setKeyValue:@"ovx-width" :@"640" ];  //width of video view
        [ovxView setKeyValue:@"ovx-height" :@"480" ];
    }
    
    
    
    [ovxView setKeyValue:@"ovx-widget" :@"ovxplayer" ];
    [ovxView setKeyValue:@"ovx-type" :@"video" ];
    
    [ovxView setKeyValue:@"ovx-chat" :@"enable" ];
    [ovxView setKeyValue:@"ovx-record" :@"enable" ];
    [ovxView setKeyValue:@"ovx-dialout" :@"disable" ];
    [ovxView setKeyValue:@"ovx-render" :@"panel" ];
    [ovxView setKeyValue:@"ovx-autostart" :@"false" ];
    
    [ovxView setKeyValue:@"ovx-showOvxMenuOnTap" :@"enable" ];
    [ovxView setKeyValue:@"ovx-autoHideOnCallEnd" :@"enable" ];
    
    [ovxView setKeyValue:@"ovx-debug":@"enable"];
  
    
    [ovxView launch];
    
    [self opxInitiateRegister];
    
}


/* callback function to receive memory warnings from the device */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/* onCallStart method is invoked when "start call" button is clicked. This method checks, if call is on and initiates the call if call is not on. if Call is already on, it returns from the functions  */


- (IBAction) onCallStart: (id)sender
{
    if(!ovxView.isCallOn)
    {
        [ovxView showLoadingView];// SDK method to show loading view
        [ovxView call]; //SDK method to initiate call
    }
}

/* onCallEnd method is invoked when "End Call" button is clicked. This method ends the call if call is on,
 otherwise ignores it.  */

- (IBAction) onCallEndButton: (id)sender
{
    if(ovxView.isCallOn)
        [ovxView exitCall];  // SDK method to end call
}

/* onRecordStart method is invoked when "Record" button is clicked. This method checks, if call is on and records. if Call is not  on, request is ignored  */


- (IBAction) onRecordStart: (id)sender
{
    if(ovxView.isCallOn)
    {
        [ovxView setKeyValue:@"ovx-record" :@"enable" ];
        [ovxView ovxVideoRecord:true];// SDK method to record call
    }
}

/* onRecordStop method is invoked when "Stop" button is clicked. This method checks, if call is on and stops recording. if Call is not  on, request is ignored  */


- (IBAction) onRecordStop: (id)sender
{
    if(ovxView.isCallOn)
    {
        [ovxView ovxVideoRecord:false];// SDK method to stop recording call
    }
}


/* onDownload method retreives recorded file. If recording has not been done, it returns null.  */


- (IBAction) onDownload: (id)sender
{
    NSLog(@"OVX : Download recorded file");
    
    NSString *file = [ovxView getRecordedFile];
    NSLog(@"Recorded File URL :%@", file);
}



/* onAudioMuteToggle is called when 'Audio Mute' button is clicked. This mutes/unmutes audio based on current state of Audio. This operations is performed only if call is active.  */
 
- (IBAction) onAudioMuteToggle: (id)sender
{
    NSLog(@"OVX : Toggling Audio Mute/UnMute");
    
    if(ovxView.isCallOn)
    {
        audiomute = !audiomute;
        [ovxView ovxAudioMute:audiomute];  //SDK method to change the audio mute status
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Start or Join a Call First"
                                                        delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
        [alert show];
     }

    
    /* direct access to mute/unmute Audio */
}



/*  onVideoMuteToggle is called when 'Video Mute' button is clicked. If call is active, video is toggled between Mute (does not send Video) and unMute (sends Video) based on the current status of the video. If call is not active, alert message is displayed to user to start the call. */

- (IBAction) onVideoMuteToggle: (id)sender
{
    NSLog(@"OVX : Toggling Video Mute/UnMute");
    if(ovxView.isCallOn)
    {
        videomute = !videomute;
        [ovxView ovxVideoMute:videomute]; /* SDK method to mute/unmute Video */
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Start or Join a Call First"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    
}


/* onSwitchCamera method is called when 'Camera' button is clicked. This is used to switch between front and back camera when call is active. if call is not active, message  is dsiplayed to user to initiate the call.
 
 */
- (IBAction) onSwitchCamera: (id)sender
{
    NSLog(@"OVX : Switch Camera");
    
    if(ovxView.isCallOn)
    {
        [ovxView switchCamera];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Start or Join a Call First"
                                                        delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
        [alert show];

    }
}


// CallBacks from OVXView

// ovxCallInitiated call back is called from SKD when call is initiated.
-(void)ovxCallInitiated
{
    NSLog(@"OVX : Call Initiated");
}

// ovxCallStarted call back is called from SKD when call is started.

-(void)ovxCallStarted
{
    NSLog(@"OVX : Call Started for Layer %@", ovxView.layerId);

    [ovxView hideLoadingView]; //SDK method to hide loading (rotating ) view image
    [ovxView getLocalCameraView].hidden = false;
    
    endCallButton.hidden = FALSE;
    
    if (endcall==TRUE)
    {
        endcall=FALSE;
        [self onCallEndButton: self];
    }
}


// ovxCallTerminated call back is called from SDK when call is terminated.

-(void)ovxCallTerminated:(NSString *)message
{
    NSLog(@"OVX : Call Terminated");
    
   [logview setText:@""];
   [logview setText:@"Welcome to Openclove"];
    endCallButton.hidden = TRUE;

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ovxView.title
                                                    message:message
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
    [alert show];
    [alert release];
   
}

// ovxCallTerminated call back is called from SDK when call failed
-(void)ovxCallFailed:(NSString *)message
{
    NSLog(@"OVX : Call Failed : %@",message);
    [logview setText:@""];
    [logview setText:@"Welcome to Openclove"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ovxView.title
                                                    message:message
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
    [alert show];
    [alert release];
  
    endCallButton.hidden = TRUE;

    
}
// ovxCallEnded call back is called from SDK when call end action is completed
-(void)ovxCallEnded
{
    NSLog(@"OVX : Call Ended : ");
    [ovxView getLocalCameraView].hidden = true;
    
    endCallButton.hidden = TRUE;
}


// ovxReceivedData call back is called when data is received on Data Channel. SDK sends different types of data on this channel-  info/ control/ participants/chat etc. The data content received is processed here according to type of data. chat view is updated with data received.

-(void)ovxReceivedData:(NSString *)data
{
  NSLog(@"OVX RECEIVED DATA: %@", data);
    
  if([ovxView isCallOn])
  {
    NSDictionary *params=[self parseQueryString:data];
    
    NSString *type = [params objectForKey:@"type"];
    NSString *content = [params objectForKey:@"data"];
    NSString *sender = [params objectForKey:@"sender"];
    
    if([type isEqualToString:@"info"]) // information/notifications for Group Chat
    {
        NSLog(@" Info from %@: %@ :%@", type, sender,  [self urldecode:content]);
        
        [logview setText:[NSString stringWithFormat:@"%@\nInfo -- %@: %@", logview.text,  sender, content]];
        
    }else if ([type isEqualToString:@"control"]) //Control information showing the current status of video View 
    {
        NSLog(@" Control Info %@: %@ :%@", type, sender,  [self urldecode:content]);
        
        [logview setText:[NSString stringWithFormat:@"%@\nControl -- %@: %@", logview.text,  sender, content]];
        
    }else if([type isEqualToString:@"participants"])// informations related participants in Group Chat
    {
        NSLog(@" Participants  %@: %@ :%@", type, sender,  [self urldecode:content]);
        
        [logview setText:[NSString stringWithFormat:@"%@\nParticipants -- %@: %@", logview.text,  sender, content]];
    }
    else if([type isEqualToString:@"chat"]) //chat messages received from other participants 
    {
        NSLog(@" Chat  %@: %@ :%@", type, sender,  [self urldecode:content]);
        
        [logview setText:[NSString stringWithFormat:@"%@\n Chat -- %@: %@", logview.text,  sender, content]];
    }
    else 
    {
        NSLog(@"Live App Data from %@: %@ :%@", sender, type , [self urldecode:content]);
    
        [logview setText:[NSString stringWithFormat:@"%@\n%@ -- %@: %@", logview.text, type, sender, content]];
    }
  }
    
}

-(void)ovxReceivedEvent:(NSString *)event
{
    NSLog(@"OVX RECEIVED event: %@", event);
    NSArray *pairs = [event componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
    
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    
    
    [logview setText:[NSString stringWithFormat:@"%@\n Received Event %@: %@  ", logview.text, dict[@"type"], dict[@"data"]]];

}

//End of Call back functions

// Utility functions

/*
 generateNonce utility function is used to genrate random string. This is used to generate random/unique Group Id
 */
-(NSString*) generateMsgId
{
    NSString *randomStr = [self generateNonce];
    
    randomStr = [randomStr stringByReplacingOccurrencesOfString:@"=" withString:@""];
    randomStr = [randomStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    randomStr = [randomStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
    randomStr = [randomStr stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    randomStr= [randomStr lowercaseString]; // Here we will use a single group ID for the entire demo App
    randomStr = [randomStr substringToIndex:4];
    return  randomStr;
    
}

- (NSString*) generateNonce
{
    NSString* nonce;
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    [NSMakeCollectable(theUUID) autorelease];
    nonce = (NSString *)string;
	
    return nonce;
    
}

/*
 parseQueryString utilty function is used to parse received data on data channel.
 */
- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];// autorelease];
    
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

/* utility function to encode url */
-(NSString *)urlencode:(NSString *)url
{
    NSString *escapedUrl = ( NSString *)CFURLCreateStringByAddingPercentEscapes(     NULL,    (CFStringRef)url,     NULL,    (CFStringRef)@"!*'();:@&=+$,/?%#[]",     kCFStringEncodingUTF8);
    
    return escapedUrl;
}

/* utility function to decode url */

- (NSString *)urldecode:(NSString *)url
{
    NSString *result = [url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

// End of Utility functions
/* portrait orientation for iPhone
   portrait and two landscape modes are supported are supported for iPad.
 */
- (NSUInteger)supportedInterfaceOrientations {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (UIInterfaceOrientationMaskPortrait );
    }
    else
    {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    }
}


/*
 For Iphone - portrait and ipad portrait and two landscape modes in autorotation are supported. 
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
      
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else
        return ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
                (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
                (interfaceOrientation == UIInterfaceOrientationLandscapeRight) );
    

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    UIView *touchedView = [touch view];
    
    if( (touchedView.isUserInteractionEnabled) && (touchedView.tag==1111) )
    {
        
        CGPoint location = [touch locationInView:self.view]; // <--- note self.superview
        touchedView.center = location;
        
    }
	
}



/******BEGIN: APPLICATION USING OPX FUNCTIONS *********/

/* The group id  given by the user is set as the room id of ovx room */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    AudioServicesDisposeSystemSoundID(ringtoneSoundID);
    
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- Invite Request accepted by peer %@", logview.text, peerUsername]];

    if([title isEqualToString:@"Answer"])      // invite request accepted
    {
        [self cancelTimerAndAccept];
        
    }
    else if([title isEqualToString:@"Reject"])      // invite request rejected
    {
        [inviteRecvdTimer invalidate]; inviteRecvdTimer = nil;
        [logview setText:[NSString stringWithFormat:@"%@\nOPX- Invite Request rejected by peer %@", logview.text, peerUsername]];
        [self sendOPXApplicationInviteRejectedMessage];
    }
    
    
}
/* onCallMenu method is invoked when "Call Menu" button is clicked. Call Menu options provided by SDK are displayed.  */

- (IBAction) onActionButton: (id)sender
{

    if([usernameField isFirstResponder]){
        [usernameField resignFirstResponder];
    }
    
        /* Sign in the user to the OPX Service */
        
        if(displaynameField.text.length>0)
            [ovxView setKeyValue:@"ovx-name" : displaynameField.text];
        else
            [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];

        username = [[NSString alloc] initWithString:usernameField.text];
    
        [self sendOpxRegister];


}

- (IBAction) onInviteButton: (id)sender
{
    
    /* Invite Peer ID */
    
    if([peernameField isFirstResponder]){
        [peernameField resignFirstResponder];
    }
    peerUsername = [[NSString alloc] initWithString:peernameField.text];
    
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- Inviting %@", logview.text, peerUsername]];

    
    if(displaynameField.text.length>0)
        [ovxView setKeyValue:@"ovx-name" : displaynameField.text];
    else
        [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];
    
    [self sendOPXApplicationInviteMessage:peerUsername];

    
}

-(void) sendOPXMessageFormat: (NSString *)msg
{
    NSString *fromId = [NSString stringWithFormat:@"myNewAPIKey:%@", username];
    NSString *toId = [NSString stringWithFormat:@"myNewAPIKey:%@", peerUsername];
    
     NSString *msgId = [self generateMsgId];
    
    NSDictionary *opxmsg = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MSG_REQUEST", @"msgtype",
                            fromId, @"fromid",
                            toId, @"toid",
                            @"call", @"type",
                            msg, @"data",
                            msgId, @"msgId",
                            nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:opxmsg options:0 error:nil];
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"String: %@", msgString);
    [ovxView ovxView_sendOPXMessage:msgString];
    
    
}
- (void) reconnectOPX
{
    if([ovxView ovxView_OPXSocket])
        [self sendOpxRegister];
    else
        [ovxView ovxView_OPXconnect];
}


- (void) sendOpxRegister
{
    NSLog(@"Registering .... as %@", username);

    NSString *idStr = [NSString stringWithFormat:@"myAPIKey:%@", username];
    
    NSDictionary *subscriberRegister = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"REGISTER", @"msgtype",
                                        idStr, @"id",
                                        username, @"identity",
                                        @"myNewAPIKey", @"key",
                                        @"mainpage", @"contextid",
                                        @"First", @"firstname",
                                        @"Last", @"lastname",
                                        @"me", @"members",
                                        @"http://ovx.me/img/person-default.jpg", @"picture",
                                        @"Activity Status", @"status",
                                        @"idle", @"state",
                                        ovxView.userId, @"deviceid",
                                        @"mobile", @"devicetype",
                                        nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:subscriberRegister options:0 error:nil];
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    int rc=[ovxView ovxView_sendOPXMessage:msgString];
    
    if(rc==-1)
        [logview setText:[NSString stringWithFormat:@"%@Sending OPX-%@", logview.text, @"REGISTER  FAILED"]];
    else
        [logview setText:[NSString stringWithFormat:@"%@Sending OPX-%@", logview.text, @"REGISTER"]];
}

-(void) processOPXInviteRequest
{
    if(!ovxView.isCallOn)
    {
        NSURL *aFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"wav"] isDirectory:NO];
    
        OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(aFileURL), &ringtoneSoundID);
   
        if(inviteRecvdTimer &&( [inviteRecvdTimer isValid]))
        {
            [inviteRecvdTimer invalidate];
            inviteRecvdTimer = nil;
        }
        
        inviteRecvdTimer = [NSTimer scheduledTimerWithTimeInterval: 40.0
                                                            target: self
                                                          selector:@selector(inviteRecvdTimerTicked)
                                                          userInfo: nil repeats:NO];
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        
        NSString *alertText = [NSString stringWithFormat:@"%@ calling ...", peerUsername];
        
        if (state == UIApplicationStateActive) {
            
            AudioServicesPlayAlertSound(ringtoneSoundID);
            
            
            inviteRecvdAlert= [[UIAlertView alloc] initWithTitle:alertText
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Reject"
                                               otherButtonTitles:@"Answer", nil];
            [inviteRecvdAlert setAlertViewStyle:UIAlertViewStyleDefault];
            [inviteRecvdAlert show];


        }
        else
        {
            NSLog(@"SENDING LOCAL NOTIFICATION");
            
            [self sendOpxRegister];
            
            Class cls = NSClassFromString(@"UILocalNotification");
            UILocalNotification *notif = [[cls alloc] init];
            notif.fireDate = Nil;
            notif.timeZone = [NSTimeZone defaultTimeZone];
            notif.alertBody = alertText;
            notif.alertAction = @"Answer";
            notif.soundName = @"ringtone.wav";
            //notif.applicationIconBadgeNumber = 1;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            
        }
        
        
    }
    else
        [self sendOPXApplicationInviteRejectedMessage];
    
}

-(void) cancelTimerAndAccept
{
    NSLog(@"CancelTimeAndAccept");
    [inviteRecvdTimer invalidate]; inviteRecvdTimer = nil;
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- Invite Request accepted by peer %@", logview.text, peerUsername]];
    AudioServicesDisposeSystemSoundID(ringtoneSoundID);

    [self sendOPXApplicationInviteAcceptedMessage];
    
}

- (void) sendOPXApplicationInviteAcceptedMessage
{

    NSString *toUser = [NSString stringWithFormat:@"myAPIKey:%@", peerUsername];
    NSString *idStr = [NSString stringWithFormat:@"myAPIKey:%@", username];
 
    inviteMessage[@"msg_type"] =@"INVITE_ACCEPTED";
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:inviteMessage
                                                        options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                          error:nil];
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    
    NSString *msgId = [self generateMsgId];
    NSMutableDictionary *inviteData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"MSG_REQUEST", @"msgtype",
                                       idStr, @"fromid",
                                       toUser, @"toid",
                                       @"call", @"type",
                                       msgId,@"msgId",
                                       nil];
    
    [inviteData setObject:jsonDataString forKey:@"data"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inviteData options:0 error:nil];
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"sendOPXApplicationInviteAcceptedMessage: %@", msgString);
    
    [ovxView ovxView_sendOPXMessage:msgString];
     NSString *messageId = [[NSString alloc] initWithString:msgId];
    if([msgTimer isValid])
    {
        [msgTimer invalidate];
    }
    msgTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                target: self
                                              selector:@selector(msgTimerTicked)
                                              userInfo: [NSDictionary dictionaryWithObject:messageId forKey:@"msgId"] repeats:NO];
    
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- Invite from %@ accepted ", logview.text, peerUsername]];
    

    
    ovxSessId =inviteMessage[@"session_id"] ;
    [ovxView setKeyValue:@"ovx-session" :ovxSessId ];
    
    if(displaynameField.text.length>0)
        [ovxView setKeyValue:@"ovx-name" : displaynameField.text];
    else
        [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];
    
    
    [ovxView setLatencyLevel:0.0];
    [self onCallStart:self];
    
    
}

- (void) sendOPXApplicationInviteRejectedMessage
{
    
    NSString *toUser = [NSString stringWithFormat:@"myAPIKey:%@", peerUsername];
    NSString *idStr = [NSString stringWithFormat:@"myAPIKey:%@", username];
    
    
    inviteMessage[@"msg_type"] =@"INVITE_REJECTED";
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:inviteMessage
                                                        options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                        error:nil];
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
     NSString *msgId = [self generateMsgId];
    NSMutableDictionary *inviteData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"MSG_REQUEST", @"msgtype",
                                       idStr, @"fromid",
                                       toUser, @"toid",
                                       @"call", @"type",
                                       msgId,@"msgId",
                                       nil];
    
    [inviteData setObject:jsonDataString forKey:@"data"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inviteData options:0 error:nil];
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"String: %@", msgString);
    
    [ovxView ovxView_sendOPXMessage:msgString];
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- Invite from %@ rejected ", logview.text, peerUsername]];
     NSString *messageId = [[NSString alloc] initWithString:msgId];
    if([msgTimer isValid])
        [msgTimer invalidate];
    msgTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                target: self
                                              selector:@selector(msgTimerTicked)
                                              userInfo: [NSDictionary dictionaryWithObject:messageId forKey:@"msgId"] repeats:NO];
    

    
}

- (void) sendOPXApplicationInviteExpiredMessage
{
    
    NSString *toUser = [NSString stringWithFormat:@"myAPIKey:%@", peerUsername];
    NSString *idStr = [NSString stringWithFormat:@"myAPIKey:%@", username];
    
    
    inviteMessage[@"msg_type"] =@"INVITE_EXPIRED";
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:inviteMessage
                                                        options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                          error:nil];
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    NSString *msgId = [self generateMsgId];
    NSMutableDictionary *inviteData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"MSG_REQUEST", @"msgtype",
                                       idStr, @"fromid",
                                       toUser, @"toid",
                                       @"call", @"type",
                                       msgId,@"msgId",
                                       nil];
    
    [inviteData setObject:jsonDataString forKey:@"data"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inviteData options:0 error:nil];
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"String: %@", msgString);
    
    [ovxView ovxView_sendOPXMessage:msgString];
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- Invite from %@ Expired ", logview.text, peerUsername]];
    NSString *messageId = [[NSString alloc] initWithString:msgId];
    if([msgTimer isValid])
        [msgTimer invalidate];
    msgTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                target: self
                                              selector:@selector(msgTimerTicked)
                                              userInfo: [NSDictionary dictionaryWithObject:messageId forKey:@"msgId"] repeats:NO];
    
}

- (void) sendOPXApplicationInviteMessage:(NSString*) pname
{
    
    NSString *toUser = [NSString stringWithFormat:@"myAPIKey:%@", pname];
    NSString *idStr = [NSString stringWithFormat:@"myAPIKey:%@", username];
  
    if(!ovxView.isCallOn)
    {

        ovxSessId = [self generateNonce];
        ovxSessId = [ovxSessId stringByReplacingOccurrencesOfString:@"=" withString:@""];
        ovxSessId = [ovxSessId stringByReplacingOccurrencesOfString:@"-" withString:@""];
        ovxSessId = [ovxSessId stringByReplacingOccurrencesOfString:@"/" withString:@""];
        ovxSessId = [ovxSessId stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
        ovxSessId= [ovxSessId lowercaseString]; // Here we will use a single group ID for the entire demo App
        ovxSessId = [ovxSessId substringToIndex:4];
        NSLog(@"sess Id: %@", ovxSessId);
    }
    else
        ovxSessId = ovxView.groupId;
    
    [ovxView setKeyValue:@"ovx-session" :ovxSessId ];

    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"INVITE_REQUEST", @"msg_type",
                                        ovxSessId, @"session_id",
                                        nil];
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:nil];
     NSString *jsonDataString = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    NSString *msgId = [self generateMsgId];
    NSMutableDictionary *inviteData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"MSG_REQUEST", @"msgtype",
                                        idStr, @"fromid",
                                        toUser, @"toid",
                                        @"call", @"type",
                                        msgId, @"msgId",
                                        nil];
    
    [inviteData setObject:jsonDataString forKey:@"data"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inviteData options:0 error:nil];
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"String: %@", msgString);
    
    [logview setText:[NSString stringWithFormat:@"%@ \n Sending OPX-%@", logview.text, @"INVITE_REQUEST"]];

    
    [ovxView ovxView_sendOPXMessage:msgString];
    NSString *messageId = [[NSString alloc] initWithString:msgId];
    if(msgTimer != nil)
    {
        if([msgTimer isValid])
            [msgTimer invalidate];
    }
    if(inviteSentTimer && ([inviteSentTimer isValid]))
        [inviteSentTimer invalidate];
    
    msgTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                 target: self
                                               selector:@selector(msgTimerTicked)
                                               userInfo:  [NSDictionary dictionaryWithObject:messageId forKey:@"msgId"] repeats:NO];
    
    inviteSentTimer = [NSTimer scheduledTimerWithTimeInterval: 40.0
                                                target: self
                                              selector:@selector(inviteSentTimerTicked)
                                              userInfo: [NSDictionary dictionaryWithObject:messageId forKey:@"msgId"] repeats:NO];

    startcall=TRUE;
  
}

- (void ) startCall
{
    NSLog(@"OVX : Start Call");
    
    if(!ovxView.isCallOn)
    {
        [ovxView showLoadingView];// SDK method to show loading view
        [ovxView call]; //SDK method to initiate call
        
    }
    
}

-(void) msgTimerTicked
{
    
    NSString *msgId = [[msgTimer userInfo] valueForKey:@"msgId"];
    NSLog (@"Msg Timer ticked : Msg Id: %@", msgId);
    msgTimer = nil;
    
 
}

-(void) inviteSentTimerTicked
{
    
    NSString *msgId = [[inviteSentTimer userInfo] valueForKey:@"msgId"];
    NSLog (@"Invite Timer ticked : Msg Id: %@", msgId);
    [logview setText:[NSString stringWithFormat:@"%@\nOPX- No Response from user %@", logview.text, peerUsername]];
    inviteSentTimer = nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Engage Chat"
                                                    message:@"No repsonse from peer"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];

    
}

-(void) inviteRecvdTimerTicked
{
    
    AudioServicesDisposeSystemSoundID(ringtoneSoundID);
    NSLog(@"invite recvd timer: ");
    inviteRecvdTimer = nil;
    inviteRecvdAlert.hidden = true;
    [inviteRecvdAlert dismissWithClickedButtonIndex:0 animated:YES];
    [inviteRecvdTimer invalidate];
    inviteRecvdTimer = nil;
  
    [inviteRecvdAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    //send INVITE_EXPIRED message
    
    [self sendOPXApplicationInviteExpiredMessage];
    
}

- (void)ovxView_didReceiveOPXMessage:(NSDictionary *)rxMessage
{
    NSLog(@"RX MESSAGE TYPE : %@", [rxMessage objectForKey:@"msgtype"]);
    
    if([[rxMessage objectForKey:@"msgtype"] isEqualToString:@"MSG_REQUEST"])
    {
         NSData* jsonData = [NSJSONSerialization dataWithJSONObject:rxMessage options:0 error:nil];
        
        NSDictionary *jsonObject=[NSJSONSerialization
                                  JSONObjectWithData:jsonData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
        NSLog(@"jsonObject is %@",jsonObject);
        
        
        NSString *data = jsonObject[@"data"];
        
        NSData *dataPart = [data dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSMutableDictionary *jsonObject1=[NSJSONSerialization
                                   JSONObjectWithData:dataPart
                                   options:NSJSONReadingMutableLeaves
                                   error:nil];
        
        inviteMessage = [[NSMutableDictionary alloc] initWithDictionary: jsonObject1];
        NSString *msg_type = jsonObject1[@"msg_type"];
        NSLog(@"msg type: %@", msg_type);
        NSString *sessionId = jsonObject1[@"session_id"];
        NSLog(@"session id: %@", sessionId);
         NSString *msgId = jsonObject[@"msgId"];
        
        [logview setText:[NSString stringWithFormat:@"%@\nReceived OPX-%@", logview.text, msg_type]];
        if([msg_type isEqualToString:@"INVITE_REQUEST"])
        {
            NSString *fromUser = jsonObject[@"fromid"];
            NSArray *stringArray = [fromUser componentsSeparatedByString: @":"];
            fromUser = stringArray[1];
            peerUsername = [[NSString alloc] initWithString:fromUser];
            [self processOPXInviteRequest];
        }
        else if([msg_type isEqualToString:@"INVITE_ACCEPTED"])
        {
            if([inviteSentTimer isValid])
            {
                NSString *inviteMsgId = (NSString*) [[inviteSentTimer userInfo] valueForKey:@"msgId"];
            
                if( [msgId isEqualToString:inviteMsgId])
                {
                    [inviteSentTimer invalidate];
                    inviteSentTimer = nil;
                }
            }
            
        }
        else   if([msg_type isEqualToString:@"INVITE_REJECTED"])
        {
            if([inviteSentTimer isValid])
            {
                
                NSString *inviteMsgId = (NSString*)[[inviteSentTimer userInfo] valueForKey:@"msgId"];
            
                if( [msgId isEqualToString:inviteMsgId])
                {
                    [inviteSentTimer invalidate];
                    inviteSentTimer = nil;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite rejected by peer"
                                                            message:@"Invitation is rejected by peer. Please try after sometime"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            
            endcall=TRUE;
            [alert show];
            
        }
        else   if([msg_type isEqualToString:@"INVITE_EXPIRED"])
        {
            if([inviteSentTimer isValid])
            {
                
                NSString *inviteMsgId = (NSString*)[[inviteSentTimer userInfo] valueForKey:@"msgId"];
                
                if( [msgId isEqualToString:inviteMsgId])
                {
                    [inviteSentTimer invalidate];
                    inviteSentTimer = nil;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Engage Chat"
                                                            message:@"No Response From Peer. Please try after sometime"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            
            [self onCallEndButton:self];
       
             endcall=TRUE;

            [alert show];
            
        }
    }
    else if([[rxMessage objectForKey:@"msgtype"] isEqualToString:@"PING"])
    {
        [self sendOpxRegister];
    }
    else  if([[rxMessage objectForKey:@"msgtype"] isEqualToString:@"MSG_RESPONSE"])
    {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:rxMessage options:0 error:nil];
        
        NSDictionary *jsonObject=[NSJSONSerialization
                                  JSONObjectWithData:jsonData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
        
        NSString *msgId = jsonObject[@"msgId"];
        NSLog(@"Received ack with msgId  %@",msgId);
        if(msgTimer!=nil)
        {
            if([msgTimer isValid])
            {
                NSString *sentMsgId = (NSString*)[[msgTimer userInfo] valueForKey:@"msgId"];
        
                if( [msgId isEqualToString:sentMsgId])
                {
                    [msgTimer invalidate];
                    msgTimer = nil;
                }
            }
        }
        
        if((inviteSentTimer &&[inviteSentTimer isValid]))
        {
            NSString *inviteMsgId = (NSString*)[[inviteSentTimer userInfo ]valueForKey:@"msgId"];
        
            if( [msgId isEqualToString:inviteMsgId])
            {
                [inviteSentTimer invalidate];
                inviteSentTimer = nil;
            }
        }
        
        NSString *data = jsonObject[@"errorcode"];

        if ((data == NULL)|| ([data isEqualToString:@"0"]))
        {
            
            if(startcall==TRUE)
            {
                [ovxView setLatencyLevel:0.0];
                startcall=FALSE;
                [self onCallStart:self];
            }
            return;
        }
        
        [logview setText:[NSString stringWithFormat:@"%@\nOPX- User is not reachable or not found: %@", logview.text, peerUsername]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EngageChat"
                                                        message:@"User is not reachable or not found. Consider sending an iMessage or Email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
        
        
    }
    else  if([[rxMessage objectForKey:@"msgtype"] isEqualToString:@"REGISTER_RESPONSE"])
    {
        [logview setText:[NSString stringWithFormat:@"%@\nOPX- Registered user %@", logview.text, username]];
        
        [self updateRegisteredUI];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:@"USERNAME"];
        [defaults synchronize];

    }
    
}


-(void) ovxView_didFailOPXWithError:(NSError *)error
{
    
    NSLog(@":( Websocket Failed With Error %@", error);
    
    [logview setText:[NSString stringWithFormat:@"%@\nOPX socket failure :%@ ", logview.text,error]];
    
    actionButton.hidden = FALSE;
    inviteButton.hidden = TRUE;
    inviteFriendButton.hidden = TRUE;
    endCallButton.hidden = TRUE;
    
    [self updateDeRegisteredUI];
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0
                                            target: self
                                            selector:@selector(reconnectOPX)
                                            userInfo: nil repeats:NO];

    
}

-(void) ovxView_didCloseOPXWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    
    NSLog(@"WebSocket closed");
    
    [logview setText:[NSString stringWithFormat:@"%@\nOPX socket closed : %@ ", logview.text, reason]];
    
    [self updateDeRegisteredUI];

}

-(void) ovxView_didOpenOPX
{
    NSLog(@"Applictaion: WebSocket Opened");
    
    [self sendOpxRegister];
    
}

-(void) ovxView_didConnectOPX
{
    
    NSLog(@"WebSocket Connected");
    
    
}

-(void) updateRegisteredUI
{
    inviteButton.hidden = FALSE;
    inviteFriendButton.hidden = FALSE;
    peernameField.hidden = FALSE;
}

-(void) updateDeRegisteredUI
{
    actionButton.hidden = FALSE;
    inviteButton.hidden = TRUE;
    inviteFriendButton.hidden = TRUE;
    endCallButton.hidden = TRUE;
    peernameField.hidden = TRUE;
    usernameField.enabled = TRUE;
}


-(IBAction) phoneInvite:(id)sender
{
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    [[picker navigationBar] setBarStyle:UIBarStyleBlack];
    picker.peoplePickerDelegate = self;
    // Display only a person's phone, email, and birthdate
    NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty] ,[NSNumber numberWithInt:kABPersonEmailProperty], nil];
    
    picker.displayedProperties = displayedItems;
    // Show the picker
    [self presentModalViewController:picker animated:YES];
    
}

-(void) inviteContact : (NSString *)name  :(NSString *)phone
{
    
    NSLog(@"invite Contact: %@ ;; %@", name, phone );
}

#pragma mark - ABPeopelPickerNavigationController Delegate and DataSource Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    return YES;
}


- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController didResolveToPerson:(ABRecordRef)person
{
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSLog(@"Default Action");
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if(property == kABPersonEmailProperty)
    {
        NSLog(@"Got Person %@", person);
        
        ABMutableMultiValueRef phonedata = ABRecordCopyValue(person, property);
        
        
        NSString *emailAddress = (NSString *) ABMultiValueCopyValueAtIndex(phonedata, identifier);
        
        NSLog(@"strEmail %@",emailAddress);

        
        [self dismissModalViewControllerAnimated:YES];
        peerUsername = [[NSString alloc] initWithString:emailAddress];
        
        
        [logview setText:[NSString stringWithFormat:@"%@\nOPX- Inviting %@", logview.text, peerUsername]];
        
        
        if(displaynameField.text.length>0)
            [ovxView setKeyValue:@"ovx-name" : displaynameField.text];
        else
            [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];
        
        [self sendOPXApplicationInviteMessage:peerUsername];
        
        
        return NO;
   }
    else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef emails = ABRecordCopyValue(person, property);
        CFStringRef phonenumberselected = ABMultiValueCopyValueAtIndex(emails, identifier);
        CFStringRef emailLabelSelected = ABMultiValueCopyLabelAtIndex(emails, identifier);
        CFStringRef emailLabelSelectedLocalized = ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(emails, identifier));
        NSLog(@"\n EmailValueSelected = %@ \n EmailLabelSelected = %@ \n \EmailLabeSelectedlLocalized = %@", phonenumberselected, emailLabelSelected, emailLabelSelectedLocalized);
        
        NSString *aNSString = (NSString *)CFBridgingRelease(phonenumberselected);
        
        
        aNSString = [aNSString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        aNSString = [aNSString stringByReplacingOccurrencesOfString:@"("
                                                         withString:@""];
        aNSString = [aNSString stringByReplacingOccurrencesOfString:@")"
                                                         withString:@""];
        aNSString = [aNSString stringByReplacingOccurrencesOfString:@"+"
                                                         withString:@""];
        aNSString = [aNSString stringByReplacingOccurrencesOfString:@"-"
                                                         withString:@""];
        aNSString = [aNSString stringByReplacingOccurrencesOfString:@" "
                                                         withString:@""];
        
        NSLog(@"Numbers Selected: %@", aNSString);
        
        [ self dismissModalViewControllerAnimated:YES ];
        
        peerUsername = [[NSString alloc] initWithString:aNSString];
    
        [logview setText:[NSString stringWithFormat:@"%@\nOPX- Inviting %@", logview.text, peerUsername]];
        
        
        if(displaynameField.text.length>0)
            [ovxView setKeyValue:@"ovx-name" : displaynameField.text];
        else
            [ovxView setKeyValue:@"ovx-name" :[[UIDevice currentDevice] name]];
        
        [self sendOPXApplicationInviteMessage:peerUsername];

        
        return NO;
    }
    return NO;
}


@end
