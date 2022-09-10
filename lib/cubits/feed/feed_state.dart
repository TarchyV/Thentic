part of 'feed_cubit.dart';

@immutable
abstract class FeedState {}

class FeedInitial extends FeedState {}
class FeedLoading extends FeedState {}
class FeedLoaded extends FeedState {
  final List<Post> feed;
  FeedLoaded(this.feed);
}
class UpdateFeed extends FeedState {}
