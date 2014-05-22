/***
 * Package Name  :com.example.engageChat
 * Version Name  :1.0.0
 * Date          :20140506 
 * Description   :Activity used to show cast the OVX Features.
  
 *****/

package com.example.engageChat;

import java.io.IOException;
import java.util.Timer;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.AlertDialog.Builder;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.res.AssetFileDescriptor;
import android.content.res.Configuration;
import android.database.Cursor;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Vibrator;
import android.provider.ContactsContract;
import android.provider.Settings.Secure;
import android.support.v4.content.LocalBroadcastManager;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.util.Patterns;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.engageChat.opxservice.OPXAlarmManager;
import com.example.engageChat.opxservice.OPXListener;
import com.example.engageChat.opxservice.SessionManager;

import com.openclove.ovx.OVXCallListener;
import com.openclove.ovx.OVXException;
import com.openclove.ovx.OVXView;
import com.openclove.stack.OVXLog;

public class EngageChat extends Activity
{

	private OVXView ovxView;
	protected RelativeLayout media_control;
	private EditText ovx_text;
	protected TextView chat_box;
	private EngageChat currentActivity;
	private String videourl;
	private EditText inv_text;
	private Button inv_btn;
	public boolean accepted_rejectedclicked;
	private MediaPlayer player;
	private Button register;
	private Button pick_number;
	private final int PICK = 1;
	public boolean end_call;
	private EditText disp_name;
	protected SessionManager sessionManager;
	public Button end_btn;
	private Notification noti;
	private NotificationManager notmgr;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		setContentView(R.layout.ovx_chat);

		/** Comments provided for ovx sdk code **/

		Log.d("OVX", "onCreate");

		currentActivity = this;
		sessionManager = new SessionManager(this);

		Log.d("INDUS",
				"Session Registered name Availability:"
						+ SessionManager.isAccNameAvail());

		if (SessionManager.isAccNameAvail()) {
			OPXApplication.setOPXUsername(sessionManager.getUserDetails().get(
					"name"));
			Intent mAlarmIntent = new Intent(currentActivity,
					OPXAlarmManager.class);

			sendBroadcast(mAlarmIntent);
		}

		/* Access the Shared Instance of the OVXView */

		ovxView = OVXView.getOVXContext(this);

		OPXApplication.setOVXContext(ovxView);
		OPXApplication.setUIState(true);
		OPXApplication.unsetOVXListener();

		Log.d("INDUS", " Registered:" + ovxView.isOPXRegistered());
		try {

			/* api key received on creation of developers account */

			ovxView.setParameter("ovx-apiKey", "jmbyzaurgsq2qfqgyrt6ct8m");

			/* secret key received on creation of developers account */

			ovxView.setParameter("ovx-apiSecret",
					"p2MDJVWSwD7lFZvd2GXUySlXQwA=");

			/* Menu title */

			ovxView.setParameter("ovx-title", "Engage Chat");

			/* To get UID(User ID) for the device */

			String ovxuserId = Secure.getString(this.getContentResolver(),
					Secure.ANDROID_ID);

			ovxView.setParameter("ovx-userId", ovxuserId);

			/*
			 * this refers to the Themeing of video frames, background, etc. of
			 * the Live Board video room. Contact support@openclove.com for more
			 * details on the Themes available.
			 */

			ovxView.setParameter("ovx-mood", "1");

			/*
			 * Now lets set a default size and location of the Video Window on
			 * your device. This is where the video will first start. After that
			 * you can pinch to re-size, and drag to move it around the Screen.
			 */

			ovxView.setParameter("ovx-width", "320"); // Width of the video
														// view..

			ovxView.setParameter("ovx-height", "240"); // Height of the video
														// view..

			ovxView.setRemoteViewX(100); // X-axis location of the video view in
											// the screen..

			ovxView.setRemoteViewY(100); // Y-axis location of the video view in
											// the screen..
			ovxView.setLatency(0);

			/* To know the debug logs */

			ovxView.setParameter("ovx-debug", "enable");

			/*
			 * Here you can set whether to show the OVX menu when the user taps
			 * the video view. OVX menu contains call control features,like
			 * audio mute,video mute etc; it also allows you to minimize or
			 * maximize the video view.
			 */

			ovxView.setParameter("ovx-showOVXMenuOnTap", "enable");

			/*
			 * Remote gesture api is true by default, setting it to false will
			 * disable the pinch/zoom and drag event of the video view and also
			 * prevents you from maximizing the video on double tap, hence
			 * setting it to false will lock the video view in a fixed position
			 * on the screen.
			 */

			ovxView.setParameter("ovx-enableUserInteraction", "enable");// enable
																		// by
																		// default

			/*
			 * set chat attribute to enable to send to and receive data from the
			 * remote peer who has joined the same room
			 */

			ovxView.setParameter("ovx-chat", "enable");

			/* set record attribute to enable to record the video conference */

			ovxView.setParameter("ovx-record", "enable");// disable by default

			/*
			 * Connect to the OpenClove Peer Exchange Service to establish the
			 * connection..
			 */

			// ovxView.connect_opx();

		} catch (OVXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		/* Layout Views */

		chat_box = (TextView) findViewById(R.id.chat_text_box);
		chat_box.setTextColor(Color.BLACK);

		disp_name = (EditText) findViewById(R.id.disp_name);
		disp_name.setHorizontallyScrolling(true);
		disp_name.setTextColor(Color.BLACK);

		ovx_text = (EditText) findViewById(R.id.chat_text);
		ovx_text.setHorizontallyScrolling(true);
		ovx_text.setTextColor(Color.BLACK);

		inv_text = (EditText) findViewById(R.id.app);
		inv_text.setTextColor(Color.BLACK);

		inv_text.setVisibility(View.INVISIBLE);

		inv_btn = (Button) findViewById(R.id.invite);

		inv_btn.setVisibility(View.INVISIBLE);

		pick_number = (Button) findViewById(R.id.pick);

		pick_number.setVisibility(View.INVISIBLE);

		end_btn = (Button) findViewById(R.id.end_btn);

		if (ovxView.isCallOn()) {
			end_btn.setVisibility(View.VISIBLE);
		}
		/* OnClick action to pick number from address book */

		end_btn.setOnClickListener(new OnClickListener()
		{

			@Override
			public void onClick(View v)
			{

				if (ovxView.isCallOn()) {
					ovxView.exitCall();
				}

			}
		});

		pick_number.setOnClickListener(new OnClickListener()
		{

			@Override
			public void onClick(View v)
			{

				getContactNumber();

			}
		});

		if (OPXApplication.getOPXUsername() != null) {

			ovx_text.setEnabled(true);
			ovx_text.setText(OPXApplication.getOPXUsername());
			if (!ovxView.isOPXRegistered())
				inv_text.setVisibility(View.INVISIBLE);
			else
				inv_text.setVisibility(View.VISIBLE);

			disp_name.setText(ovxView.getOvxUserName());

			inv_text.setEnabled(true);

			if (!ovxView.isOPXRegistered())
				inv_btn.setVisibility(View.INVISIBLE);
			else
				inv_btn.setVisibility(View.VISIBLE);

			if (!ovxView.isOPXRegistered())
				pick_number.setVisibility(View.INVISIBLE);
			else
				pick_number.setVisibility(View.VISIBLE);

		}

		/* onClick action to register */
		register = (Button) findViewById(R.id.reg_btn);
		register.setOnClickListener(new OnClickListener()
		{

			@Override
			public void onClick(View v)
			{

				String entered_number = ovx_text.getText().toString();

				if ((containsOnlyDigits(entered_number) && isValidPhoneNumber(entered_number))
						|| isValidEmail(entered_number))

					try {

						/*
						 * Set key-value with 'ovx-name' , OPX will Register
						 * with this name
						 */

						if (disp_name.getText().toString().trim().equals(""))
							ovxView.setParameter("ovx-name", ovx_text.getText()
									.toString());
						else
							ovxView.setParameter("ovx-name", disp_name
									.getText().toString());

						OPXApplication.setOPXUsername(ovx_text.getText()
								.toString());
						SessionManager.createAccountSession(ovx_text.getText()
								.toString());

						// ovxView.setUserLogin(entered_number,"email",disp_name.getText().toString(),disp_name.getText().toString(),"","myAPIKey");//
						// type
						if (isValidEmail(entered_number))
							ovxView.setUserLogin(entered_number, "email");// type
						if ((containsOnlyDigits(entered_number) && isValidPhoneNumber(entered_number)))
							ovxView.setUserLogin(entered_number, "sms");// ,disp_name.getText().toString(),disp_name.getText().toString(),"","myAPIKey");//
																		// type

						// email
						// or
						// sms
						// can
						// be
						// used..

						Log.d("INDUS",
								"Registered Name: " + ovxView.getOvxUserName());

						Log.d("INDUS", "Starting intent to start service");

					} catch (OVXException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				else
					Toast.makeText(currentActivity,
							"Enter Correct Number or Email", Toast.LENGTH_LONG)
							.show();

			}
		});

		/* OnClick action to send invite request */

		inv_btn.setOnClickListener(new OnClickListener()
		{

			@Override
			public void onClick(View v)
			{

				if (!inv_text.getText().toString().trim().equals("")) {
					if (!ovxView.isCallOn())
					{
						OPX.invite_request(ovxView, inv_text.getText()
								.toString());
						chat_box.append("\n" +"Sending OPX Invite Request to :"+inv_text.getText().toString());
						chat_box.setMovementMethod(new ScrollingMovementMethod());
						focusOnText();
					}
					else {
						CharSequence[] ch = { "Call is already Active" };
						showDialog("Engage Chat", ch);
					}
				}

			}
		});

		/*
		 * This method contains implementation of OVX call listeners. Look into
		 * the method definition for further description *
		 */

		callListener();

		/*
		 * Once call is started the scroll event will not take place when user
		 * tries to scroll through thetext box since it has its own custom
		 * scroll. Users will have to scroll through the sides(regions other
		 * than the chat text box)
		 */

		ScrollView scroll_layout = (ScrollView) findViewById(R.id.scroll_layout);
		scroll_layout.setOnTouchListener(new View.OnTouchListener()
		{

			public boolean onTouch(View v, MotionEvent event)
			{

				findViewById(R.id.chat_text_box).getParent()
						.requestDisallowInterceptTouchEvent(false);

				return false;
			}
		});

		chat_box.setOnTouchListener(new View.OnTouchListener()
		{

			public boolean onTouch(View v, MotionEvent event)
			{

				// Disallow the touch request for parent scroll on touch of
				// child view
				v.getParent().requestDisallowInterceptTouchEvent(true);

				return false;
			}
		});

		try {
			handleIntent(getIntent());
		} catch (OVXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private void handleIntent(Intent intent) throws OVXException
	{
		// TODO Auto-generated method stub
		if (intent == null || intent.getExtras() == null) {
			Log.d("INDUS", "intent empty");
			return;
		}

		Log.d("INDUS", "intent not empty");
		String action = (String) intent.getExtras().get("notification");
		if (action.equals("answer")) {
			OPXListener.cancelNotification();

			String sessionId = (String) intent.getExtras().get("sessionId");
			String peer = (String) intent.getExtras().get("peer");
			ovxView.setParameter("ovx-session", sessionId);
			OPX.invite_accept(ovxView, peer, sessionId);
			ovxView.call();
			

		}
	}

	protected void getContactNumber()
	{
		Intent i = new Intent(Intent.ACTION_GET_CONTENT);
		i.setType(ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE);
		startActivityForResult(i, PICK);

	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		switch (requestCode) {
		case PICK:

			if (data != null) {
				Uri uri = data.getData();
				if (uri != null) {
					Cursor c = null;

					try {
						c = getContentResolver()
								.query(uri,
										new String[] {
												ContactsContract.CommonDataKinds.Phone.NUMBER,
												ContactsContract.CommonDataKinds.Phone.TYPE },
										null, null, null);

						if (c != null && c.moveToFirst()) {
							String number = c.getString(0);
							int type = c.getInt(1);

							showSelectedNumber(type, number);
						}
					} finally {
						if (c != null) {
							c.close();
						}
					}
				}

			}

			break;

		default:
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

	public void showSelectedNumber(int type, String number)
	{
		Toast.makeText(this, "Selected Number" + ": " + number,
				Toast.LENGTH_LONG).show();

		String contact_number = number.replaceAll("[^0-9\\+]", "");

		Log.d("INDUS", "Valid Phone Number:"
				+ isValidPhoneNumber(contact_number));

		if (contact_number.startsWith("+")) {
			contact_number = contact_number.replace("+", "");
		}

		inv_text.setText(contact_number);

	}

	public boolean isValidPhoneNumber(CharSequence phoneNumber)
	{
		if (!TextUtils.isEmpty(phoneNumber)) {
			return Patterns.PHONE.matcher(phoneNumber).matches();
		}

		return false;
	}

	public final static boolean isValidEmail(CharSequence target)
	{
		if (target == null) {
			return false;
		} else {
			return android.util.Patterns.EMAIL_ADDRESS.matcher(target)
					.matches();
		}
	}

	public boolean containsOnlyDigits(String str)
	{
		if (str == null || str.length() == 0)
			return false;

		for (int i = 0; i < str.length(); i++) {
			// If we find a non-digit character we return false.
			if (!Character.isDigit(str.charAt(i)))
				return false;

		}
		return true;

	}

	/*
	 * SDK method to update orientation .Must use in onWindowFocus method for
	 * updation of LocalView
	 */

	@Override
	public void onWindowFocusChanged(boolean hasFocus)
	{
		// TODO Auto-generated method stub

		if (hasFocus)
			ovxView.updateVideoOrientation();

		Log.d("OVX", "OnWindow Focus calling  updateVideo Orientation");
		super.onWindowFocusChanged(hasFocus);
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig)
	{

		// don't reload the current page when the orientation is changed
		Log.d("OVX", "onConfigurationChanged() Called");
		super.onConfigurationChanged(newConfig);

		ovxView.setRemoteViewX(100);
		ovxView.setRemoteViewY(100);

		/*
		 * Should be called to update the dimensions and position of the video
		 * view that had been changed after the call was started or to resume
		 * the video stream if it had been paused while launching another
		 * activity.
		 */

		if (ovxView.isCallOn())
			ovxView.updateVideoOrientation();

	}

	@Override
	public void onDestroy()
	{
		super.onDestroy();

	
	}

	// generic dialog used to display messages


	public void showDialog(String title, String session_id, String peer)
	{

		final AlertDialog.Builder lmenu_dialog = new AlertDialog.Builder(this);
		final String sessvalue = session_id;
		final String peername = peer;

		lmenu_dialog.setTitle(title);

		lmenu_dialog.setPositiveButton("Answer",
				new DialogInterface.OnClickListener()
				{

					public void onClick(DialogInterface dialog, int id)
					{

						try {
							if (player.isPlaying()) {
								player.stop();

							}

							if (notmgr != null) {
								notmgr.cancel(0);
							}

							/*
							 * Before accepting have to set the groupid to
							 * connect in to the same room
							 */

							ovxView.setParameter("ovx_session", sessvalue);

							accepted_rejectedclicked = true;

							OPX.invite_accept(ovxView, peername, sessvalue);
							ovxView.call();
							chat_box.append("\n" +"Invite Request from "+peername+"Accepted");
							chat_box.setMovementMethod(new ScrollingMovementMethod());
							focusOnText();

						}

						catch (OVXException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
				});

		lmenu_dialog.setNegativeButton("Reject",
				new DialogInterface.OnClickListener()
				{
					public void onClick(DialogInterface dialog, int id)
					{
						if (player.isPlaying()) {
							player.stop();

						}
						if (notmgr != null) {
							notmgr.cancel(0);
						}
						accepted_rejectedclicked = true;

						OPX.invite_rejected(ovxView, peername, sessvalue);

						chat_box.append("\n" +"Invite Request from "+peername+"Rejected");
						chat_box.setMovementMethod(new ScrollingMovementMethod());
						focusOnText();
					}
				});

		final AlertDialog ad_dialog = lmenu_dialog.create();

		ad_dialog.show();

		/*
		 * Set the timer for 10secs to answer.. If not responded(else) send
		 * expired request
		 */

		final Handler handler = new Handler();
		final Runnable runnable = new Runnable()
		{

			@Override
			public void run()
			{
				if (ad_dialog.isShowing()) {
					if (player.isPlaying()) {

						player.stop();

					}
					ad_dialog.dismiss();

					if (notmgr != null) {
						notmgr.cancel(0);
					}
					OPX.invite_expired(ovxView, peername, sessvalue);

					Toast.makeText(currentActivity,
							"Timer expired to Response", Toast.LENGTH_LONG)
							.show();

				}
			}
		};

		handler.postDelayed(runnable, 10000);

	}

	/*
	 * * We can listen to call related events like call started , call ended ,
	 * call failed and perform appropriate actions in these callback functions,
	 * we can also receive messages sent from the other parties in the
	 * conference using the call listener.
	 */

	public void callListener()
	{
		/** call back listener to listen to call events */

		ovxView.setCallListener(new OVXCallListener()
		{

			private Builder lmenu;
			private String reg_type;
			private AlertDialog callback_dialog;

			/* invoked when the call has been disconnected by the user. */

			@Override
			public void callEnded()
			{
				// TODO Auto-generated method stub

				Log.d("OVX", "Call Ended ");

				end_btn.setVisibility(View.INVISIBLE);
				accepted_rejectedclicked = false;
				end_call = false;
				chat_box.setText("");
				chat_box.setHint("Welcome to openclove");

			}

			/* invoked when the call fails due to some reasons. */

			@Override
			public void callFailed()
			{
				// TODO Auto-generated method stub
				chat_box.clearComposingText();
				chat_box.setHint("Welcome to openclove");
				accepted_rejectedclicked = false;
				end_call = false;
				end_btn.setVisibility(View.INVISIBLE);

			}

			/* invoked when the call has been established. */

			@Override
			public void callStarted()
			{
				Log.d("OVX", "Call Started");

				if (end_call) {
					if (ovxView.isCallOn()) {
						ovxView.exitCall();
						return;
					}
				}
				end_btn.setVisibility(View.VISIBLE);

			}

			/*
			 * * ovxReceivedData call back is called when data is received on
			 * Data Channel. SDK sends different types of data on this channel-
			 * info/ control/ participants/chat etc. The data content received
			 * is processed here according to type of data. chat view is updated
			 * with data received.
			 */

			@Override
			public void ovxReceivedData(String arg0)
			{
				Uri uri = Uri.parse("http://dummyserver.com?" + arg0);

				String type = uri.getQueryParameter("type");
				String data = uri.getQueryParameter("data");
				String sender = uri.getQueryParameter("sender");
				// TODO Auto-generated method stub

				Log.d("OVX", "Received message from ac_server:" + arg0);

				/**********
				 * if(type.equals("info")) // information/notifications for
				 * Group Chat { Log.d("INDUS","Info From :"+type+sender+data);
				 * 
				 * } else if (type.equals("control")) //Control information
				 * showing the current status of video View {
				 * Log.d("INDUS","Control Info :"+type+sender+data); } else
				 * if(type.equals("participants"))// informations related
				 * participants in Group Chat {
				 * Log.d("INDUS","Participants:"+type+sender+data); } else
				 * if(type.equals("chat")) //chat messages received from other
				 * participants { Log.d("INDUS","Chat:"+type+sender+data); }
				 * else {
				 * Log.d("INDUS","Remaining type like 'link','image' :"+type
				 * +sender+data); }
				 *************/

				chat_box.setMovementMethod(new ScrollingMovementMethod());

				if (chat_box.getText().toString()
						.equals("Welcome to openclove"))
					chat_box.setText(sender + " : " + data);
				else
					chat_box.append("\n" + sender + " : " + data);

				chat_box.setTextColor(Color.BLACK);
				focusOnText();

			}

			/* invoked when the call has been terminated due to n/w issues. */

			@Override
			public void callTerminated(String arg0)
			{
				// TODO Auto-generated method stub
				chat_box.clearComposingText();
				chat_box.setHint("Welcome to openclove");
				accepted_rejectedclicked = false;
				end_btn.setVisibility(View.INVISIBLE);

			}

			/* invoked When video Recording started */

			@Override
			public void recordedCallStart()
			{
				// TODO Auto-generated method stub
				Log.d("OVX", "Recording Started");
			}

			/*
			 * invoked When video Recording stopped with generated url as a
			 * parameter.To retrieve recorded file use parameter value
			 */

			@Override
			public void recordedCallStop(String arg0)

			{
				// TODO Auto-generated method stub
				videourl = arg0;
				Log.d("OVX", "Recorded Url.. " + videourl);

			}

			/* invoked Broadcast link to view the conference video */

			@Override
			public void onNotificationEvent(String arg0, String arg1)
			{
				// TODO Auto-generated method stub
				String event_type = arg0;
				String data_url = arg1;

				if (event_type.equals("broadcastUrl")) {
					Log.d("OVX", "Broadcast url:" + data_url);
				}

			}

			/*
			 * OPX Callback Peer Messages will be received when particular
			 * OPXMessaging request has been sent To do operations on this data
			 * ,run it on UI thread ..
			 */

			@Override
			public void opxAuthenticationFailed(String arg0)
			{
				// TODO Auto-generated method stub
				runOnUiThread(new Runnable()
				{
					public void run()
					{

						inv_text.setVisibility(View.INVISIBLE);

						inv_btn.setVisibility(View.INVISIBLE);

						pick_number.setVisibility(View.INVISIBLE);
						chat_box.append("\n" + "Authentication Failed");
						chat_box.setMovementMethod(new ScrollingMovementMethod());
						focusOnText();

					}
				});

			}

			@Override
			public void opxConnectionClosed(int arg0, String arg1)
			{
				// TODO Auto-generated method stub
				runOnUiThread(new Runnable()
				{
					public void run()
					{

						inv_text.setVisibility(View.INVISIBLE);

						inv_btn.setVisibility(View.INVISIBLE);

						pick_number.setVisibility(View.INVISIBLE);
						chat_box.append("\n" + "Connection Closed" );
						chat_box.setMovementMethod(new ScrollingMovementMethod());
						focusOnText();

					}
				});
			}

			@Override
			public void opxConnectionFailed(String arg0)
			{
				// TODO Auto-generated method stub

				runOnUiThread(new Runnable()
				{
					public void run()
					{

						inv_text.setVisibility(View.INVISIBLE);

						inv_btn.setVisibility(View.INVISIBLE);

						pick_number.setVisibility(View.INVISIBLE);
					
						chat_box.setMovementMethod(new ScrollingMovementMethod());
						focusOnText();

					}
				});

			}

			@Override
			public void opxConnectionReady()
			{
				// TODO Auto-generated method stub

				Log.d("INDUS", "Connection Ready");
				runOnUiThread(new Runnable()
				{

					@Override
					public void run()
					{
						inv_text.setVisibility(View.VISIBLE);
						ovx_text.setEnabled(true);
						inv_text.setEnabled(true);

						inv_btn.setVisibility(View.VISIBLE);
						pick_number.setVisibility(View.VISIBLE);

						chat_box.append("\n"+"OPX-"
								+ OPXApplication.getOPXUsername()
								+ " Registered  " );
						Intent mAlarmIntent = new Intent(currentActivity,
								OPXAlarmManager.class);

						sendBroadcast(mAlarmIntent);
						chat_box.setMovementMethod(new ScrollingMovementMethod());
						focusOnText();

					}
				});

			}

			@Override
			public void opxDidReceiveMessage(String arg0)
			{
				// TODO Auto-generated method stub

				Log.d("INDUS", "Peer Message Receiving:" + arg0);

				// lmenu = new AlertDialog.Builder(currentActivity);
				// callback_dialog=lmenu.create();
				String msg_type = null;
				String invite_msgtype = null;
				String errorcode = null;
				String reason = null;
				String fromid = null;
				String apiKey = null;
				String peerName = null;
				String sessionId = null;
				JSONObject request;

				try {

					request = new JSONObject(arg0);

					msg_type = (String) request.get("msgtype");

					fromid = (String) request.get("fromid");
					if (fromid.equals("SERVER"))
						return;

					apiKey = fromid.split(":")[0];
					peerName = fromid.split(":")[1];

					String data = (String) request.getString("data");

					JSONObject jdata = new JSONObject(data);
					invite_msgtype = (String) jdata.get("msg_type");
					sessionId = (String) jdata.get("session_id");

				}

				catch (JSONException e) {

					e.printStackTrace();
				}

				if (msg_type.equals("MSG_REQUEST")) {

					// showalert to accept or reject

					final String sessvalue = sessionId;
					final String peername = peerName;

					if (invite_msgtype.equals("INVITE_ACCEPTED")) 
					{
						Log.d("INDUS", "Peer Invite Message Received:"
								+ invite_msgtype);
						currentActivity.runOnUiThread(new Runnable()
						{
							
							@Override
							public void run()
							{
								// TODO Auto-generated method stub
					
								chat_box.append("\n" + "OPX:"
										+ "Invite Request accepted from"
										+ peername );
								chat_box.setMovementMethod(new ScrollingMovementMethod());
								focusOnText();
							}
						});
					
					}

					else if (invite_msgtype.equals("INVITE_EXPIRED")) {
						// alert("No Response from Invited User");

						Log.d("INDUS", "Peer Invite Message Received:"
								+ invite_msgtype);
						currentActivity.runOnUiThread(new Runnable()
						{

							@Override
							public void run()
							{
								// TODO Auto-generated method stub

								if (ovxView.isCallOn())
									ovxView.exitCall();
								
								chat_box.append("\n" + "OPX:"
										+ "Invite Request Expired by"
										+ peername );
								chat_box.setMovementMethod(new ScrollingMovementMethod());
								focusOnText();
								
								CharSequence[] ch = { "No Response from Invite User" };
								showDialog("Engage Chat", ch);
							}
						});

					}

					else if (invite_msgtype.equals("INVITE_REJECTED")) {
						Log.d("INDUS", "Peer Invite Message Received:"
								+ invite_msgtype);
						// alert("Call has been rejected");
						currentActivity.runOnUiThread(new Runnable()
						{

							@Override
							public void run()
							{

								end_call = true;
								if (ovxView.isCallOn()) {
									ovxView.exitCall();
								}

								CharSequence[] ch = { "Call has been Rejected" };
								showDialog("Engage Chat", ch);
								
								chat_box.append("\n" + "OPX:"
										+ "Invite Request rejected by"
										+ peername );
								chat_box.setMovementMethod(new ScrollingMovementMethod());
								focusOnText();
							}
						});

					}

					else if (invite_msgtype.equals("INVITE_REQUEST")) {

						Log.d("INDUS", "Peer Invite Message Received:"
								+ invite_msgtype);

						currentActivity.runOnUiThread(new Runnable()
						{

							@Override
							public void run()
							{
								// TODO Auto-generated method stub

								
								chat_box.append("\n" +"Received OPX Invite Request from "+peername);
								chat_box.setMovementMethod(new ScrollingMovementMethod());
								focusOnText();
								
								if (!ovxView.isCallOn()) {
									/*
									 * Playing the audio file once the invite
									 * request came
									 */

									
									play_audio();
									
									showDialog("Engage Chat", sessvalue,
											peername);

									launchNtfctn(peername, sessvalue);

								} else {
									/*
									 * When call is already on send expired
									 * request(Based on requirement)
									 */

									OPX.invite_expired(ovxView, peername,
											sessvalue);

									chat_box.append("\n" + "OPX:" + peername
											+ " Sent request to you");

									Log.d("INDUS",
											" Sending expired request to invitee if already"
													+ "call is on");
								}

							}

							private void play_audio()
							{
								// TODO Auto-generated method stub

								AssetFileDescriptor afd;

								try {

									afd = getAssets().openFd("ringtone.wav");
									player = new MediaPlayer();
									player.setDataSource(
											afd.getFileDescriptor(),
											afd.getStartOffset(),
											afd.getLength());
									player.prepare();
									player.start();

								} catch (IOException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}

							}

						});

					}
				}

				else if (msg_type.equals("MSG_RESPONSE")) {

					Log.d("INDUS", "Message Response:" + arg0);
					final String session_id = sessionId;

					try {
						request = new JSONObject(arg0);
						errorcode = (String) request.get("errorcode");
						reason = (String) request.get("reason");
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

					final String reason_message = reason;

					/*
					 * Once the invitee not registered You will get errorcode
					 * with "1".. Reason with User not reachable
					 */

					if (!errorcode.equals("0")) {
						// User not reachable alert
						currentActivity.runOnUiThread(new Runnable()
						{

							@Override
							public void run()
							{
								chat_box.append("\n" + "OPX:"
										+ reason_message );
								chat_box.setMovementMethod(new ScrollingMovementMethod());
								focusOnText();
								CharSequence[] ch = { reason_message };
								showDialog("Engage Chat", ch);
							}
						});

					}

					else {
						if (invite_msgtype.contains("INVITE_ACCEPTED")) {

							Log.d("INDUS", "Invite Accepted Message Response");

						}

						if (invite_msgtype.contains("INVITE_REQUEST")) {
							try {
								ovxView.setLatency(0);
								ovxView.setParameter("ovx-session", session_id);
								ovxView.call();
							
								Log.d("INDUS",
										"Call Status:" + ovxView.isCallOn());
							} catch (OVXException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}

							Log.d("INDUS", "Invite Request Message Response");

						}
					}
				}

			}

		});

	}

	void showDialog(String title, CharSequence[] items)
	{

		OVXLog.d("INDUS", "function showdialog");
		final CharSequence[] fitems = items;

		AlertDialog.Builder lmenu = new AlertDialog.Builder(currentActivity);

		final AlertDialog ad = lmenu.create();
		lmenu.setTitle(title);
		lmenu.setMessage(fitems[0]);
		lmenu.setPositiveButton("OK", new DialogInterface.OnClickListener()
		{
			public void onClick(DialogInterface dialog, int id)
			{
				ad.dismiss();
			}
		});
		lmenu.show();

	}

	@Override
	public void onResume()
	{

		super.onResume();
		Log.d("OVX", "OnResume:" + this);

	}

	@Override
	public void onPause()
	{
		super.onPause();
		Log.d("OVX", "On Pause");

	}

	private void focusOnText()
	{

		/*
		 * * find the amount we need to scroll. This works by asking the
		 * TextView's internal layout for the position of the final line and
		 * then subtracting the TextView's height
		 */

		final int scrollAmount = chat_box.getLayout().getLineTop(
				chat_box.getLineCount())
				- chat_box.getHeight();
		// if there is no need to scroll, scrollAmount will be <=0
		if (scrollAmount > 0)
			chat_box.scrollTo(0, scrollAmount);
		else
			chat_box.scrollTo(0, 0);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (notmgr != null) {
				notmgr.cancel(0);
			}

			OPXApplication.setUIState(false);
			OPXApplication.setOVXListener();
			finish();
			return true;
		}
		// return false;
		return super.onKeyDown(keyCode, event);
	}

	@SuppressWarnings("deprecation")
	private void launchNtfctn(final String peer, final String session_id)
	{
		// TODO Auto-generated method stub
		notmgr = (NotificationManager) currentActivity
				.getSystemService(currentActivity.NOTIFICATION_SERVICE);

		Intent intent = new Intent(currentActivity, EngageChat.class);

		PendingIntent pi = PendingIntent.getActivity(currentActivity, 1,
				intent, 0);

		Vibrator vb = (Vibrator) currentActivity
				.getSystemService(currentActivity.VIBRATOR_SERVICE);

		long[] pattern = { 0, 100, 600, 100, 700 };

		vb.vibrate(pattern, -1);

		noti = new Notification(R.drawable.phoneicon, "Engage Chat",
				System.currentTimeMillis());
		noti.setLatestEventInfo(currentActivity, "EngageChat", peer
				+ "  is Calling..", pi);

		// noti.flags |= Notification.FLAG_AUTO_CANCEL;

		noti.number += 5;// number of times to show the icon in the status bar

		noti.flags |= Notification.FLAG_SHOW_LIGHTS;// How the notifcations
		// should be like in the
		// seeker content after
		// clicking ...
		notmgr.notify(0, noti);// Using Mgr to show the
		// notifications...

	}

}
