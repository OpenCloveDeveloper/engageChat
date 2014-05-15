package com.example.engageChat;


import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

public class SplashScreen extends Activity {
	private AnimationDrawable animation;
	private int screen_width;
	private int screen_height;

	@Override
	public void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		screen_width = getWindowManager().getDefaultDisplay().getWidth();
		screen_height = getWindowManager().getDefaultDisplay().getHeight();
		setSplashScreen();

		Handler handler = new Handler();

		// run a thread after 2 seconds to start the home screen
		handler.postDelayed(new Runnable() {

			@Override
			public void run() {

				// make sure we close the splash screen so the user won't come
				// back when it presses back key

				finish();
				// start the home screen

				Intent intent = new Intent(SplashScreen.this, EngageChat.class);
				
				
				SplashScreen.this.startActivity(intent);
				
			}

		}, 2000);
	}

	public void setSplashScreen() {
		animation = new AnimationDrawable();
		animation.addFrame(getResources().getDrawable(R.drawable.img1), 100);
		animation.addFrame(getResources().getDrawable(R.drawable.img2), 500);
		animation.addFrame(getResources().getDrawable(R.drawable.img3), 500);
		animation.addFrame(getResources().getDrawable(R.drawable.img4), 500);
		animation.addFrame(getResources().getDrawable(R.drawable.img5), 500);
		animation.setOneShot(false);

		// layout = (RelativeLayout) findViewById(R.id.relative);
		FrameLayout.LayoutParams flp = new FrameLayout.LayoutParams(
				screen_width, screen_height);
		RelativeLayout rl = new RelativeLayout(this);
		RelativeLayout.LayoutParams rlp = new RelativeLayout.LayoutParams(
				screen_width, screen_height);
		ImageView imageAnim = new ImageView(this);

		imageAnim.setBackgroundDrawable(animation);
		imageAnim.setLayoutParams(rlp);
		rl.addView(imageAnim, rlp);
		// imageAnim.requestLayout();
		// layout.requestLayout();
		addContentView(rl, flp);
		// run the start() method later on the UI thread
		imageAnim.post(new Starter());
	}

	class Starter implements Runnable {

		public void run() {

			animation.start();
		}
	}

}
