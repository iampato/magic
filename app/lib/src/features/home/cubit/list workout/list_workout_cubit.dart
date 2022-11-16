import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:magic/src/core/shared_preference.dart';
import 'package:magic/src/features/home/model/workout_response.dart';
import 'package:magic/src/features/home/repository/workout_repository.dart';
import 'package:magic/src/features/landing/models/user_model.dart';

part 'list_workout_state.dart';
part 'list_workout_cubit.freezed.dart';

class ListWorkoutCubit extends Cubit<ListWorkoutState> {
  final WorkoutRepository workoutRepo;
  final SharedPreferenceRepo preferenceRepo;
  ListWorkoutCubit({
    required this.workoutRepo,
    required this.preferenceRepo,
  }) : super(const ListWorkoutState.initial());

  /// get all workouts
  Future<void> getMyWorkouts() async {
    try {
      final userStr = await preferenceRepo.getUserValue();
      final userMap = jsonDecode(userStr ?? "");
      UserModel user = UserModel.fromJson(userMap);
      final workoutResponse = await workoutRepo.getMyWorkouts(userId: user.id);
      emit(ListWorkoutState.success(workoutResponse: workoutResponse));
    } catch (e) {
      emit(ListWorkoutState.error(message: e.toString()));
    }
  }

  Future<void> createWorkout({
    required String type,
    required int noOfSets,
    required int noOfReps,
    required double weight,
  }) async {
    final currentState = state;
    currentState.maybeWhen(
      orElse: () async {
        try {
          emit(const ListWorkoutState.success(
            isLoading: true,
            workoutResponse: [],
            message: null,
          ));
          final userStr = await preferenceRepo.getUserValue();
          final userMap = jsonDecode(userStr ?? "");
          UserModel user = UserModel.fromJson(userMap);
          await workoutRepo.createWorkout(
            userId: user.id,
            type: type,
            noOfSets: noOfSets,
            noOfReps: noOfReps,
            weight: weight,
          );
          getMyWorkouts();
          emit(const ListWorkoutState.success(
            isLoading: null,
            workoutResponse: [],
            message: "Workout created successfully",
          ));
        } catch (e) {
          emit(
            const ListWorkoutState.success(
              isLoading: null,
              workoutResponse: [],
              message: "Error in creating workout",
            ),
          );
        }
      },
      success: (isLoading, workoutResponse, message) async {
        try {
          emit(ListWorkoutState.success(
            isLoading: true,
            workoutResponse: workoutResponse,
            message: null,
          ));
          final userStr = await preferenceRepo.getUserValue();
          final userMap = jsonDecode(userStr ?? "");
          UserModel user = UserModel.fromJson(userMap);
          await workoutRepo.createWorkout(
            userId: user.id,
            type: type,
            noOfSets: noOfSets,
            noOfReps: noOfReps,
            weight: weight,
          );
          getMyWorkouts();
          emit(ListWorkoutState.success(
            isLoading: null,
            workoutResponse: workoutResponse,
            message: "Workout created successfully",
          ));
        } catch (e) {
          emit(
            ListWorkoutState.success(
              isLoading: isLoading,
              workoutResponse: workoutResponse,
              message: "Error in creating workout",
            ),
          );
        }
      },
    );
  }

  Future<void> deleteWorkout({required String workoutId}) async {
    final currentState = state;
    currentState.maybeWhen(
      orElse: () async {
        try {
          emit(const ListWorkoutState.success(
            isLoading: true,
            workoutResponse: [],
            message: null,
          ));
          await workoutRepo.deleteWorkout(workoutId: workoutId);
          getMyWorkouts();
          emit(const ListWorkoutState.success(
            isLoading: null,
            workoutResponse: [],
            message: "Workout deleted successfully",
          ));
        } catch (e) {
          emit(
            const ListWorkoutState.success(
              isLoading: null,
              workoutResponse: [],
              message: "Error in deleting workout",
            ),
          );
        }
      },
      success: (isLoading, workoutResponse, message) async {
        try {
          emit(ListWorkoutState.success(
            isLoading: true,
            workoutResponse: workoutResponse,
            message: null,
          ));
          await workoutRepo.deleteWorkout(workoutId: workoutId);
          getMyWorkouts();
          emit(ListWorkoutState.success(
            isLoading: null,
            workoutResponse: workoutResponse,
            message: "Workout deleted successfully",
          ));
        } catch (e) {
          emit(
            ListWorkoutState.success(
              isLoading: isLoading,
              workoutResponse: workoutResponse,
              message: "Error in deleting workout",
            ),
          );
        }
      },
    );
  }

  Future<void> editWorkout({
    required String workoutId,
    required String type,
    required int noOfSets,
    required int noOfReps,
    required double weight,
  }) async {
    final currentState = state;
    currentState.maybeWhen(
      orElse: () async {
        try {
          emit(const ListWorkoutState.success(
            isLoading: true,
            workoutResponse: [],
            message: null,
          ));
          await workoutRepo.updateWorkout(
            workoutId: workoutId,
            type: type,
            noOfSets: noOfSets,
            noOfReps: noOfReps,
            weight: weight,
          );
          getMyWorkouts();
          emit(const ListWorkoutState.success(
            isLoading: null,
            workoutResponse: [],
            message: "Workout editted successfully",
          ));
        } catch (e) {
          emit(
            const ListWorkoutState.success(
              isLoading: null,
              workoutResponse: [],
              message: "Error while editing workout",
            ),
          );
        }
      },
      success: (isLoading, workoutResponse, message) async {
        try {
          emit(ListWorkoutState.success(
            isLoading: true,
            workoutResponse: workoutResponse,
            message: null,
          ));
          await workoutRepo.updateWorkout(
            workoutId: workoutId,
            type: type,
            noOfSets: noOfSets,
            noOfReps: noOfReps,
            weight: weight,
          );
          getMyWorkouts();
          emit(ListWorkoutState.success(
            isLoading: null,
            workoutResponse: workoutResponse,
            message: "Workout editted successfully",
          ));
        } catch (e) {
          emit(
            ListWorkoutState.success(
              isLoading: isLoading,
              workoutResponse: workoutResponse,
              message: "Error in editting workout",
            ),
          );
        }
      },
    );
  }
}