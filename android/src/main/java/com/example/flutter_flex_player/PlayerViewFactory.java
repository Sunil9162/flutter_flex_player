package com.example.flutter_flex_player;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PlayerViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public PlayerViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object o) {
        return new PlayerView(context, messenger,id);
    }
}
