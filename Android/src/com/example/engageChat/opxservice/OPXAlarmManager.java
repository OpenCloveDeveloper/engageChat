package com.example.engageChat.opxservice;

import java.util.Calendar;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

public class OPXAlarmManager extends BroadcastReceiver
{

	private static final long REPEAT_TIME = 1000 * 20;
	public static AlarmManager alarm_service;

	@Override
	public void onReceive(Context context, Intent intent)
	{
		Log.d("INDUS", "Launching ovx service");
		/*
		 * Toast.makeText(context, "intializing ovx service", Toast.LENGTH_LONG)
		 * .show();
		 */
		if (alarm_service == null)
			alarm_service = (AlarmManager) context
					.getSystemService(Context.ALARM_SERVICE);
		Intent i = new Intent(context, StartOPXReciever.class);
		PendingIntent pending = PendingIntent.getBroadcast(context, 0, i,
				PendingIntent.FLAG_CANCEL_CURRENT);
		Calendar cal = Calendar.getInstance();
		// Start 30 seconds after boot completed
		cal.add(Calendar.SECOND, 1);
		//
		// Fetch every 30 seconds
		// InexactRepeating allows Android to optimize the energy consumption
		alarm_service.setInexactRepeating(AlarmManager.RTC_WAKEUP,
				cal.getTimeInMillis(), REPEAT_TIME, pending);

		// service.setRepeating(AlarmManager.RTC_WAKEUP, cal.getTimeInMillis(),
		// REPEAT_TIME, pending);

	}

}
