package com.example.engageChat.opxservice;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Timer;

import com.example.engageChat.OPX;
import com.example.engageChat.OPXApplication;
import com.openclove.ovx.OVXCallListener;
import com.openclove.ovx.OVXView;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Binder;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;
import android.widget.Button;
import android.widget.Toast;

public class OPXRegisterService extends Service
{

	Button btnShowLocation;
	OVXView ovxview;
	private OVXCallListener ovx_listener;

	

	@Override
	public int onStartCommand(Intent intent, int flags, int startId)
	{

		Log.d("INDUS", "onStartCommand:");

		ovxview = OPXApplication.getOVXContext();
		
		if (ovxview != null) {

			if (!ovxview.isOPXRegistered() && !OPXApplication.isUiOn()
					&& SessionManager.isAccNameAvail()) 
			{
				Log.d("INDUS",
						"in service ---- opx not connected ... registering opx");

				if (isNetworkAvailable(this))
				{
					
					try {
						ovxview.opxInitiateRegister(OPXApplication.getOPXUsername());
					//	ovxview.setUserLogin(, "email");
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

					
				}
			}
			else
			{
				

				if(!ovxview.isOPXRegistered() && SessionManager.isAccNameAvail())
				{
					if (isNetworkAvailable(this)) {
						Log.d("INDUS",
								" opx not registered ... registering opx:");

					
						try
						{
							ovxview.opxInitiateRegister(OPXApplication.getOPXUsername());
						}
						catch (Exception e)
						{
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
				}
			}
		}

		// Toast.makeText(this, "on start command", Toast.LENGTH_LONG).show();

		return Service.START_NOT_STICKY;

	}

	@Override
	public IBinder onBind(Intent intent)
	{
		// TODO Auto-generated method stub
		return null;
	}

	
	public boolean isNetworkAvailable(Context context)
	{
		ConnectivityManager connectivity = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);

		if (connectivity == null) {
			return false;
		} else {
			NetworkInfo[] info = connectivity.getAllNetworkInfo();
			if (info != null) {
				for (int i = 0; i < info.length; i++) {
					if (info[i].getState() == NetworkInfo.State.CONNECTED) {
						return true;
					}
				}
			}
		}
		return false;
	}

}
