import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../genres_list/domain/entites/genre.dart';
import '../../../genres_list/infrastructure/models/genre_model.dart';
import '../../../genres_list/presentation/blocs/dropdown_selection_bloc/dropdown_selection_bloc.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/genres_list_bloc.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/states/genres_list_states.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/states/get_genres_list_failure_state.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/states/get_genres_list_loading_state.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/states/get_genres_list_success_state.dart';
import '../../../movies_by_genres/domain/entities/movies_by_genres_parameters.dart';
import '../../../movies_by_genres/presentation/bloc/movies_by_genres_bloc/events/get_movies_by_genres_event.dart';
import '../../../movies_by_genres/presentation/bloc/movies_by_genres_bloc/events/reset_movies_by_genres_event.dart';
import '../../../movies_by_genres/presentation/bloc/movies_by_genres_bloc/movies_by_genres_bloc.dart';
import '../blocs/most_popular_movies_bloc/events/get_most_popular_movies_event.dart';
import '../blocs/most_popular_movies_bloc/events/reset_most_popular_movies_event.dart';
import '../blocs/most_popular_movies_bloc/most_popular_movies_bloc.dart';

class GenreListSelector extends StatelessWidget {
  GenreListSelector({super.key});

  final genresListBloc = Modular.get<GenresListBloc>();
  final dropdownSelectionBloc = Modular.get<DropdownSelectionBloc>();
  final mostPopularMoviesBloc = Modular.get<MostPopularMoviesBloc>();
  final moviesByGenresBloc = Modular.get<MoviesByGenresBloc>();

  final mostPopularMoviesGenre = GenreModel(id: -1, name: 'Most Popular Movies');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenresListBloc, GenresListStates>(
      bloc: genresListBloc,
      builder: ((context, state) {
        if (state is GetGenresListLoadingState) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: LinearProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.blue,
            ),
          );
        }

        if (state is GetGenresListFailureState) {
          return Text(
            'state.failure.message',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          );
        }

        if (state is GetGenresListSuccessState) {
          if (state.genresList.genresList.first.id != mostPopularMoviesGenre.id) {
            state.genresList.genresList.insert(0, mostPopularMoviesGenre);
          }

          return BlocBuilder<DropdownSelectionBloc, String>(
            bloc: dropdownSelectionBloc,
            builder: (context, dropdownSelectionState) {
              return DropdownButton<String>(
                underline: SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Colors.white,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    dropdownSelectionBloc.add(newValue);

                    genresListBloc.genre = state.genresList.genresList.firstWhere((element) => element.name == newValue);

                    if (genresListBloc.genre.id == -1) {
                      moviesByGenresBloc.add(ResetMoviesByGenresEvent());
                      mostPopularMoviesBloc.add(GetMostPopularMoviesEvent());
                    } else {
                      mostPopularMoviesBloc.add(ResetMostPopularMoviesEvent());
                      moviesByGenresBloc.add(GetMoviesByGenresEvent(MoviesByGenresParameters(genresListBloc.genre)));
                    }
                  }
                },
                value: dropdownSelectionBloc.dropdownValue,
                dropdownColor: Color.fromARGB(255, 34, 37, 37),
                items: state.genresList.genresList.map((Genre genre) {
                  return DropdownMenuItem(
                    value: genre.name,
                    child: Text(
                      genre.name,
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              );
            },
          );
        }
        return const SizedBox();
      }),
    );
  }
}
