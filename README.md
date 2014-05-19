engageChat
==========

engageChat source code for In-App communications using FreeMAD Service.

Get your own APIKey for FREE at http://developer.openclove.com and start using the FreeMAD Service for free.

### iOS Quick Start:

#### Configure the Service:
    
    [ovxView setParameter:@"ovx-title":@"EngageChat"]
    
    [ovxView setParameter:@"ovx-apiKey":@"GET_AN_API_KEY"]
    

#### Register the User:
    
    [ovxView setUserLogin:@"14695551212" usingType @"phone"], OR
    
    [ovxView setUserLogin:@"janet@openclove.com usingType @"email"], OR
    
    [ovxView setUserLogin:facebook usingType @"facebook"], OR
    

#### Invoke iOS Address Book, and find someone's address.

#### Invite Someone:

    [self sendOPXApplicationInviteMessage:@"john.doe@openclove.com"]

#### Send MESSAGE REQUEST

    NSMutableDictionary *inviteData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"MSG_REQUEST", @"msgtype",
                                       @"myAppKey:user1@ovx.me", @"fromid",
                                       @"myAppKey:user2@ovx.me", @"toid",
                                       @"message", @"type",
                                       @"12312",@"msgId",
                                       @"Any Text or JSON Message",@"data",
                                       nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inviteData options:0 error:nil];
    
    NSString* msgString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    [ovxView ovxView_sendOPXMessage:msgString];
    

### For more information, please visit http://developer.openclove.com

