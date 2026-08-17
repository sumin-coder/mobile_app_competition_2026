import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'auth.dart';
import 'shell.dart';
import 'state.dart';

Widget moduleAApp(ModuleAAppState state) => ModuleAStateScope(
  state: state,
  child: MaterialApp(
    title: 'Vinyl Groove - Module A',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: AnimatedBuilder(
      animation: state,
      builder: (context, _) =>
          state.isLoggedIn ? const ModuleAShell() : const LoginScreen(),
    ),
  ),
);
