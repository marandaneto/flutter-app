import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tesla_android/common/ui/constants/ta_timing.dart';
import 'package:tesla_android/feature/touchscreen/model/pointer_state.dart';
import 'package:tesla_android/feature/touchscreen/transport/touchscreen_transport.dart';

@injectable
class TouchscreenCubit extends Cubit<bool> {
  final TouchscreenTransport _transport;
  StreamSubscription<bool>? _streamSubscription;

  TouchscreenCubit(this._transport) : super(false) {
    _connectWebSocket();
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    _transport.closeWebSocket();
    super.close();
  }

  void dispatchTouchEvent(int index, Offset offset, bool isBeingTouched,
      BoxConstraints constraints) {
    final scaleX = touchScreenMaxX / constraints.maxWidth;
    final scaleY = touchScreenMaxY / constraints.maxHeight;

    var scaledOffset = offset.scale(scaleX, scaleY);

    if (scaledOffset.dx.isNegative) {
      scaledOffset = Offset(0, scaledOffset.dy);
    }

    if (scaledOffset.dy.isNegative) {
      scaledOffset = Offset(scaledOffset.dx, 0);
    }

    final newPointerState = PointerState(
      trackingId: index,
      position: scaledOffset,
      isBeingTouched: isBeingTouched,
    );

    _transport.sendMessage(newPointerState.toVirtualTouchScreenEvent());
  }

  void _connectWebSocket() {
    _transport.connectWebSocket();
  }
}
