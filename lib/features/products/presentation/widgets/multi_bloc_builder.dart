import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiBlocBuilder extends StatelessWidget {
  final List<BlocBase> blocs;
  final Widget Function(BuildContext, List<dynamic>) builder;

  const MultiBlocBuilder({
    super.key,
    required this.blocs,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return _buildMultiBlocBuilder(context, 0, []);
  }

  Widget _buildMultiBlocBuilder(
    BuildContext context,
    int index,
    List<dynamic> states,
  ) {
    if (index >= blocs.length) {
      return builder(context, states);
    }

    return BlocBuilder(
      bloc: blocs[index],
      builder: (context, state) {
        final newStates = List<dynamic>.from(states)..add(state);
        return _buildMultiBlocBuilder(context, index + 1, newStates);
      },
    );
  }
}