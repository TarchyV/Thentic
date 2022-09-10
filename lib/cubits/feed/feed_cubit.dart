import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:thentic_app/resources/feed_repository.dart';
import 'package:thentic_app/resources/post.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedRepository _feedRepository;
  FeedCubit(this._feedRepository) : super(FeedInitial());


  void updateFeed() {
    emit(UpdateFeed());
  }

  Future<void> getFeed(List<String> following) async {
    emit(FeedLoading());
    try {
      List<Post> feed = await _feedRepository.getFeed(following);
      emit(FeedLoaded(feed));
    } catch (e) {
      print(e);
    }


  }


}
