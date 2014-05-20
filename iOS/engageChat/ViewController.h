/*
 *
 * Package Name		: engageChat
 * File Name		: ViewController.h
 * Version Name		: 1.3.1
 * Date    			: 20140506
 * Description		: Copyright (c) 2012 OpenClove. All rights reserved.
 *
 *
 */
#import <UIKit/UIKit.h>
#import "OVXView.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#include <AudioToolbox/AudioToolbox.h>

#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/AddressBookUI.h>




@interface ViewController : UIViewController <UITextFieldDelegate,OVXDelegate,ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate,ABUnknownPersonViewControllerDelegate>
{
    
    UITextView *logview;
    OVXView *ovxView;
    
    UITextField *displaynameField;
    UITextField *usernameField;
    UITextField *userphoneField;
    UITextField *peernameField;
    
    UIButton *actionButton;
    UIButton *inviteButton;
    UIButton *inviteFriendButton;
    UIButton *endCallButton;
    
    NSString *displayname;
    NSString *username;
    NSString *peerUsername;
    
    NSMutableDictionary *inviteMessage;
    NSString *ovxSessId;
    
    BOOL audiomute;
    BOOL videomute;
    
    SystemSoundID ringtoneSoundID;
    NSTimer *msgTimer;
    NSTimer *inviteSentTimer;
    NSTimer *inviteRecvdTimer;
    UIAlertView *inviteRecvdAlert;
    
    BOOL startcall;
    BOOL endcall;

}

@property (retain, nonatomic) IBOutlet UITextView *logview;
@property (retain, nonatomic) IBOutlet UITextField *displaynameField;
@property (retain, nonatomic) IBOutlet UITextField *usernameField;
@property (retain, nonatomic) IBOutlet UITextField *userphoneField;

@property (retain, nonatomic) IBOutlet UITextField *peernameField;

@property (retain, nonatomic) IBOutlet UIButton *actionButton;
@property (retain, nonatomic) IBOutlet UIButton *inviteButton;
@property (retain, nonatomic) IBOutlet UIButton *inviteFriendButton;
@property (retain, nonatomic) IBOutlet UIButton *endCallButton;

@property (retain, nonatomic) NSString *username;
@property (retain, nonatomic) NSString *peerUsername;
@property (retain, nonatomic) NSMutableDictionary *inviteMessage;
@property (retain, nonatomic) NSString *ovxSessId;
@property (retain, nonatomic) NSString *msgTimer;
@property (retain, nonatomic) NSString *inviteSentTimer;
@property (retain, nonatomic) NSString *inviteRecvdTimer;
@property (retain, nonatomic) UIAlertView *inviteRecvdAlert;

- (void)cancelTimerAndAccept;

@end
