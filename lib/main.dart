import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thentic_app/constants/app_bloc_providers.dart';
import 'package:thentic_app/constants/app_dis.dart';
import 'package:thentic_app/constants/app_repository_providers.dart';
import 'package:thentic_app/cubits/feed/feed_cubit.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/cubits/utility/utility_cubit.dart';
import 'package:thentic_app/global_cubit_observer.dart';
import 'package:thentic_app/resources/user_repository.dart';
import 'package:thentic_app/views/feed.dart';
import 'package:thentic_app/views/login_signup.dart';
import 'package:thentic_app/navigator.dart';
import 'firebase_options.dart';

late List<CameraDescription> _cameras;


Future<void> main() async {
  
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  AppDIs.dependencyInjection();

  _cameras = await availableCameras();
  GetIt.I<UtilityCubit>().setCameras(_cameras);

  BlocOverrides.runZoned(() {
    runApp(MyApp());  
  },
  blocObserver: GlobalCubitObserver()
  );
  // initializeApp();
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  UserRepository _userRepository = UserRepository();

  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MultiRepositoryProvider(
      providers: AppRepositoryProviders.repositoryProviders,
       child: MultiBlocProvider(
        providers: AppBlocProviders.blocProviders,
        child: MaterialApp(
          title: 'Thentic',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.workSansTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserInitial) {
                return LoginSignUpPage();
              } else if (state is UserLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is UserLoggedIn) {
                return NavigatorPage(userId: state.userId);
              } else {
                return LoginSignUpPage();
              }
            },
          ),
        ),
       )
       );
    
  
  }
}
