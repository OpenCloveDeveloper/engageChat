package com.example.engageChat.opxservice;

import java.io.File;
import java.util.Timer;
import java.util.TimerTask;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.os.Handler;
import android.os.Vibrator;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.widget.RemoteViews;

import com.example.engageChat.OPX;
import com.example.engageChat.OPXApplication;
import com.example.engageChat.EngageChat;
import com.example.engageChat.R;
import com.openclove.ovx.OVXCallListener;
import com.openclove.ovx.OVXView;

public class OPXListener implements OVXCallListener
{

	protected static final String KEY_NEXT = "reject";
	Context main_ctx;
	OVXView ovx_view;
	
	private Notification noti;
	public static NotificationManager notmgr;
	private static boolean cancelled;

	public OPXListener(Context ctx, OVXView ovxView)
	{
		main_ctx = ctx;
		ovx_view = ovxView;
	}

	@Override
	public void callEnded()
	{
		// TODO Auto-generated method stub

	}

	@Override
	public void callFailed()
	{
		// TODO Auto-generated method stub

	}

	@Override
	public void callStarted()
	{
		// TODO Auto-generated method stub

	}

	@Override
	public void callTerminated(String arg0)
	{
		// TODO Auto-generated method stub

	}

	

	public TimerTask sendExpireOnExpiry(final OVXView ovx_instance,
			final String peer_name, final String session_id)
	{
		TimerTask td = new TimerTask()
		{

			@Override
			public void run()
			{
				if(!OPXApplication.isUiOn())
				{
				OPX.invite_expired(ovx_instance, peer_name, session_id);
				notmgr.cancel(0);
				}
			}

		};

		return td;

	}


	@Override
	public void onNotificationEvent(String arg0, String arg1)
	{
		// TODO Auto-generated method stub

	}

	@Override
	public void ovxReceivedData(String arg0)
	{
		// TODO Auto-generated method stub

	}

	@Override
	public void recordedCallStart()
	{
		// TODO Auto-generated method stub

	}

	@Override
	public void recordedCallStop(String arg0)
	{
		// TODO Auto-generated method stub

	}
	
	@Override
	public void opxAuthenticationFailed(String arg0)
	{
		// TODO Auto-generated method stub
		
	}

	

	
	@SuppressWarnings("deprecation")
	private void launchNtfctn(final String peer, final String session_id)
	{
		// TODO Auto-generated method stub
		notmgr = (NotificationManager) main_ctx
				.getSystemService(main_ctx.NOTIFICATION_SERVICE);

		Intent intent = new Intent(main_ctx, EngageChat.class);
		intent.putExtra("notification", "answer");
		intent.putExtra("sessionId", session_id);
		intent.putExtra("peer", peer);

		PendingIntent pi = PendingIntent.getActivity(main_ctx, 1, intent, PendingIntent.FLAG_UPDATE_CURRENT);

		Vibrator vb = (Vibrator) main_ctx
				.getSystemService(main_ctx.VIBRATOR_SERVICE);

		long[] pattern = { 0, 100, 600, 100, 700 };

		vb.vibrate(pattern, -1);

		noti = new Notification(R.drawable.phoneicon, "Engage Chat",
				System.currentTimeMillis());
		noti.setLatestEventInfo(main_ctx, "EngageChat", peer + "  is Calling..",
				pi);

		// noti.flags |= Notification.FLAG_AUTO_CANCEL;

		noti.number += 5;// number of times to show the icon in the status bar

		noti.flags |= Notification.FLAG_SHOW_LIGHTS;// How the notifcations
		// should be like in the
		// seeker content after
		// clicking ...
		notmgr.notify(0, noti);// Using Mgr to show the
		// notifications...

	}
	
	public static void cancelNotification()
	{
		notmgr.cancel(0);
		cancelled=true;
	}

	@Override
	public void opxConnectionClosed(int arg0, String arg1)
	{
		// TODO Auto-generated method stub
		
	}

	@Override
	public void opxConnectionFailed(String arg0)
	{
		// TODO Auto-generated method stub
		
	}

	@Override
	public void opxConnectionReady()
	{
		// TODO Auto-generated method stub
	
		Log.d("INDUS", "OVXLIstener    ----opxConnectionReady" );
	}

	@Override
	public void opxDidReceiveMessage(String arg0)
	{
		// TODO Auto-generated method stub
		
		Log.d("INDUS", "OVXLIstener    ----opxDidReceiveMessage:" + arg0);

		final String response=arg0;
		Handler mainHandler = new Handler(main_ctx.getMainLooper());

		Runnable myRunnable = new Runnable()
		{

			private JSONObject request;
			private String msg_type;
			private String fromid;
			private String apiKey;
			private String peerName;
			private String invite_msgtype;
			private String sessionId;

			@Override
			public void run()
			{
				// TODO Auto-generated method stub
				try {
					
					request = new JSONObject(response);
					msg_type = (String) request.get("msgtype");
					fromid = (String) request.get("fromid");
					

					if(fromid.equals("SERVER"))
						return;
					
					String data = (String) request.getString("data");

					JSONObject jdata = new JSONObject(data);
						invite_msgtype = (String) jdata.get("msg_type");
						sessionId = (String) jdata.get("session_id");

					}
				catch (JSONException e) 
				{
					e.printStackTrace();
				}

				
				apiKey = fromid.split(":")[0];
				peerName = fromid.split(":")[1];

				Timer tt = new Timer();
				TimerTask td = sendExpireOnExpiry(ovx_view, peerName, sessionId);

				if (invite_msgtype.equals("INVITE_REQUEST")) 
				{
					if(!ovx_view.isCallOn())
						launchNtfctn(peerName, sessionId);
					tt.schedule(td, 40000);

				}
				
			
				Log.d("INDUS", "creating notification");
			}
		}; // This is your code
		mainHandler.post(myRunnable);

		
	}

	}
