import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/feed/feed_cubit.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/cubits/utility/utility_cubit.dart';
import 'package:thentic_app/resources/post.dart';
import 'package:thentic_app/views/feed.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  
late CameraController controller;

late VideoPlayerController _videoPlayerController;

TextEditingController _captionController = TextEditingController();

ScrollController _scrollController = ScrollController();


List<CameraDescription>? _cameras;
int selectedCamera = 1;

bool _isRecording = false;
double maxRecordTime = 30;
double currentRecordTime = 0;

bool _editMode = false;
bool _isImage = false;

String _videoPath = "";
String _imagePath = "";



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
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }



void loadingPopUp() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text("Uploading..."),
          ],
        ),
      );
    }
  );
}



   _captureImage() async {
    try {
      final path = await controller.takePicture().then((value) { 
        setState(() {
          _imagePath = value.path;
          _isImage = true;
          _editMode = true;
        }); 
      }
      );
      print(path);
    } catch (e) {
      print(e);
    }
  }

  _recordVideo() async {
    try {
      await controller.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  _stopVideoRecording() async {
    try {
      final path = await controller.stopVideoRecording().then((value) {
        print("VIDEO PATH ${value.path}");
        _videoPlayerController = VideoPlayerController.file(File(value.path));
        setState(() {
          _videoPath = value.path;
          _isImage = false;
          _editMode = true;
          _videoPlayerController.initialize().then((_) {
            _videoPlayerController.play();
            _videoPlayerController.setLooping(true);
            setState(() {});
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }
String formatDateTimeOfNow(){
  var now = DateTime.now();
  var date = now.toString().substring(0,10);
  var time = now.toString().substring(11,19);
  //time to 12 hour format
  var hour = int.parse(time.substring(0,2));
  var minute = time.substring(3,5);
  var second = time.substring(6,8);
  var period = "AM";
  if(hour > 12){
    hour = hour - 12;
    period = "PM";
  }
  var time12 = hour.toString() + ":" + minute + " " + period;

  //change date format to dd/mm/yyyy
  var dateSplit = date.split("-");
  var dateNew = dateSplit[2] + "/" + dateSplit[1] + "/" + dateSplit[0];


  return dateNew + " " + time12;
}

Future<void> post() async {
  loadingPopUp();
  print("==========POSTING=========\n Caption: ${_captionController.text}");
  print("Date: ${formatDateTimeOfNow()}");
  if(_isImage){
    print("Image: ${_imagePath}");
  }else{
    print("Video: ${_videoPath}");
  }
  print("==========================");
  File file = File(_isImage ? _imagePath : _videoPath);
  PostType postType = _isImage ? PostType.IMAGE : PostType.VIDEO;
  await GetIt.I<UserCubit>().createPost(file, _captionController.text, postType).then((value) {
    Navigator.pop(context);
    Navigator.pop(context);
    GetIt.I<FeedCubit>().updateFeed();
  });
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.355,
          child: Stack(
            children: [
            (_editMode == false)?  SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CameraPreview(
                  controller,  
                ),  
              ): Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  Stack(
                    children: [
                      contentPreview(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:15),
                        child: editModeTopRow(),
                      ),
                    ],
                  )
                  
                ],
              ),
             
      
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                (_editMode == false)?  SizedBox(height: MediaQuery.of(context).size.height * 0.87):SizedBox(height: MediaQuery.of(context).size.height * 0.92),
                 (_editMode == false)? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cameraFlipButton(),
                      _cameraActionButton(),
                      _flashControlButton(),
                  ],):
                 //Text input field for caption
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(
                          hintText: "Add a caption...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15)
                        ),
                        //on focus set scroll to bottom
                        onTap: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        //on focus lost set scroll to top
                        onEditingComplete: () {
                          _scrollController.animateTo(
                            _scrollController.position.minScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                          //hide keyboard
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
    
                ],
              ),
            ),
            ],
            ),
        ),
      )
    );
  }





Widget editModeTopRow() {
return Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0),
          child: IconButton(
            onPressed: (){
              setState(() {
                _editMode = false;
              });
            },
            icon: const Icon(Icons.close, color: Colors.white, size: 30,)
          ),
        ),
        //Time Stamp 
        Text("${formatDateTimeOfNow()}", style: TextStyle(
          color: Colors.white,
           fontSize: 14,
           background: 
           Paint()..shader = const LinearGradient(
             colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 17, 17, 17)]
           ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))
           ),),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0),
          child: IconButton(
            onPressed: (){
              post();
          }, icon: const Icon(Icons.check, color: Colors.white, size: 30,)),
        )

            ],
      );
}






  double contentBorderRadius = 8;
  Widget contentPreview() {
 return Center(
   child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration:  BoxDecoration(
                borderRadius: BorderRadius.circular(contentBorderRadius),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow:  [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                
                 
                ],

              ),
              child: (_isImage == true)? ClipRRect(
                borderRadius: BorderRadius.circular(contentBorderRadius),
                child: Image.file(
                  File(_imagePath),
                  fit: BoxFit.cover,
                ),
              ): ClipRRect(
                borderRadius: BorderRadius.circular(contentBorderRadius),
                child: VideoPlayer(
                  _videoPlayerController,
                ),
              ),
          
            ),
 );
  }


  
  Widget _recordTimeProgressBar(){
    return Container(
      height: 5,
      width: 100,
      color: Colors.red,
    );

  }


  Widget _cameraFlipButton(){
    return Padding(
    padding: const EdgeInsets.only(left: 10.0, top:30),
    child: InkWell(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.cameraswitch_outlined),
      ),
      onTap: () {
        if (_cameras!.length > 1) {
          selectedCamera = selectedCamera == 0 ? 1 : 0;
          _initializeCamera();
        }
      },
    ),
  );
  }

  Widget _flashControlButton(){
    return Padding(
    padding: const EdgeInsets.only(right: 10.0, top:30),
    child: InkWell(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child:  Icon(      
        controller.value.focusMode == (FlashMode.off)?  Icons.flash_off_outlined:
        controller.value.focusMode == (FlashMode.auto)?  Icons.flash_auto_outlined:
        controller.value.focusMode == (FlashMode.always)?  Icons.flash_on_outlined:
        Icons.flash_off_outlined,
        ),
      ),
      onTap: () {
        //Switch between Flash On Flash Off and Auto
        if (controller.value.focusMode == (FlashMode.off)) {
          controller.setFlashMode(FlashMode.off);
        } else if (controller.value.focusMode == (FlashMode.auto)) {
          controller.setFlashMode(FlashMode.auto);
        } else if (controller.value.focusMode == (FlashMode.always)) {
          controller.setFlashMode(FlashMode.always);
        }
   
      

       
      },
    ),
  );
  }
    Widget _cameraActionButton(){
    return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _isRecording? Colors.red[400]: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: _isRecording? Colors.black: Colors.grey, 
            width: _isRecording? 5 : 3
            
            ),
        ),
      ),
      onTap: () {
        //Take a picture
        if (!_isRecording) {
          _captureImage();
        }
       
      },
      onLongPressStart: (details) {
        //Start recording
      setState(() {
        _isRecording = true;
      });
        _recordVideo();
    

     
      },
      onLongPressEnd: (details) {
        //Stop recording
      setState(() {
        _isRecording = false;
      });
      _stopVideoRecording(); 
      },

    ),
  );
  }

}

