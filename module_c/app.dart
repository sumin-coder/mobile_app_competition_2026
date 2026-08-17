import 'package:flutter/material.dart';
import '../module_a/app_theme.dart';
import '../module_a/auth.dart';
import '../module_a/state.dart';
import '../module_b/state.dart';
import 'app_state.dart';
import 'shell.dart';
import 'state.dart';

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
