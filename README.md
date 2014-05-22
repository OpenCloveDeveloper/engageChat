engageChat
==========

engageChat source code for In-App communications using FreeMAD Service.

Get your own APIKey for FREE at http://developer.openclove.com and start using the FreeMAD Service for free.

### iOS Quick Start:

#### Configure the Service:

    iOS:
    
      [ovxView setParameter:@"ovx-title":@"EngageChat"];
      [ovxView setParameter:@"ovx-apiKey":@"GET_AN_API_KEY"];
      
    Android:
    
      OVXView ovxview = OVXView.getOVXContext(this);
      ovxView.setParameter("ovx-title","EngageChat");
      ovxView.setParameter("ovx-apiKey","GET_AN_API_KEY"); 
    

    

#### Register the User:

    iOS:
    
      [ovxView setUserLogin:@"14695551212" withType:@"sms"]; OR,
      [ovxView setUserLogin:@"janet@openclove.com" withType:@"email"]; OR,
      [ovxView setUserLogin:facebook withType:@"facebook"];
      
    Android:
    
      ovxView.setUserLogin("14695551212","sms") OR  
      ovxView.setUserLogin("janet@openclove.com","email")

    

#### Invoke iOS Address Book, and find someone's address.

#### Invite Someone:

    iOS:
    
      [self sendOPXApplicationInviteMessage:@"john.doe@openclove.com"];

    Android:
    
      invite_request(ovxView, "janet@openclove.com");
      


#### Send MESSAGE REQUEST

    iOS:
    
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
    
    Android:
    
      JSONObject message_request = new JSONObject();
      message_request.put("MSG_REQUEST","msgtype");
      message_request.put(user1@ovx.me","fromid");
      message_request.put(user2@ovx.me", "toid");
      message_request.put("message","type");
      message_request.put("12312","msgId");
      message_request.put("Any Text or JSON Message","data");     
                                   
      ovxView.sendOPXMessage(message_request.toString());
    

### For more information, please visit http://freemad.net

