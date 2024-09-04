import 'package:flutter/material.dart';

import '../../../search_movies/presentation/widgets/movies_search_delegate.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (() {
        showSearch(context: context, delegate: MoviesSearchDelegate());
      }),
      icon: Icon(
        Icons.search,
        color: Colors.white,
      ),
    );
  }
}
