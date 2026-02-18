import 'package:flutter/material.dart';

class AgentBallanceProvider extends ChangeNotifier {
  int _ballanceInToman = 0;
  int get ballanceInToman => _ballanceInToman;
  double _ballanceInDollar = 0.0;
  double get ballanceInDollar => _ballanceInDollar;
  setAgentBallenceInToman(int newBallamce) {
    _ballanceInToman = newBallamce;
    notifyListeners();
  }

  increaseBallanceInToman(int val) {
    _ballanceInToman += val;
    notifyListeners();
  }

  decreaseBallanceInToman(int val) {
    _ballanceInToman -= val;
    notifyListeners();
  }

  increaseBallanceInDollar(double val) {
    _ballanceInDollar += val;
    notifyListeners();
  }

  decreaseBallanceInDollar(double val) {
    _ballanceInDollar -= val;
    notifyListeners();
  }

  setAgentBallenceInDollar(double newBallamce) {
    _ballanceInDollar = newBallamce;
    notifyListeners();
  }
}
