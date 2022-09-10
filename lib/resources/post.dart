//Can only post every 4 hours
//Ability to anonymously post to thentic
class Post{
  final String userId;
  final String id;
  final String caption;
  final PostType type;
  final String? imageUrl;
  final String? videoUrl;
  final String createdAt;
  final int views;
  Post({
    required this.userId,
    required this.id,
    required this.caption,
    required this.type,
    required this.createdAt,
    this.imageUrl,
    this.videoUrl,
    this.views = 0,
  });

}

enum PostType{
  IMAGE,
  VIDEO,
}

class Comment{
  final int postId;
  final int id;
  final String userId;
  final String name;
  final String caption;
  final DateTime date;

  Comment({
    required this.postId,
    required this.id,
    required this.userId,
    required this.name,
    required this.caption,
    required this.date,
  });





}