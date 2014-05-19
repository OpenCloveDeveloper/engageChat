engageChat
==========

engageChat source code for In-App communications using FreeMAD Service.

Get your own APIKey for FREE at http://developer.openclove.com and start using the FreeMAD Service for free.

## iOS Quick Start:

### Configure the Service:
    
    [ovxView setParameter:@"ovx-title":@"EngageChat"]
    
    [ovxView setParameter:@"ovx-apiKey":@"GET_AN_API_KEY"]
    

Register the User:
    
    [ovxView setUserLogin:@"14695551212" usingType @"phone"], OR
    
    [ovxView setUserLogin:@"janet@openclove.com usingType @"email"], OR
    
    [ovxView setUserLogin:facebook usingType @"facebook"], OR
    

Invoke iOS Address Book, and find someone's address.

Invite Someone:

    [self sendOPXApplicationInviteMessage:@"john.doe@openclove.com"]

For more information, please visit http://developer.openclove.com

