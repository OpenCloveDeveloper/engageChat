package com.example.engageChat;

import org.json.JSONException;
import org.json.JSONObject;

import com.openclove.ovx.OVXException;
import com.openclove.ovx.OVXView;

public class OPX {
	
	/******  APPLICATION USING OPX FUNCTIONS *********/
	
	
	
	public static void invite_request(OVXView ovx_instance,String peer_name)
	{
	
		
		JSONObject message_request = new JSONObject();
		try {
			message_request.put("msgtype", "MSG_REQUEST");
			message_request.put("fromid", "myAPIKey:"+OPXApplication.getOPXUsername());
			message_request.put("toid", "myAPIKey:"+peer_name);
			message_request.put("ovxApiKey",ovx_instance.getApiKey());
			JSONObject invite_request = new JSONObject();
			invite_request.put("msg_type", "INVITE_REQUEST");
			invite_request.put("client_id", "");
			invite_request.put("session_id", new Integer((int)(Math.random()*10000)).toString());//new Integer((int)(Math.random()*100000)).toString());
			message_request.put("data", invite_request.toString());
			
			message_request.put("type", "call");
			message_request.put("msgId", new Integer((int)(Math.random()*10000)).toString());
			message_request.put("errorcode", "0");
			message_request.put("reason", "NA");
			

			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 
			try {
				ovx_instance.sendOPXMessage(message_request.toString());
			} catch (OVXException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	
	}
	
	
	public static void invite_rejected(OVXView ovx_instance,String peer_name,String session_id)
	{

		JSONObject message_request = new JSONObject();
		try {
			message_request.put("msgtype", "MSG_REQUEST");
			message_request.put("fromid","myAPIKey:"+OPXApplication.getOPXUsername());
			message_request.put("toid", "myAPIKey:"+peer_name);
			message_request.put("ovxApiKey",ovx_instance.getApiKey());
			JSONObject invite_request = new JSONObject();
			invite_request.put("msg_type", "INVITE_REJECTED");
			invite_request.put("client_id", "");
			invite_request.put("session_id", session_id);
			
			message_request.put("data", invite_request.toString());
			message_request.put("type", "call");
			message_request.put("msgId", new Integer((int)(Math.random()*10000)).toString());
			message_request.put("errorcode", "0");
			message_request.put("reason", "NA");
			message_request.put("ssr","10.209.153.23:8897");
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 
				
		try 
		{
			ovx_instance.sendOPXMessage(message_request.toString());
		}
		catch (OVXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	public static void invite_expired(OVXView ovx_instance,String peer_name,String session_id)
	{

		
		JSONObject message_request = new JSONObject();
		try {
			message_request.put("msgtype", "MSG_REQUEST");
			message_request.put("fromid", "myAPIKey:"+OPXApplication.getOPXUsername());
			message_request.put("toid", "myAPIKey:"+peer_name);
			message_request.put("ovxApiKey",ovx_instance.getApiKey());
			
			JSONObject invite_request = new JSONObject();
			invite_request.put("msg_type", "INVITE_EXPIRED");
			invite_request.put("client_id", "");
			invite_request.put("session_id", session_id);
			message_request.put("data", invite_request.toString());
			message_request.put("type", "call");
			message_request.put("msgId", new Integer((int)(Math.random()*10000)).toString());
			message_request.put("errorcode", "0");
			message_request.put("reason", "NA");
			message_request.put("ssr","10.209.153.23:8897");
			
		} catch (JSONException e) 
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 
		
		try 
		{
			ovx_instance.sendOPXMessage(message_request.toString());
		}
		catch (OVXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	
	public static void invite_accept(OVXView ovx_instance,String peer_name,String sessionId)
	{
		
		JSONObject message_request = new JSONObject();
		
		try {
			
			message_request.put("msgtype", "MSG_REQUEST");
			message_request.put("fromid", "myAPIKey:"+OPXApplication.getOPXUsername());//appKey:userIdemail or phone entered
			message_request.put("toid", "myAPIKey:"+peer_name);
			message_request.put("ovxApiKey",ovx_instance.getApiKey());
				JSONObject invite_accept = new JSONObject();
			invite_accept.put("msg_type", "INVITE_ACCEPTED");
			invite_accept.put("client_id", "");
			invite_accept.put("session_id", sessionId);
			message_request.put("data", invite_accept.toString());
			message_request.put("type", "call");
			message_request.put("msgId", new Integer((int)(Math.random()*10000)).toString());
			message_request.put("errorcode", "0");
			message_request.put("reason", "NA");
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 
		
		try {
			ovx_instance.sendOPXMessage(message_request.toString());
//			ovx_instance.call();
		} catch (OVXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
	}
	
	
}
