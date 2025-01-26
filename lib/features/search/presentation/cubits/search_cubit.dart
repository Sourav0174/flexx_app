import 'dart:developer'; // For better logging
import 'package:flexx/features/search/domain/repos/search_repo.dart';
import 'package:flexx/features/search/presentation/cubits/search_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;
  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  // To debounce API calls
  String _lastQuery = '';
  bool _isDebouncing = false;

  /// Searches users based on the query.
  Future<void> searchUsers(String query) async {
    // If the query is empty, reset the state
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Prevent unnecessary duplicate API calls
    if (_isDebouncing || query == _lastQuery) return;
    _isDebouncing = true;

    try {
      // Emit loading state before making the API call
      emit(SearchLoading());

      // Fetch users from the repository
      final users = await searchRepo.searchUsers(query);

      // Debug log for successful search
      log("Search results: ${users.length} users found for query '$query'");

      // Update the state with the fetched users
      emit(SearchLoaded(users));
    } catch (e, stackTrace) {
      // Log the error and stack trace for debugging
      log("Error during search: $e", stackTrace: stackTrace);

      // Emit an error state with a user-friendly message
      emit(SearchError("An error occurred while searching. Please try again."));
    } finally {
      // Reset debounce logic
      _lastQuery = query;
      _isDebouncing = false;
    }
  }
}
