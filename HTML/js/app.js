var msgId = "";
var msgIdTimer = 0;
var incomingmsg;
var recentincomingmsg ;

var sampleAppRecord = {
	"msg_type" : "",  /*INVITE_REQUEST,INVITE_ACCEPT,INVITE_REJECTED*/
	"client_id" : "",
	"session_id": "", /*SESSION  ID for the call*/
};

var grpId = "ovxtest";
var appkey = "myAPIKey";
var callstatus = "IDLE";

function handleServerEvents(eventType, eventData)
{
	OPX.utils.log("handleServerEvents - " + eventType + ",eventData - " + eventData);

	switch(eventType)
	{
		case "OPX_SERVER_MESSAGE":
			var rxmsg;
			try
			{
				rxmsg = JSON.parse(eventData);
			}
			catch (e)
			{
				OPX.utils.log("Not a JSON Message: " + eventData);

				if(eventData.search("Unknown Subscriber") > -1)
				{
					alert("User Not Reachable");
					resetInviteButton();
				}

				return;
			}

			if(rxmsg.msgtype == "REGISTER_RESPONSE")
			{
				OPX.utils.log(rxmsg);
				registerUpdate(1);
			}

			break;
	}

}

function handleNotificationEvents(eventType, eventData)
{
	OPX.utils.log("handleNotificationEvents - " + eventType);
}

function handlePeerEvents(eventType, eventData)
{
	console.log("handlePeerEvents - " + eventData);

	switch(eventType)
	{
		case "OPX_PEER_MESSAGE":
			var rxmsg = JSON.parse(eventData);
			OPX.utils.log(rxmsg);
			if((rxmsg.msgtype == "MSG_RESPONSE") && rxmsg.msgId == msgId)
			{
				clearAnswerResponseTimerExpiry();
				if(msgIdTimer != 0)
				{
					clearTimeout(msgIdTimer);
					msgIdTimer=0;
				}
				OPX.utils.log("Message Delivery Success for  Id - " + rxmsg.msgId);

				//clearAnswerResponseTimerExpiry();
				if(rxmsg.errorcode)
				{
					if(rxmsg.errorcode != "0")
					{
						alert(rxmsg.reason);
						resetInviteButton();
						return;
					}
				}
			}

			if(rxmsg.msgtype == "MSG_REQUEST")
			{
				clearAnswerResponseTimerExpiry();
				/*if(rxmsg.errorcode != "0")
				  {
				  alert(rxmsg.reason);
				  resetInviteButton();
				  return;
				  }*/

				var msg = JSON.parse(rxmsg.data);

				OPX.utils.log("Message Type is - " + msg.msg_type + ", session id is - " + msg.session_id);            
				if(msg.msg_type == 'INVITE_ACCEPTED')
				{
					document.getElementById("status").innerHTML = "INVITE ACCEPTED";
					grpId = msg.session_id;
					setTimeout(function(){ placeCall(msg.session_id); } ,0);

				}

				if(msg.msg_type == 'INVITE_EXPIRED')
				{
					document.getElementById("status").innerHTML = "INVITE REJECTED";
					alert("No Response from Invited User");
					resetInviteButton();
				}

				if(msg.msg_type == 'INVITE_REJECTED')
				{
					document.getElementById("status").innerHTML = "INVITE REJECTED";
					alert("Call has been rejected");
					resetInviteButton();
				}

				if(msg.msg_type  == 'INVITE_REQUEST')
				{
					document.getElementById("status").innerHTML = "RECEIVED INVITE";

					if(callstatus == "IDLE")   /* Ignore if already on call */
						showAlertBox(rxmsg);
					else
					{
						rejectCall(eventData);
					}

				}


			}
			break;
	}

}

function registerUser()
{
	OPX.initialize(appkey,function(eventCategory, eventType, eventData) 
			{
			OPX.utils.log(eventType + ": " + eventData);
			switch (eventCategory)
			{
			case "ServerEvents":
			handleServerEvents(eventType, eventData);
			break;
			case "NotificationEvents":
			handleNotificationEvents(eventType, eventData);
			break;
			case "PeerEvents":
			handlePeerEvents(eventType, eventData);
			break;
			default:
			OPX.utils.log("Event Category: " +eventCategory);
			}
			});
        OPX.User.setAPIKey('jmbyzaurgsq2qfqgyrt6ct8m');
	OPX.User.setIdentity(document.getElementById('userid').value);

	OPX.Session.register();
}

function sendInviteToUser()
{
	var toid = document.getElementById('invitee').value;
	sampleAppRecord.msg_type = "INVITE_REQUEST";

	if(callstatus == "ACTIVE")
		sampleAppRecord.session_id = grpId;
	else
	{
		sampleAppRecord.session_id = OPX.utils.randomNumbers(5);
		grpId = sampleAppRecord.session_id;
	}

	msgId = OPX.Session.sendMessage("MSG_REQUEST",toid,"call",JSON.stringify(sampleAppRecord));

	document.getElementById("status").innerHTML = "SENDING INVITE";

	msgIdTimer = setTimeout(handleMessageDeliveryFailure,5000);
	answerResponseTimer = setTimeout(handleAnswerResponseTimerExpiry,answerResponseTimerVal); 
}

function handleMessageDeliveryFailure()
{
	document.getElementById("status").innerHTML =  "Message Delivery Failure for Id - " + msgId;
	OPX.utils.log("Message Delivery Failure for Id - " + msgId);

}

function handlePlayerEvents(eventType, eventData)
{
	var evtData = JSON.parse(eventData);

	if(eventType == "OVX_CALL_EVENT")
	{
		if( (evtData.eventDataType == "OVX_CALL_STATUS") && (evtData.eventDataValue == "IDLE") || (evtData.eventDataValue == "END") )
			document.getElementById('ovx-player').style.display = "none";

		if( (evtData.eventDataType == "OVX_CALL_STATUS") && (evtData.eventDataValue == 'ACTIVE'))
		{
			resetInviteButton();
		}
		if(evtData.eventDataType == "OVX_CALL_STATUS")
		{
			callstatus = evtData.eventDataValue;
		}
	}
}

function invitePressed()
{
	sendInviteToUser();
	document.getElementById('inviteButtonText').innerHTML = "Connecting";
	document.getElementById('inviteButtonStatus').setAttribute('class','fa fa-2x fa-repeat fa-spin pull-right');
}

function resetInviteButton()
{
	document.getElementById('inviteButtonText').innerHTML = "Invite";
	document.getElementById('inviteButtonStatus').setAttribute('class','fa fa-2x fa-sign-in pull-right');
}

function registerPressed()
{
	registerUser();
	var btn = document.getElementById('registerButtonStatus');
	btn.setAttribute('class','fa fa-2x fa-repeat fa-spin pull-right');

}

function registerUpdate(result)
{
	document.getElementById('registerButton').style.display="none";
	var rx = document.getElementById('registerStatus');
	rx.style.color = "#00CC00";
	rx.setAttribute('class','fa fa-circle fa-fw');
	document.getElementById('inviteDialog').style.display="block";
	document.getElementById('userid').setAttribute('disabled','');
}

function placeCall(sessid)
{
	if(callstatus == "IDLE")
	{
		OVXEMBED.setCallBack(function(eventType, eventData) {
				handlePlayerEvents(eventType, eventData);
				});

		OVXEMBED.setKeyValue('ovx-apikey',OPX.User.getAPIKey());
		OVXEMBED.setKeyValue('ovx-autostart','true');
		OVXEMBED.setKeyValue('ovx-session', sessid);
		if(document.getElementById('username').value != "")
			OVXEMBED.setKeyValue('ovx-name', document.getElementById('username').value);

		document.getElementById('ovx-player').style.display='block';
		/*		setTimeout(function() {
				document.getElementById('ovx-player').style.display='block';
				}, 4000);*/
	}
	else
		resetInviteButton();

}
var answerTimer = 0;
var answerTimerVal = 40000;

var answerResponseTimer = 0;
var answerResponseTimerVal = 50000;


function handleAnswerResponseTimerExpiry()
{
	alert("No Response from the User");
	resetInviteButton(); 
}

function handleAnswerRequestTimerExpiry()
{
	//ignoreCall();
	expireCall();
}

function clearAnswerRequestTimerExpiry()
{
	if(answerTimer != 0)
	{
		clearTimeout(answerTimer);
		answerTimer = 0;
	}
}

function clearAnswerResponseTimerExpiry()
{
	if(answerResponseTimer != 0)
	{
		clearTimeout(answerResponseTimer);
		answerResponseTimer = 0;
	}
}

function answerCall()
{
	clearAnswerRequestTimerExpiry();
	hideAlertBox();
	var msg = JSON.parse(incomingmsg.data);

	msg.msg_type = 'INVITE_ACCEPTED';                                                
	msgId = OPX.Session.sendMessage("MSG_REQUEST",incomingmsg.fromid.split(":")[1],"call",JSON.stringify(msg));  
	msgIdTimer = setTimeout(handleMessageDeliveryFailure,5000);                                                
	grpId = msg.session_id;                                                
	placeCall(msg.session_id);

	document.getElementById('inviteButtonText').innerHTML = "Connecting";
	document.getElementById('inviteButtonStatus').setAttribute('class','fa fa-2x fa-repeat fa-spin pull-right');

}

function rejectCall(inMsg)
{
	var msg = JSON.parse(inMsg);
	msg.msg_type = 'INVITE_REJECTED';
	msgId = OPX.Session.sendMessage("MSG_REQUEST",msg.fromid.split(":")[1],"call",JSON.stringify(msg));
	msgIdTimer = setTimeout(handleMessageDeliveryFailure,5000);
}

function ignoreCall()
{
	clearAnswerRequestTimerExpiry();
	hideAlertBox();
	var msg = JSON.parse(incomingmsg.data);
	msg.msg_type = 'INVITE_REJECTED';
	msgId = OPX.Session.sendMessage("MSG_REQUEST",incomingmsg.fromid.split(":")[1],"call",JSON.stringify(msg));
	msgIdTimer = setTimeout(handleMessageDeliveryFailure,5000);
}

function expireCall()
{
	clearAnswerRequestTimerExpiry();
	hideAlertBox();
	var msg = JSON.parse(incomingmsg.data);
	msg.msg_type = 'INVITE_EXPIRED';
	msgId = OPX.Session.sendMessage("MSG_REQUEST",incomingmsg.fromid.split(":")[1],"call",JSON.stringify(msg));
	msgIdTimer = setTimeout(handleMessageDeliveryFailure,5000);
}


function showAlertBox(rxmsg)
{
	answerTimer = setTimeout(handleAnswerRequestTimerExpiry,answerTimerVal);
	incomingmsg = rxmsg;

	document.getElementById('dialogoverlay').style.display="block";
	document.getElementById('dialogbox').style.display="block";	
	playTone();
}
function hideAlertBox()
{
	document.getElementById('dialogoverlay').style.display="none";
	document.getElementById('dialogbox').style.display="none";    
	stopTone();
}

function playTone()
{
	var x = document.getElementById('ring');
	x.play();
}
function stopTone()
{
	document.getElementById('ring').pause();
}

