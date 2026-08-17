import 'package:flutter/material.dart';
import '../module_a/step_00_app_theme.dart';
import '../module_a/step_08_auth.dart';
import '../module_a/step_04_state.dart';
import '../module_b/step_04_state.dart';
import 'step_05_app_state.dart';
import 'step_13_shell.dart';
import 'step_04_state.dart';

Widget vinylGrooveApp(AppState state) => ModuleAStateScope(
  state: state,
  child: ModuleBStateScope(
    state: state,
    child: ModuleCStateScope(
      state: state,
      child: MaterialApp(
        title: 'Vinyl Groove',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: AnimatedBuilder(
          animation: state,
          builder: (context, _) =>
              state.isLoggedIn ? const MainShell() : const LoginScreen(),
        ),
      ),
    ),
  ),
);
