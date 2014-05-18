engageChat
==========

engageChat source code for In-App communications using FreeMAD Service.

Get your own APIKey for FREE at http://developer.openclove.com and start using the FreeMAD Service for free.

iOS Quick Start:

Configure the FreeMAD Service:

[ovxView setKeyValue:@"ovx-title" :@"Engage Chat" ];
[ovxView setKeyValue:@"ovx-apiKey" :@"jmbyzaurgsq2qfqgyrt6ct8m" ];
[ovxView setKeyValue:@"ovx-maxParticipants" :@"2"];


Register the User:
    
    [ovxView setUserLogin:@"14692334486 usingType @"phone"], OR
    
    [ovxView setUserLogin:@"pulin@openclove.com usingType @"email"], OR
    
    [ovxView setUserLogin:facebook usingType @"facebook"], OR
    
    [ovxView setUserLogin:yossession usingType @"yahoo"], OR


Invoke iOS Address Book, and find someone's address.

Invite Someone:

    [self sendOPXApplicationInviteMessage:@"shubh@openclove.com"]

For more information, please visit http://developer.openclove.com

