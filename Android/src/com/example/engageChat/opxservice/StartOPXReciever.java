package com.example.engageChat.opxservice;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class StartOPXReciever extends BroadcastReceiver
{

	@Override
	public void onReceive(Context context, Intent arg1)
	{
		// TODO Auto-generated method stub
		Log.d("INDUS", "onReceive: launching device tracer intent");

		Intent service = new Intent(context, OPXRegisterService.class);
		context.startService(service);
	}

}
