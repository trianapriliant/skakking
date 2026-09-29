import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chess_models.dart';
import 'game_controller.dart';

final gameControllerProvider = NotifierProvider<GameController, GameUiState>(
  GameController.new,
);
