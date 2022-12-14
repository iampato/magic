import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/src/core/shared_preference.dart';
import 'package:magic/src/features/home/cubit/list%20workout/list_workout_cubit.dart';
import 'package:magic/src/features/home/repository/workout_repository.dart';
import 'package:magic/src/features/landing/cubit/authentication/authentication_cubit.dart';
import 'package:magic/src/features/onboarding/cubit/login/login_cubit.dart';
import 'package:magic/src/features/onboarding/cubit/register/register_cubit.dart';
import 'package:magic/src/features/onboarding/repository/login_repository.dart';

Widget setupProviders(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => AuthenticationCubit(
          preferencesRepo: context.read<SharedPreferenceRepo>(),
        )..isUserLoggedIn(),
      ),
      BlocProvider(
        create: (context) => LoginCubit(
          preferencesRepo: context.read<SharedPreferenceRepo>(),
          loginRepo: context.read<LoginRepository>(),
        ),
      ),
      BlocProvider(
        create: (context) => RegisterCubit(
          loginRepo: context.read<LoginRepository>(),
        ),
      ),
      BlocProvider(
        create: (context) => ListWorkoutCubit(
          workoutRepo: context.read<WorkoutRepository>(),
          preferenceRepo: context.read<SharedPreferenceRepo>(),
        )..clearState(),
      ),
    ],
    child: child,
  );
}
