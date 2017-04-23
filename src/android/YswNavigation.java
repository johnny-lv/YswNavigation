package com.yaoshangwang.yswapp.plugins.nav;

import android.content.Intent;
import android.net.Uri;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class YswNavigation extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("showNav")) {
            JSONObject navObject = args.getJSONObject(0);
            int mapType = navObject.getInt("mapType");
            double slat = navObject.getDouble("slat");
            double slng = navObject.getDouble("slng");
            String sname = navObject.getString("sname");
            double dlat = navObject.getDouble("dlat");
            double dlng = navObject.getDouble("dlng");
            String dname = navObject.getString("dname");
            this.showNav(mapType, slat, slng, sname, dlat, dlng, dname, callbackContext);
            return true;
        }
        return false;
    }

    private void showNav(int mapType, double slat, double slng, String sname, double dlat, double dlng, String dname, CallbackContext callbackContext) {
        boolean isAppInstalled = true;
        switch (mapType) {
            case 0: {
                if(OpenLocalMapUtil.isGdMapInstalled()) {
                    openGaoDeMap(slat, slng, sname, dlat, dlng, dname);
                } else {
                    isAppInstalled = false;
                }
            }
            break;
            case 1: {
                if(OpenLocalMapUtil.isBaiduMapInstalled()) {
                    openBaiduMap(slat, slng, sname, dlat, dlng, dname);
                } else {
                    isAppInstalled = false;
                }
            }
            break;
        }
        callbackContext.success(isAppInstalled + "");
    }

    /**
     *  打开百度地图
     */
    private void openBaiduMap(double slat, double slng, String sname, double dlat, double dlng, String dname) {
        try {
            String uri = OpenLocalMapUtil.getBaiduMapUri(String.valueOf(slat), String.valueOf(slng), sname,
                    String.valueOf(dlat), String.valueOf(dlng), dname, "", "1");
            final Intent intent = Intent.parseUri(uri, 0);
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    YswNavigation.this.cordova.getActivity().startActivity(intent);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 打开高德地图
     */
    private void openGaoDeMap(double slat, double slng, String sname, double dlat, double dlng, String dname) {
        try {
            double[] sLatLng = OpenLocalMapUtil.bdToGaoDe(slat, slng);
            double[] dLatLng = OpenLocalMapUtil.bdToGaoDe(dlat, dlng);
            String uri = OpenLocalMapUtil.getGdMapUri("com.yaoshangwang.yswapp", String.valueOf(sLatLng[0]), String.valueOf(sLatLng[1]),
                    sname, String.valueOf(dLatLng[0]), String.valueOf(dLatLng[1]), dname);
            final Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setPackage("com.autonavi.minimap");
            intent.setData(Uri.parse(uri));
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    YswNavigation.this.cordova.getActivity().startActivity(intent);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 打开浏览器进行百度地图导航
     */
    /*private void openWebMap(double slat, double slon, String sname, double dlat, double dlon, String dname, String city){
        Uri mapUri = Uri.parse(OpenLocalMapUtil.getWebBaiduMapUri(String.valueOf(slat), String.valueOf(slon), sname,
                String.valueOf(dlat), String.valueOf(dlon),
                dname, city, APP_NAME));
        Intent loction = new Intent(Intent.ACTION_VIEW, mapUri);
        startActivity(loction);
    }*/
}
