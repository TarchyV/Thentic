

import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/feed/feed_cubit.dart';
import 'package:thentic_app/cubits/navigation/navigation_cubit.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/cubits/utility/utility_cubit.dart';
import 'package:thentic_app/resources/post.dart';
import 'package:thentic_app/views/feed.dart';
import 'package:thentic_app/views/post_card.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  bool _editMode = false;
  Color _gradientStart = Colors.blueGrey.shade900;
  Color _gradientEnd = Colors.blueGrey.shade200;
  late CameraController controller;
  List<CameraDescription>? _cameras;
  int selectedCamera = 1;
  bool _isTakingPicture = false;
  List<Post> feed = [];
  ScrollController _scrollController = ScrollController();
  bool _headerExpanded = true;
  bool _isMyProfile = false;
  bool _isFollowing = false;

  Future<void> getUserFeed() async{
    await GetIt.I<FeedCubit>().getFeed([widget.userId]);
    feed = (GetIt.I<FeedCubit>().state as FeedLoaded).feed;
    setState(() {});
  }

Future<void> determineIfFollowing() async{
  if(widget.userId == GetIt.I<UserCubit>().getUserId()){
    _isMyProfile = true;
  } else {
    _isMyProfile = false;
  }
  if(_isMyProfile){
    _isFollowing = true;
  } else {
   List<String> following = await GetIt.I<UserCubit>().getFollowing(widget.userId);
    if(following.contains(GetIt.I<UserCubit>().getUserId())){
      _isFollowing = true;
    } else {
      _isFollowing = false;
    }
  }
  setState(() {});
}


  Future<String> getUsername() async {
    username = await GetIt.I<UserCubit>().getUserNameFromId(widget.userId);
    return username;
  }
  Future<String> getProfilePic() async {
    String profilePic = await GetIt.I<UserCubit>().getProfilePictureUrl(widget.userId);
    if(profilePic.isEmpty) {
      profilePic = "https://picsum.photos/200/300?grayscale";
    }
    return profilePic;
  }

  Future<void> _getColorsForGradient() async {
    GetIt.I<UserCubit>().getProfileGradientColors(widget.userId).then((value) {
      setState(() {
        _gradientStart = value[0];
        _gradientEnd = value[1];
      });
    });
  }

  Future<void> _initializeCamera() async {
   _cameras = GetIt.I<UtilityCubit>().cameras;
  controller = CameraController(_cameras![selectedCamera], ResolutionPreset.max);
  await controller.initialize().then((_) {
    if (!mounted) {
      return;
    }
    setState(() {});
  });
}

  @override
  void initState() {
    getUsername();
    _getColorsForGradient();
    getUserFeed();
    determineIfFollowing();
    //listen to scroll events
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  //Determine if the header should be expanded or not based on the scroll position
  void _onScroll() {
    print("Listening to scroll");
    if (_scrollController.offset >= 100) {
      setState(() {
        _headerExpanded = false;
      });
    } else {
      setState(() {
        _headerExpanded = true;
      });
    }
  }


        
Future<void> _startCamera() async {
  await _initializeCamera();
  setState(() {
    _isTakingPicture = true;
  });
}

Future<void> applyProfilePictureAfter(File image) async{
  
     await GetIt.I<UserCubit>().setProfilePicture(widget.userId,image);
     Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isTakingPicture = false;
        });
        getProfilePic();
      Navigator.of(context).pop();
     });
}

void showPicturePreview(File image) {
  setState(() {
    _isTakingPicture = false;
  });
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Preview'),
        content: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
           TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
           applyProfilePictureAfter(image);
            },
            child: Text('Apply'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                  children: [
                    profileHeader(),
                     Expanded(
                     child: ListView.builder(
                      controller: _scrollController,
                      itemCount: feed.length,
                      itemBuilder: (context, index) {
                        return PostCard(post: feed[index]);
                       },
                     ),
                     ),
                  ],
                ),
            ),
          );
        },
      )
    );
  }


Widget profileHeader(){
  return Stack(
      children: [
    _banner(),
    Column(
      children: [
      _profilePicture(),
      Transform.translate(
        offset: _headerExpanded? Offset.zero : Offset(0, -30),

        child: FutureBuilder(
          future: getUsername(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _username(snapshot.data.toString());
            } else {
              return const Text("...");
            }
          },
        ),
      ),
    _headerExpanded?  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          FutureBuilder(
            future: GetIt.I<UserCubit>().getFollowingCount(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  "Following: " + snapshot.data.toString(),
                  style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                  ),
                  );
              } else {
                return const Text("...");
              }
            },
          ),
          SizedBox(width: 20,),
            FutureBuilder(
            future: GetIt.I<UserCubit>().getFollowingCount(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text("Followers: " + snapshot.data.toString(),
                  style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                  ),);
              } else {
                return const Text("...");
              }
            },
          ),
        ],
      ): Container()



      ],
    ),
      Align(
          alignment: Alignment.topLeft,
          child: backButton(),
        ),
     
       Align(
          alignment: Alignment.topRight,
          child: _isMyProfile? editButton() : followButton(),
        ),
        _isTakingPicture? CameraPreview(controller): Container(),
        _isTakingPicture? Positioned(
          bottom: 0,
          left: MediaQuery.of(context).size.width/2-20,
          child: IconButton(
            onPressed: () async {
              final image = await controller.takePicture();
              _isTakingPicture = false;
              showPicturePreview(File(image.path));
            },
            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 40,),
          ),
        ): Container(),
      ],
    );
}

Widget backButton(){
return  Transform.translate(
          offset: _headerExpanded? Offset(0, -16): Offset(0, -7),
  child: Padding(
              padding:  EdgeInsets.only(
                top:  _headerExpanded? 20: 0, 
                left: 5),
              child: IconButton(
              onPressed: (){
               if((GetIt.I<NavigationCubit>().state as NavigationSelected).page == TabItem.profile){
                 if((GetIt.I<NavigationCubit>().state as NavigationSelected).previousTab != null){
                  GetIt.I<NavigationCubit>().selectTab((GetIt.I<NavigationCubit>().state as NavigationSelected).previousTab!);
                 }
               }else{
                Navigator.pop(context);
               }
              }, 
              icon:  Icon(
                Icons.arrow_back_ios,
                 size: _headerExpanded? 28: 20,
                color: Colors.white,
                shadows:const [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                  ),
        ],
                )),
            ),
);
}

Widget editButton(){
return _headerExpanded? Padding(
    padding: const EdgeInsets.only(top:20),
    child: IconButton(
      onPressed: (){
        setState(() {
          _editMode = !_editMode;
        });
    }, icon: const Icon(Icons.edit,
    color: Colors.white,
    size: 28,
    shadows: [
      Shadow(
        blurRadius: 5.0,
        color: Colors.black,
        offset: Offset(1.0, 1.0),
      ),
    ],
    )),
  ): Container();
}
Widget followButton(){
return Transform.translate(
  offset: _headerExpanded? Offset.zero : Offset(0, -7),
  child: IconButton(
    onPressed: (){
      if(!_isFollowing){  
        GetIt.I<UserCubit>().followUser(widget.userId);  
        setState(() {  
          _isFollowing = true;  
        });  
      }else{  
        GetIt.I<UserCubit>().unfollowUser(widget.userId);  
        setState(() {  
          _isFollowing = false;  
        });  
      }          
  }, icon: _isFollowing?  Icon(  
    Icons.remove_circle_outline,  
     size: _headerExpanded? 28: 20,
      color: Colors.white,  
      shadows: const [  
        Shadow(
          blurRadius: 5.0,  
          color: Colors.black,  
          offset: Offset(1.0, 1.0),  
        ),  
      ],)  
      : const Icon(
        Icons.add_circle_outline_outlined,
        size: 28,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: Colors.black,
          offset: Offset(1.0, 1.0),
        ),
      ],
        )),
);
}



Widget _banner(){
  return Stack(
    children: [
      AnimatedOpacity(
        opacity: _headerExpanded? 1: 0.4,
        duration: const Duration(milliseconds: 500),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
        height: _headerExpanded? MediaQuery.of(context).size.height * 0.3: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
            
          ),
          gradient: LinearGradient(
          colors: [
            _gradientStart,
            _gradientEnd,
            ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
            )
        ),
        ),
      ),

  Positioned(
    bottom: 0,
    child: Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _editMode ? 30 : 0,
        width: _editMode ? 30 : 0,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      child: IconButton(
      onPressed: (){
        _gradientColorPickerDialog();

      },
      icon: Icon(Icons.brush, color: Colors.white, size: _editMode? 16: 0,),
      )
    ),
  ),
  ),
  
  ],
  );
}

Future<void> setAndSaveGradientColors(Color start, Color end) async {
  await GetIt.I<UserCubit>().setProfileGradientColor1(widget.userId, start);
  await GetIt.I<UserCubit>().setProfileGradientColor2(widget.userId, end);
}

void _gradientColorPickerDialog(){
  int _colorPickerIndex = 1;
  showDialog(
    context: context,
    builder: (BuildContext context){
      return StatefulBuilder(
        builder: (context, setThisState) {
          return  AlertDialog(
          title:  Text("Choose Color $_colorPickerIndex/2"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _colorPickerIndex == 1? _gradientStart: _gradientEnd,
              onColorChanged: (color){
                setState(() {
                _colorPickerIndex == 1?(_gradientStart = color):(_gradientEnd = color);
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
              TextButton(
              onPressed: (){
                if(_colorPickerIndex == 2){
                setAndSaveGradientColors(_gradientStart, _gradientEnd);
                  Navigator.of(context).pop();
                }else{
                 setThisState(() {
                  _colorPickerIndex = 2;
                });
                }
              },
              child: const Text("Apply",),
            ),
          ],
      );
        }
        );
    }
  );
}


Widget _profilePicture(){
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top:30.0),
      child: Stack(
        children: [
              FutureBuilder(
                future: getProfilePic(),
                builder: (context, snapshot) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                      height: _headerExpanded? 120: 0,
                      width:  _headerExpanded? 120: 0,
                      decoration:  BoxDecoration(
                        shape: BoxShape.circle,
                        image:  DecorationImage(
                          image: NetworkImage(snapshot.data.toString()),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      ),
                    );
                }
              ),
                 Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height:_editMode ? 30: 0,
                    width: _editMode ? 30: 0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 0, 0, 0),
                      
                    ),
                    child:  IconButton(
                      onPressed: (){
                        _startCamera();
                      },
                      icon:  Icon(Icons.add_a_photo, color: Colors.white, size: _editMode ? 16: 0,),
                    ),
                  ),
                )
        ],
      )
      
     
    ),
  );
}

Widget _username(String username){
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top:5.0),
      child: Text(
        username,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
    ),
  );
}




}