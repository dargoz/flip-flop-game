import 'dart:async';

import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flip_flop_game/domain/firebase/entities/player.dart';
import 'package:flip_flop_game/presentation/navigation/app_route.gr.dart';
import 'package:flip_flop_game/presentation/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_flop_game/domain/game/constants.dart';
import 'package:flip_flop_game/domain/game/entity/game.dart';
import 'package:flip_flop_game/injection.dart';
import 'package:flip_flop_game/presentation/pages/game/card_flip_widget.dart';
import 'package:flip_flop_game/usecase/game/game_bloc.dart';
import 'package:flip_flop_game/usecase/timer/timer_bloc.dart';

class GamePage extends StatelessWidget {
  GamePage({Key? key, required this.player, required this.game})
      : super(key: key);

  final Player player;
  final Game game;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<GameBloc>()),
            BlocProvider(create: (context) => getIt<TimerBloc>()),
          ],
          child: Center(
              child: Column(
            children: [
              Container(
                child: BlocConsumer<TimerBloc, TimerState>(
                  listener: (context, state) {

                    if (!state.start || state.score == 0) {
                      int finalScore = state.score == 0 ? 1 : state.score;
                      BlocProvider.of<GameBloc>(context)
                          .add(GameEvent.onGameEnd(player, finalScore));
                      timer?.cancel();
                      context.navigateTo(ResultRoute(score: "$finalScore"));
                    }
                  },
                  builder: (context, state) {
                    if (!state.isActive) {
                      timer =
                          Timer.periodic(const Duration(seconds: 1), (timer) {
                        BlocProvider.of<TimerBloc>(context)
                            .add(TimerEvent.tickTimer());
                      });
                    }
                    return Text(
                        'game time ${state.hours}:${state.minutes}:${state.seconds}',
                      style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),);
                  },
                ),
              ),
              const Spacer(),
              Container(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 800),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          for (int index = 0; index < GameConfig.quantity; index++)
                            SizedBox(
                              width: 120,
                              height: 180,
                              child: CardFlipWidget(
                                position: index,
                                frontAsset: game.assetPaths[index],
                                rearAsset: 'resources/cover/card_rear_bg.png',
                              ),
                            ),
                        ],
                      ),
                    ),
                    BlocConsumer<TimerBloc, TimerState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        if(state.pause) {
                          return const LoadingWidget();
                        } else {
                          return const SizedBox(
                            width: 0,
                            height: 0,
                          );
                        }

                      },
                    ),
                  ],

                )
              ),
            ],
          ))),
    );
  }
}
