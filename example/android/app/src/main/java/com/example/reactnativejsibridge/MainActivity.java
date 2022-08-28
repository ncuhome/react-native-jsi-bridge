package com.example.reactnativejsibridge;

import android.os.Bundle;
import android.util.Log;

import com.facebook.react.ReactActivity;
import com.reactnativejsibridge.JsiBridge;

public class MainActivity extends ReactActivity {

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  @Override
  protected String getMainComponentName() {
    return "JsiBridgeExample";
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    JsiBridge.off("jsData");
    JsiBridge.on("jsData", data -> {
      JsiBridge.emit("onData", data);
    });
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    JsiBridge.off("jsData");
  }
}
