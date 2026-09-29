// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, GameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerColorMeta = const VerificationMeta(
    'playerColor',
  );
  @override
  late final GeneratedColumn<String> playerColor = GeneratedColumn<String>(
    'player_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fenMeta = const VerificationMeta('fen');
  @override
  late final GeneratedColumn<String> fen = GeneratedColumn<String>(
    'fen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('in_progress'),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    updatedAt,
    mode,
    difficulty,
    playerColor,
    fen,
    status,
    outcome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('player_color')) {
      context.handle(
        _playerColorMeta,
        playerColor.isAcceptableOrUnknown(
          data['player_color']!,
          _playerColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playerColorMeta);
    }
    if (data.containsKey('fen')) {
      context.handle(
        _fenMeta,
        fen.isAcceptableOrUnknown(data['fen']!, _fenMeta),
      );
    } else if (isInserting) {
      context.missing(_fenMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      playerColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_color'],
      )!,
      fen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fen'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class GameRow extends DataClass implements Insertable<GameRow> {
  final int id;
  final DateTime startedAt;
  final DateTime updatedAt;
  final String mode;
  final String difficulty;
  final String playerColor;
  final String fen;
  final String status;
  final String? outcome;
  const GameRow({
    required this.id,
    required this.startedAt,
    required this.updatedAt,
    required this.mode,
    required this.difficulty,
    required this.playerColor,
    required this.fen,
    required this.status,
    this.outcome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['mode'] = Variable<String>(mode);
    map['difficulty'] = Variable<String>(difficulty);
    map['player_color'] = Variable<String>(playerColor);
    map['fen'] = Variable<String>(fen);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      updatedAt: Value(updatedAt),
      mode: Value(mode),
      difficulty: Value(difficulty),
      playerColor: Value(playerColor),
      fen: Value(fen),
      status: Value(status),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
    );
  }

  factory GameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRow(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      mode: serializer.fromJson<String>(json['mode']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      playerColor: serializer.fromJson<String>(json['playerColor']),
      fen: serializer.fromJson<String>(json['fen']),
      status: serializer.fromJson<String>(json['status']),
      outcome: serializer.fromJson<String?>(json['outcome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'mode': serializer.toJson<String>(mode),
      'difficulty': serializer.toJson<String>(difficulty),
      'playerColor': serializer.toJson<String>(playerColor),
      'fen': serializer.toJson<String>(fen),
      'status': serializer.toJson<String>(status),
      'outcome': serializer.toJson<String?>(outcome),
    };
  }

  GameRow copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? updatedAt,
    String? mode,
    String? difficulty,
    String? playerColor,
    String? fen,
    String? status,
    Value<String?> outcome = const Value.absent(),
  }) => GameRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    mode: mode ?? this.mode,
    difficulty: difficulty ?? this.difficulty,
    playerColor: playerColor ?? this.playerColor,
    fen: fen ?? this.fen,
    status: status ?? this.status,
    outcome: outcome.present ? outcome.value : this.outcome,
  );
  GameRow copyWithCompanion(GamesCompanion data) {
    return GameRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      mode: data.mode.present ? data.mode.value : this.mode,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      playerColor: data.playerColor.present
          ? data.playerColor.value
          : this.playerColor,
      fen: data.fen.present ? data.fen.value : this.fen,
      status: data.status.present ? data.status.value : this.status,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mode: $mode, ')
          ..write('difficulty: $difficulty, ')
          ..write('playerColor: $playerColor, ')
          ..write('fen: $fen, ')
          ..write('status: $status, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    updatedAt,
    mode,
    difficulty,
    playerColor,
    fen,
    status,
    outcome,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.updatedAt == this.updatedAt &&
          other.mode == this.mode &&
          other.difficulty == this.difficulty &&
          other.playerColor == this.playerColor &&
          other.fen == this.fen &&
          other.status == this.status &&
          other.outcome == this.outcome);
}

class GamesCompanion extends UpdateCompanion<GameRow> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> updatedAt;
  final Value<String> mode;
  final Value<String> difficulty;
  final Value<String> playerColor;
  final Value<String> fen;
  final Value<String> status;
  final Value<String?> outcome;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mode = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.playerColor = const Value.absent(),
    this.fen = const Value.absent(),
    this.status = const Value.absent(),
    this.outcome = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required DateTime updatedAt,
    required String mode,
    required String difficulty,
    required String playerColor,
    required String fen,
    this.status = const Value.absent(),
    this.outcome = const Value.absent(),
  }) : startedAt = Value(startedAt),
       updatedAt = Value(updatedAt),
       mode = Value(mode),
       difficulty = Value(difficulty),
       playerColor = Value(playerColor),
       fen = Value(fen);
  static Insertable<GameRow> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? mode,
    Expression<String>? difficulty,
    Expression<String>? playerColor,
    Expression<String>? fen,
    Expression<String>? status,
    Expression<String>? outcome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (mode != null) 'mode': mode,
      if (difficulty != null) 'difficulty': difficulty,
      if (playerColor != null) 'player_color': playerColor,
      if (fen != null) 'fen': fen,
      if (status != null) 'status': status,
      if (outcome != null) 'outcome': outcome,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? updatedAt,
    Value<String>? mode,
    Value<String>? difficulty,
    Value<String>? playerColor,
    Value<String>? fen,
    Value<String>? status,
    Value<String?>? outcome,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      playerColor: playerColor ?? this.playerColor,
      fen: fen ?? this.fen,
      status: status ?? this.status,
      outcome: outcome ?? this.outcome,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (playerColor.present) {
      map['player_color'] = Variable<String>(playerColor.value);
    }
    if (fen.present) {
      map['fen'] = Variable<String>(fen.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mode: $mode, ')
          ..write('difficulty: $difficulty, ')
          ..write('playerColor: $playerColor, ')
          ..write('fen: $fen, ')
          ..write('status: $status, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }
}

class $GameMovesTable extends GameMoves
    with TableInfo<$GameMovesTable, MoveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameMovesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanMeta = const VerificationMeta('san');
  @override
  late final GeneratedColumn<String> san = GeneratedColumn<String>(
    'san',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromSquareMeta = const VerificationMeta(
    'fromSquare',
  );
  @override
  late final GeneratedColumn<String> fromSquare = GeneratedColumn<String>(
    'from_square',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toSquareMeta = const VerificationMeta(
    'toSquare',
  );
  @override
  late final GeneratedColumn<String> toSquare = GeneratedColumn<String>(
    'to_square',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    ply,
    san,
    fromSquare,
    toSquare,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_moves';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('san')) {
      context.handle(
        _sanMeta,
        san.isAcceptableOrUnknown(data['san']!, _sanMeta),
      );
    } else if (isInserting) {
      context.missing(_sanMeta);
    }
    if (data.containsKey('from_square')) {
      context.handle(
        _fromSquareMeta,
        fromSquare.isAcceptableOrUnknown(data['from_square']!, _fromSquareMeta),
      );
    } else if (isInserting) {
      context.missing(_fromSquareMeta);
    }
    if (data.containsKey('to_square')) {
      context.handle(
        _toSquareMeta,
        toSquare.isAcceptableOrUnknown(data['to_square']!, _toSquareMeta),
      );
    } else if (isInserting) {
      context.missing(_toSquareMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoveRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      san: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}san'],
      )!,
      fromSquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_square'],
      )!,
      toSquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_square'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $GameMovesTable createAlias(String alias) {
    return $GameMovesTable(attachedDatabase, alias);
  }
}

class MoveRow extends DataClass implements Insertable<MoveRow> {
  final int id;
  final int gameId;
  final int ply;
  final String san;
  final String fromSquare;
  final String toSquare;
  final DateTime playedAt;
  const MoveRow({
    required this.id,
    required this.gameId,
    required this.ply,
    required this.san,
    required this.fromSquare,
    required this.toSquare,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['ply'] = Variable<int>(ply);
    map['san'] = Variable<String>(san);
    map['from_square'] = Variable<String>(fromSquare);
    map['to_square'] = Variable<String>(toSquare);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  GameMovesCompanion toCompanion(bool nullToAbsent) {
    return GameMovesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      ply: Value(ply),
      san: Value(san),
      fromSquare: Value(fromSquare),
      toSquare: Value(toSquare),
      playedAt: Value(playedAt),
    );
  }

  factory MoveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoveRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      ply: serializer.fromJson<int>(json['ply']),
      san: serializer.fromJson<String>(json['san']),
      fromSquare: serializer.fromJson<String>(json['fromSquare']),
      toSquare: serializer.fromJson<String>(json['toSquare']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'ply': serializer.toJson<int>(ply),
      'san': serializer.toJson<String>(san),
      'fromSquare': serializer.toJson<String>(fromSquare),
      'toSquare': serializer.toJson<String>(toSquare),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  MoveRow copyWith({
    int? id,
    int? gameId,
    int? ply,
    String? san,
    String? fromSquare,
    String? toSquare,
    DateTime? playedAt,
  }) => MoveRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    ply: ply ?? this.ply,
    san: san ?? this.san,
    fromSquare: fromSquare ?? this.fromSquare,
    toSquare: toSquare ?? this.toSquare,
    playedAt: playedAt ?? this.playedAt,
  );
  MoveRow copyWithCompanion(GameMovesCompanion data) {
    return MoveRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      ply: data.ply.present ? data.ply.value : this.ply,
      san: data.san.present ? data.san.value : this.san,
      fromSquare: data.fromSquare.present
          ? data.fromSquare.value
          : this.fromSquare,
      toSquare: data.toSquare.present ? data.toSquare.value : this.toSquare,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoveRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('ply: $ply, ')
          ..write('san: $san, ')
          ..write('fromSquare: $fromSquare, ')
          ..write('toSquare: $toSquare, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameId, ply, san, fromSquare, toSquare, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoveRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.ply == this.ply &&
          other.san == this.san &&
          other.fromSquare == this.fromSquare &&
          other.toSquare == this.toSquare &&
          other.playedAt == this.playedAt);
}

class GameMovesCompanion extends UpdateCompanion<MoveRow> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> ply;
  final Value<String> san;
  final Value<String> fromSquare;
  final Value<String> toSquare;
  final Value<DateTime> playedAt;
  const GameMovesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.ply = const Value.absent(),
    this.san = const Value.absent(),
    this.fromSquare = const Value.absent(),
    this.toSquare = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  GameMovesCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int ply,
    required String san,
    required String fromSquare,
    required String toSquare,
    required DateTime playedAt,
  }) : gameId = Value(gameId),
       ply = Value(ply),
       san = Value(san),
       fromSquare = Value(fromSquare),
       toSquare = Value(toSquare),
       playedAt = Value(playedAt);
  static Insertable<MoveRow> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? ply,
    Expression<String>? san,
    Expression<String>? fromSquare,
    Expression<String>? toSquare,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (ply != null) 'ply': ply,
      if (san != null) 'san': san,
      if (fromSquare != null) 'from_square': fromSquare,
      if (toSquare != null) 'to_square': toSquare,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  GameMovesCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? ply,
    Value<String>? san,
    Value<String>? fromSquare,
    Value<String>? toSquare,
    Value<DateTime>? playedAt,
  }) {
    return GameMovesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      ply: ply ?? this.ply,
      san: san ?? this.san,
      fromSquare: fromSquare ?? this.fromSquare,
      toSquare: toSquare ?? this.toSquare,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (san.present) {
      map['san'] = Variable<String>(san.value);
    }
    if (fromSquare.present) {
      map['from_square'] = Variable<String>(fromSquare.value);
    }
    if (toSquare.present) {
      map['to_square'] = Variable<String>(toSquare.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameMovesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('ply: $ply, ')
          ..write('san: $san, ')
          ..write('fromSquare: $fromSquare, ')
          ..write('toSquare: $toSquare, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $GameMovesTable gameMoves = $GameMovesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [games, gameMoves];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_moves', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      required DateTime updatedAt,
      required String mode,
      required String difficulty,
      required String playerColor,
      required String fen,
      Value<String> status,
      Value<String?> outcome,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime> updatedAt,
      Value<String> mode,
      Value<String> difficulty,
      Value<String> playerColor,
      Value<String> fen,
      Value<String> status,
      Value<String?> outcome,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, GameRow> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameMovesTable, List<MoveRow>>
  _gameMovesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameMoves,
    aliasName: 'games__id__game_moves__game_id',
  );

  $$GameMovesTableProcessedTableManager get gameMovesRefs {
    final manager = $$GameMovesTableTableManager(
      $_db,
      $_db.gameMoves,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameMovesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerColor => $composableBuilder(
    column: $table.playerColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fen => $composableBuilder(
    column: $table.fen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameMovesRefs(
    Expression<bool> Function($$GameMovesTableFilterComposer f) f,
  ) {
    final $$GameMovesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameMoves,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameMovesTableFilterComposer(
            $db: $db,
            $table: $db.gameMoves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerColor => $composableBuilder(
    column: $table.playerColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fen => $composableBuilder(
    column: $table.fen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playerColor => $composableBuilder(
    column: $table.playerColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fen =>
      $composableBuilder(column: $table.fen, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  Expression<T> gameMovesRefs<T extends Object>(
    Expression<T> Function($$GameMovesTableAnnotationComposer a) f,
  ) {
    final $$GameMovesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameMoves,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameMovesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameMoves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          GameRow,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (GameRow, $$GamesTableReferences),
          GameRow,
          PrefetchHooks Function({bool gameMovesRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> playerColor = const Value.absent(),
                Value<String> fen = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                startedAt: startedAt,
                updatedAt: updatedAt,
                mode: mode,
                difficulty: difficulty,
                playerColor: playerColor,
                fen: fen,
                status: status,
                outcome: outcome,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required DateTime updatedAt,
                required String mode,
                required String difficulty,
                required String playerColor,
                required String fen,
                Value<String> status = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                startedAt: startedAt,
                updatedAt: updatedAt,
                mode: mode,
                difficulty: difficulty,
                playerColor: playerColor,
                fen: fen,
                status: status,
                outcome: outcome,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GamesTable, GameRow>(table),
                  $$GamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameMovesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameMovesRefs) db.gameMoves],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameMovesRefs)
                    await $_getPrefetchedData<GameRow, $GamesTable, MoveRow>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._gameMovesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GamesTableReferences(db, table, p0).gameMovesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      GameRow,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (GameRow, $$GamesTableReferences),
      GameRow,
      PrefetchHooks Function({bool gameMovesRefs})
    >;
typedef $$GameMovesTableCreateCompanionBuilder =
    GameMovesCompanion Function({
      Value<int> id,
      required int gameId,
      required int ply,
      required String san,
      required String fromSquare,
      required String toSquare,
      required DateTime playedAt,
    });
typedef $$GameMovesTableUpdateCompanionBuilder =
    GameMovesCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<int> ply,
      Value<String> san,
      Value<String> fromSquare,
      Value<String> toSquare,
      Value<DateTime> playedAt,
    });

final class $$GameMovesTableReferences
    extends BaseReferences<_$AppDatabase, $GameMovesTable, MoveRow> {
  $$GameMovesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_moves__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameMovesTableFilterComposer
    extends Composer<_$AppDatabase, $GameMovesTable> {
  $$GameMovesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get san => $composableBuilder(
    column: $table.san,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromSquare => $composableBuilder(
    column: $table.fromSquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toSquare => $composableBuilder(
    column: $table.toSquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameMovesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameMovesTable> {
  $$GameMovesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get san => $composableBuilder(
    column: $table.san,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromSquare => $composableBuilder(
    column: $table.fromSquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toSquare => $composableBuilder(
    column: $table.toSquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameMovesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameMovesTable> {
  $$GameMovesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<String> get san =>
      $composableBuilder(column: $table.san, builder: (column) => column);

  GeneratedColumn<String> get fromSquare => $composableBuilder(
    column: $table.fromSquare,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toSquare =>
      $composableBuilder(column: $table.toSquare, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameMovesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameMovesTable,
          MoveRow,
          $$GameMovesTableFilterComposer,
          $$GameMovesTableOrderingComposer,
          $$GameMovesTableAnnotationComposer,
          $$GameMovesTableCreateCompanionBuilder,
          $$GameMovesTableUpdateCompanionBuilder,
          (MoveRow, $$GameMovesTableReferences),
          MoveRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$GameMovesTableTableManager(_$AppDatabase db, $GameMovesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameMovesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameMovesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameMovesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<String> san = const Value.absent(),
                Value<String> fromSquare = const Value.absent(),
                Value<String> toSquare = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => GameMovesCompanion(
                id: id,
                gameId: gameId,
                ply: ply,
                san: san,
                fromSquare: fromSquare,
                toSquare: toSquare,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int ply,
                required String san,
                required String fromSquare,
                required String toSquare,
                required DateTime playedAt,
              }) => GameMovesCompanion.insert(
                id: id,
                gameId: gameId,
                ply: ply,
                san: san,
                fromSquare: fromSquare,
                toSquare: toSquare,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameMovesTable, MoveRow>(table),
                  $$GameMovesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$GameMovesTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$GameMovesTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameMovesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameMovesTable,
      MoveRow,
      $$GameMovesTableFilterComposer,
      $$GameMovesTableOrderingComposer,
      $$GameMovesTableAnnotationComposer,
      $$GameMovesTableCreateCompanionBuilder,
      $$GameMovesTableUpdateCompanionBuilder,
      (MoveRow, $$GameMovesTableReferences),
      MoveRow,
      PrefetchHooks Function({bool gameId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$GameMovesTableTableManager get gameMoves =>
      $$GameMovesTableTableManager(_db, _db.gameMoves);
}
