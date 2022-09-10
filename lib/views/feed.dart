import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/feed/feed_cubit.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/resources/post.dart';
import 'package:thentic_app/views/create_post.dart';
import 'package:thentic_app/views/post_card.dart';
import 'package:video_player/video_player.dart';


class FeedPage extends StatefulWidget {
  FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {


  List<Post> feed = [];



  Future<void> getFeed() async {
     await GetIt.I<FeedCubit>().getFeed((GetIt.I<UserCubit>().state as UserLoggedIn).following);
    feed = (GetIt.I<FeedCubit>().state as FeedLoaded).feed;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("THENTIC"),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraPage()));
            },
            icon: const Icon(Icons.add_a_photo_outlined),
          ),
        
        ],

      ),
      body:  BlocConsumer<FeedCubit, FeedState>(
        listener: (context, state) {
          if (state is UpdateFeed) {
            getFeed();
          }
        },
        builder: (context, state) {
          if(state is FeedInitial){
            getFeed();
          }
          if(state is FeedLoading){
            return const Center(child: CircularProgressIndicator());
          }
          if(state is FeedLoaded){
        return Column(
               mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                 Expanded(
                   child: Center(
                     child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                       child: ListView.builder(
                         itemCount: feed.length,
                         itemBuilder: (context, index) {
                           return PostCard(post: feed[index]);
                         },
                       ),
                     ),
                   ),
                 ),
              ],
            );
          }
          return const Center(child: Text(".>."));
          
        },
      ),
    
    );
  }
}




