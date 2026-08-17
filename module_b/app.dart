import 'package:flutter/material.dart';
import '../module_a/app_theme.dart';
import '../module_a/auth.dart';
import '../module_a/state.dart';
import 'app_state.dart';
import 'shell.dart';
import 'state.dart';

Widget moduleBApp(ModuleBAppState state) => ModuleAStateScope(
  state: state,
  child: ModuleBStateScope(
    state: state,
    child: MaterialApp(
      title: 'Vinyl Groove - Module B',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AnimatedBuilder(
        animation: state,
        builder: (context, _) =>
            state.isLoggedIn ? const ModuleBShell() : const LoginScreen(),
      ),
    ),
  ),
);
