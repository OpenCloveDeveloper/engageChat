package com.example.engageChat.opxservice;

import java.util.HashMap;

import android.content.Context;
//import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;


public class SessionManager {
    // Shared Preferences
     static SharedPreferences pref;
     
    // Editor for Shared preferences
    static Editor editor;
     
    // Context
    Context _context;
     
    // Shared pref mode
    int PRIVATE_MODE = 0;
     
    // Sharedpref file name
    private static final String PREF_NAME = "TalkOnPref";
     
    // All Shared Preferences Keys
    private static final String IS_ACCNAME_AVAIL = "IsAccNameAvail";
     
    // User name (make variable public to access from outside)
    public static final String KEY_NAME = "name";
     
    // Constructor
    public SessionManager(Context context){
        this._context = context;
        pref = _context.getSharedPreferences(PREF_NAME, PRIVATE_MODE);
        editor = pref.edit();
    }
     
    /**
     * Create Account session
     * */
    public static void createAccountSession(String name){
        // Storing Account value as TRUE
        editor.putBoolean(IS_ACCNAME_AVAIL, true);
         
        // Storing name in pref
        editor.putString(KEY_NAME, name);
     
        // commit changes
        editor.commit();
    }   

    public boolean isFirstTime()
	{
    	return pref.getBoolean("firstTime", false);
		//return firstTime;
	}
	
	public void setFirstTimeStatus(boolean status)
	{
		editor.putBoolean("firstTime", status);
		editor.commit();
	}
	
	public boolean isContactAdded()
	{
		return pref.getBoolean("contactAdded", false);
	}
	
	public void setContactAddedStatus(boolean status)
	{
		editor.putBoolean("contactAdded", status);
		editor.commit();
	}
	
    /**
     * Get stored session data
     * */
    public HashMap<String, String> getUserDetails(){
    	
        HashMap<String, String> user = new HashMap<String, String>();
        // user name
        user.put(KEY_NAME, pref.getString(KEY_NAME, null));
              
        // return user
        return user;
    }
     
    /**
     * Clear session details
     * */
    public void remUser(){
        // Clearing all data from Shared Preferences
        editor.clear();
        editor.commit();
    }
     
    /**
     * Quick check for Account Information
     * **/
    // Get Account State
    public static boolean isAccNameAvail(){
        return pref.getBoolean(IS_ACCNAME_AVAIL, false);
    }
}