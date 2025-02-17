import 'package:flutter/material.dart';

class ScoreModel with ChangeNotifier {
  int _team1Score = 0;
  int _team2Score = 0;
  int _winningScore = 152;

  // History stacks for undo functionality
  final List<int> _team1History = [];
  final List<int> _team2History = [];
  final List<int> _team1Inputs = [];
  final List<int> _team2Inputs = [];

  int get team1Score => _team1Score;
  int get team2Score => _team2Score;
  int get winningScore => _winningScore;
  List<int> get team1Inputs => _team1Inputs;
  List<int> get team2Inputs => _team2Inputs;
  Function(String team, int team1Score, int team2Score)? onWin;

  void addPointsToTeam1(int points) {
    _team1History.add(_team1Score);
    _team1Score += points;
    _team1Inputs.add(points);
    if (_team1Score >= _winningScore) {
      onWin?.call("لنا", _team1Score, _team2Score);
    }
    notifyListeners();
  }

  void addPointsToTeam2(int points) {
    _team2History.add(_team2Score);
    _team2Score += points;
    _team2Inputs.add(points);
    if (_team2Score >= _winningScore) {
      onWin?.call("لهم", _team1Score, _team2Score);
    }
    notifyListeners();
  }

  void resetScores() {
    _team1Score = 0;
    _team2Score = 0;
    _team1History.clear();
    _team2History.clear();
    _team1Inputs.clear();
    _team2Inputs.clear();
    notifyListeners();
  }

  void undoLastAction() {
    if (_team1History.isNotEmpty && _team1Inputs.isNotEmpty) {
      _team1Score = _team1History.removeLast();
      _team1Inputs.removeLast();
    }
    if (_team2History.isNotEmpty && _team1Inputs.isNotEmpty) {
      _team2Score = _team2History.removeLast();
      _team2Inputs.removeLast();
    } else {
      resetScores();
    }
    notifyListeners();
  }

  // void onWin(int _team1Score, int _team2Score) {
  //   if (_team1Score >= _winningScore) {
  //     _team1Score;
  //   }
  //   if (_team2Score >= _winningScore) {
  //     _team2Score;
  //   }
  //   notifyListeners();
  // }
}
