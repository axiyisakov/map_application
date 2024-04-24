package com.example.map_application

import android.app.Activity
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);
    MapKitFactory.setApiKey("YANDEX_MAP_API_KEY");
    }
}

