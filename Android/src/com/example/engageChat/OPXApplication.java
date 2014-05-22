package com.example.engageChat;

import android.content.Context;
import android.util.Log;

import com.example.engageChat.opxservice.OPXListener;
import com.openclove.ovx.OVX;
import com.openclove.ovx.OVXCallListener;
import com.openclove.ovx.OVXView;



public class OPXApplication extends OVX{
	static OVXView ovxView;
	static OVXCallListener ovx_listener;
	static Context ctx ;
	private static String userName;
	
	
	public OPXApplication()
	{
		ctx = this;
	}
	
	@Override 
	public void onCreate()
	{
		
		ctx = this;
		Log.d("INDUS","Application oncreate called");
	}
	
	public static void setOVXContext(OVXView ovx_view)
	{
		
		ovxView = ovx_view;
	}
	
	public static OVXView getOVXContext()
	{
		return ovxView;
		
	}
	
	public static void setOPXUsername(String number)	
	{
		userName = number;
	}
	
	public static String getOPXUsername()
	{
		return userName;
	}
	
	public static void setOVXListener()
	{
		Log.d("INDUS", "in OVXApplication setOVXListener");
		if (ovxView != null) {
			ovx_listener = new OPXListener(ctx,ovxView);
			ovxView.setCallListener(ovx_listener);
			Log.d("INDUS", "setting call listener for service");
		}
		
	}
	
	public static void unsetOVXListener()
	{
		if (ovxView != null) {
			ovx_listener = null;
			
			ovxView.setCallListener(ovx_listener);
		}
	}

	private static boolean uiState;
	
	
	public static void setUIState(boolean ui_state)
	{
		uiState = ui_state; 
	}
	
	public static boolean isUiOn()
	{
		return uiState;
	}
	
	
	
}
