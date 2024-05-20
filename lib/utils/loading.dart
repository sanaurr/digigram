import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading with ChangeNotifier {
  bool _state = false;
  void on() {
    _state = true;
    notifyListeners();
  }

  void off() {
    _state = false;
    notifyListeners();
  }

  Future<void> load(Future<void> Function() callback) async {
    on();
    await callback();
    off();
  }

  bool get state => _state;
}

extension LoadingWidget on Loading {
  Widget build(Widget child, BuildContext context) {
    return Stack(
      children: [
        child,
        if (state)
          Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: LoadingAnimationWidget.inkDrop(
              // leftDotColor: const Color(0xFF1A1A3F),
              // rightDotColor: const Color(0xFFEA3799),
              color: Color.fromARGB(255, 218, 12, 225),
              size: 150,
            ),
          ),
      ],
    );
  }
}

extension LoadingFunction on BuildContext {
  void load(Future<void> Function() callback) => read<Loading>().load(callback);
}
