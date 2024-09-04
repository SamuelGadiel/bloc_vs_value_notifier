import 'package:flix_clean_ark/app/modules/movies/submodules/genres_list/presentation/blocs/dropdown_selection_bloc/dropdown_selection_bloc.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/most_popular_movies/presentation/widgets/genre_list_selector.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/most_popular_movies/presentation/widgets/search_button.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/movies_by_genres/presentation/bloc/movies_by_genres_bloc/events/get_movies_by_genres_event.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/movies_by_genres/presentation/bloc/movies_by_genres_bloc/movies_by_genres_bloc.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/movies_by_genres/presentation/bloc/movies_by_genres_bloc/states/get_movies_by_genres_failure_state.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/movies_by_genres/presentation/bloc/movies_by_genres_bloc/states/get_movies_by_genres_loading_state.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/movies_by_genres/presentation/bloc/movies_by_genres_bloc/states/get_movies_by_genres_success_state.dart';
import 'package:flix_clean_ark/app/modules/movies/submodules/movies_by_genres/presentation/bloc/movies_by_genres_bloc/states/movies_by_genres_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide WatchContext;
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../domain/movie.dart';
import '../../../../presentation/settings/movie_poster_url.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/events/get_genres_list_event.dart';
import '../../../genres_list/presentation/blocs/genres_list_bloc/genres_list_bloc.dart';
import '../../../movies_by_genres/domain/entities/movies_by_genres_parameters.dart';
import '../../../search_movies/presentation/bloc/search_movies_bloc/search_movies_bloc.dart';
import '../blocs/most_popular_movies_bloc/events/get_most_popular_movies_event.dart';
import '../blocs/most_popular_movies_bloc/most_popular_movies_bloc.dart';
import '../blocs/most_popular_movies_bloc/states/get_most_popular_movies_failure_state.dart';
import '../blocs/most_popular_movies_bloc/states/get_most_popular_movies_loading_state.dart';
import '../blocs/most_popular_movies_bloc/states/get_most_popular_movies_sucess_state.dart';
import '../blocs/most_popular_movies_bloc/states/most_popular_movies_states.dart';

class MostPopularMoviesHomePage extends StatefulWidget {
  const MostPopularMoviesHomePage();

  @override
  State<MostPopularMoviesHomePage> createState() => _ModuleMostPopularMoviesState();
}

class _ModuleMostPopularMoviesState extends State<MostPopularMoviesHomePage> {
  final mostPopularMoviesBloc = Modular.get<MostPopularMoviesBloc>();

  final searchMoviesBloc = Modular.get<SearchMoviesBloc>();
  final genresListBloc = Modular.get<GenresListBloc>();
  final moviesByGenresBloc = Modular.get<MoviesByGenresBloc>();
  final dropdownSelectionBloc = Modular.get<DropdownSelectionBloc>();

  @override
  void initState() {
    mostPopularMoviesBloc.add(GetMostPopularMoviesEvent());
    genresListBloc.add(GetGenresListEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoviesByGenresBloc, MoviesByGenresStates>(
      bloc: moviesByGenresBloc,
      builder: (context, moviesByGenresState) {
        return Scaffold(
          backgroundColor: Color(0xFF072E2F),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 60, 60, 60),
            title: GenreListSelector(),
            actions: [SearchButton()],
          ),
          body: Scrollbar(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: BlocBuilder<MostPopularMoviesBloc, MostPopularMoviesStates>(
                bloc: mostPopularMoviesBloc,
                builder: (context, mostPopularMoviesState) {
                  if (mostPopularMoviesState is GetMostPopularMoviesLoadingState || moviesByGenresState is GetMoviesByGenresLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (mostPopularMoviesState is GetMostPopularMoviesFailureState) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Icon(Icons.error, size: 48, color: Colors.white),
                          ),
                          Text(
                            mostPopularMoviesState.failure.message,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          ElevatedButton(
                            child: Text('Tentar novamente'),
                            onPressed: () {
                              mostPopularMoviesBloc.add(
                                GetMostPopularMoviesEvent(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (moviesByGenresState is GetMoviesByGenresFailureState) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Icon(Icons.error, size: 48, color: Colors.white),
                          ),
                          Text(
                            moviesByGenresState.failure.message,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          ElevatedButton(
                            child: Text('Tentar novamente'),
                            onPressed: () {
                              moviesByGenresBloc.add(GetMoviesByGenresEvent(
                                MoviesByGenresParameters(genresListBloc.genre),
                              ));
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (mostPopularMoviesState is GetMostPopularMoviesSucessState || moviesByGenresState is GetMoviesByGenresSuccessState) {
                    List<Movie> movies;

                    if (mostPopularMoviesState is GetMostPopularMoviesSucessState) {
                      movies = mostPopularMoviesState.movieList.movies;
                    } else {
                      moviesByGenresState as GetMoviesByGenresSuccessState;
                      movies = moviesByGenresState.moviesByGenres.movies;
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (mostPopularMoviesState is GetMostPopularMoviesSucessState) {
                          movies = mostPopularMoviesState.movieList.movies;
                        } else {
                          moviesByGenresState as GetMoviesByGenresSuccessState;
                          movies = moviesByGenresState.moviesByGenres.movies;
                        }
                      },
                      child: Container(
                        child: ListView.builder(
                          itemCount: movies.length,
                          itemBuilder: (context, position) {
                            return Card(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Color.fromARGB(255, 19, 3, 252).withAlpha(30),
                                onTap: () {
                                  Modular.to.pushNamed(
                                    '/movies/movieDetails/',
                                    arguments: [
                                      movies[position].id,
                                    ],
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        '${MoviesSettings.moviePosterUrl}${movies[position].poster}',
                                        width: 150,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.52,
                                              child: Text(
                                                movies[position].title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              movies[position].releaseDate,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            SizedBox(height: 7),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.52,
                                              child: Text(
                                                movies[position].overview,
                                                maxLines: 6,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 15, color: Colors.white),
                                              ),
                                            ),
                                            SizedBox(height: 7),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                ),
                                                Text(
                                                  movies[position].score,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  return SizedBox();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
