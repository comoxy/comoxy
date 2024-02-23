package com.rating.buzzle;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.provider.Settings;
import android.util.Base64;

import androidx.annotation.NonNull;

import java.security.SecureRandom;
import java.util.HashMap;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "RATE_REVIEW_APP_METHOD_CHANNEL";
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 16;

    static {
        System.loadLibrary("native-lib");
    }

    public static native String EncryptionKey();

    public static native String SecretKey();


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {

                            switch (call.method) {
                                case "getToken": {
                                    String personId = call.argument("data");
                                    String secureId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
                                    personId = personId + "-" + secureId;
                                    SecretKey password = generateKey();

                                    String encryptedData = null;
                                    try {
                                        encryptedData = encryptMsg_New(personId, password);
                                        result.success(encryptedData);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                    break;
                                }
                                case "getPlatformDetail": {
                                    PackageManager pm = getApplicationContext().getPackageManager();
                                    PackageInfo info = null;
                                    try {
                                        info = pm.getPackageInfo(getApplicationContext().getPackageName(), 0);
                                        HashMap<String, Object> map = new HashMap<>();
                                        // map["appName"] = info.applicationInfo.loadLabel(pm).toString()

                                        map.put("packageName", getApplicationContext().getPackageName());
                                        map.put("version", info.versionCode);
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                            map.put("buildNumber", info.getLongVersionCode());
                                        }

                                        result.success(map);
                                    } catch (PackageManager.NameNotFoundException e) {
                                        e.printStackTrace();
                                    }
                                    break;
                                }
                                case "getEncryptedPassword": {
                                    String personId = call.argument("data");
                                    String passwordData = call.argument("password");

                                    personId = passwordData + personId;
                                    SecretKey password = generateKey();

                                    String encryptedData = null;
                                    try {
                                        encryptedData = encryptMsg_New(personId, password);
                                        result.success(encryptedData);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                    break;
                                }
                                case "internetConnectivity": {
                                    result.success(isInternetConnection(MainActivity.this));
                                    break;
                                }
                                case "getEncryptionKey": {
                                    result.success(EncryptionKey());
                                    break;
                                }
                                case "getSecretKey": {
                                    result.success(SecretKey());
                                    break;
                                }
                                case "saveSharedPref": {
                                    String sharePref = call.argument("sharePref");
                                    String map = call.argument("json");
                                    setAppPref(map, sharePref);
                                    result.success(true);
                                    break;
                                }
                                case "readSharedPref": {
                                    String sharePref = call.argument("sharePref");
                                    String prefValue = getAppPref(sharePref);
                                    result.success(prefValue);
                                    break;
                                }
                                case "removeSharedPref": {
                                    String sharePref = call.argument("sharePref");
                                    Boolean isRemoved = removeAppPref(sharePref);
                                    result.success(isRemoved);
                                    break;
                                }

                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }

    String myPref = "UserPref";

    void setAppPref(String myObject, String pefName) {
        SharedPreferences sharedPreferences = MainActivity.this.getApplicationContext().getSharedPreferences(myPref, Context.MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = sharedPreferences.edit();
        prefsEditor.putString(pefName, myObject);
        prefsEditor.apply();
    }

    String getAppPref(String pefName) {
        SharedPreferences sharedPreferences = MainActivity.this.getApplicationContext().getSharedPreferences(myPref, Context.MODE_PRIVATE);
        return sharedPreferences.getString(pefName, null);
    }

    boolean removeAppPref(String pefName) {
        SharedPreferences sharedPreferences = MainActivity.this.getApplicationContext().getSharedPreferences(myPref, Context.MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = sharedPreferences.edit();
        prefsEditor.remove(pefName).apply();
        return true;
    }
    
    private SecretKey generateKey() {
        return new SecretKeySpec(SecretKey().getBytes(), "AES");
    }


    boolean isInternetConnection(Activity context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnectedOrConnecting();
    }

    public static String encryptMsg_New(String privateString, SecretKey skey) throws Exception {
        byte[] iv = new byte[GCM_IV_LENGTH];
        (new SecureRandom()).nextBytes(iv);
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        GCMParameterSpec ivSpec = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            ivSpec = new GCMParameterSpec(GCM_TAG_LENGTH * Byte.SIZE, iv);
            cipher.init(Cipher.ENCRYPT_MODE, skey, ivSpec);
        }
        byte[] ciphertext = cipher.doFinal(privateString.getBytes("UTF-8"));
        byte[] encrypted = new byte[iv.length + ciphertext.length];
        System.arraycopy(iv, 0, encrypted, 0, iv.length);
        System.arraycopy(ciphertext, 0, encrypted, iv.length, ciphertext.length);
        String encoded = Base64.encodeToString(encrypted, Base64.DEFAULT);
        return encoded;
    }

}
