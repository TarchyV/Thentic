import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/resources/post.dart';
import 'package:video_player/video_player.dart';


class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String username = "";
  String postedTime = "";
  String caption = "";
  String fullCaption = "";
  PostType postType = PostType.IMAGE;
  String postUrl = "";
late VideoPlayerController _videoController;


  Future<void> getUsername() async {
    username = await GetIt.I<UserCubit>().getUserNameFromId(widget.post.userId);
    setState(() {});
  }

  Future<void> getPostedTime() async {
    String _timeSinceEpoch = widget.post.createdAt;
    DateTime _dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(_timeSinceEpoch));
    //format to (posted 2 hours ago)
    var _timeSince = DateTime.now().difference(_dateTime);
    var _timeSinceString = _timeSince.toString().split(":");
    var _timeSinceInt = int.parse(_timeSinceString[0]);
    var _timeSinceUnit = "hours";
    if(_timeSinceInt < 1){
      _timeSinceInt = int.parse(_timeSinceString[1]);
      _timeSinceUnit = "minutes";
    }
    if(_timeSinceInt < 1){
      try {
      _timeSinceInt = int.parse(_timeSinceString[2]);
      _timeSinceUnit = "seconds";
      } catch (e) {
        _timeSinceInt = 0;
        _timeSinceUnit = "seconds";
      }
    
    }
    print('$_timeSinceInt $_timeSinceUnit');
    postedTime = "$_timeSinceInt $_timeSinceUnit ago";
    setState(() {});
  }



  onVideoEnd(){
  if(_videoController.value.position == _videoController.value.duration){
    print("Video Ended~!");
    setState((){});
  }
    
  }

  void initializeVideo(){
    if(postType == PostType.VIDEO){
      _videoController = VideoPlayerController.network(postUrl)
        ..initialize().then((_) {
          setState(() {});
        });
        _videoController.play();
        _videoController.addListener(onVideoEnd);
    }
  }

  void handleCaption(){
    if(widget.post.caption.length > 20){
      caption = widget.post.caption.substring(0, 20) + "...";
      fullCaption = widget.post.caption;
    } else {
      caption = widget.post.caption;
    }

  }

 




  @override
  void initState() {
    getUsername();
    getPostedTime();
    caption = widget.post.caption;
    handleCaption();
    postType = widget.post.type;
    postUrl = postType == PostType.IMAGE ? widget.post.imageUrl! : widget.post.videoUrl!;
    initializeVideo();
    
    super.initState();
  }





  @override
  Widget build(BuildContext context) {
   //Create a social media style card
    return Container(
      height: 550,
      margin: const EdgeInsets.all(7.0),
      padding: const EdgeInsets.only(left:0.0,right:0.0,top:0.0),
      decoration: const BoxDecoration(
        color: Colors.black,

      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom:60.0),
            child: SizedBox(
              width: double.infinity,
              height: 500,
                      child: postType == PostType.IMAGE ?
                        Image.network(postUrl,
                        fit: BoxFit.fitWidth,
                        )
                        : Stack(
                          children: [
                          Center(
                            child: AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: VideoPlayer(
                             _videoController,
                            ),
                        ),
                      ),
                      //Pause/Play button
                      Center(
                        child: Visibility(
                          visible: !_videoController.value.isPlaying,
                          child: IconButton(
                            onPressed: () {
                              _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
                              setState(() {});
                            },
                            icon: const Icon(Icons.play_arrow),
                            iconSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                          ],
                        )
                        
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:16.0, top: 8),
                    child: headLine(),
                  ),   
                 
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                        Padding(
                          padding: const EdgeInsets.only(top:4.0),
                          child:
                          viewsIcon()),
                          textSection(),
                    ],
                  )
                  
                  
                
                ),
              ),

            
        ],
      )
      
      
    );

    
  }

Widget headLine(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
          Text("@$username", style: 
          const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
          ),),
          const SizedBox(
            height: 4,
          ),
                                      
        Text(postedTime, style: const TextStyle(
          color: Color.fromARGB(255, 226, 226, 226), 
          fontSize: 12,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
          ),
          ),
    ],
  );
}

Widget textSection(){
  return Expanded(
        child: Row(
          children: [
              RichText(
              text: TextSpan(
                text: "@$username ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                  ),
                children: <TextSpan>[
                  TextSpan(
                    text: caption,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.white,
                      ),
                  ),
                ],
              ),
              ),
          if(fullCaption != "")
          InkWell(
            onTap: (){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("@$username"),
                    content: Text(fullCaption),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("read more", style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              ),
            ),
          ),
      

          ],
        ),
      );
}




Widget viewsIcon() {
 return Row(
    children:  [
          const Icon(
            Icons.remove_red_eye,
            size:18,
            color: Colors.white,
            ),
            const SizedBox(
              width: 5,
            ),
          Text(widget.post.views.toString(), style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            ),
          ),
                    ],
                  );
}





}