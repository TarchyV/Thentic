import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/views/feed.dart';
import 'package:ionicons/ionicons.dart';


class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({Key? key}) : super(key: key);

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {

  bool _isLogin = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if(state is UserInitial){
          GetIt.I<UserCubit>().getUser();
          }
        },
        builder: (context, state) {
          return Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Thentic', style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                  ),
             !_isLogin?inputField("Username", const Icon(Ionicons.person, color: Color.fromARGB(255, 79, 152, 235)), MediaQuery.of(context).size.width * 0.8, _nameController):Container(),
              inputField("Email", const Icon(Icons.email, color: Color.fromARGB(255, 79, 152, 235)), MediaQuery.of(context).size.width * 0.8, _emailController),
              inputField("Password", const Icon(Icons.vpn_key, color: Color.fromARGB(255, 79, 152, 235)), MediaQuery.of(context).size.width * 0.8, _passwordController),
                //  Terms of Service
                const SizedBox(
                  height: 20,
                ),
                !_isLogin? const Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: Text('By signing up, you agree to Thentic\'s Terms of Service and Privacy Policy', style: TextStyle(
                    fontSize: 8,
                    color: Colors.black,
                  )),
                ): const Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: Text('Remember Me', style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
           InkWell(
              onTap: () {
                if(_isLogin){
                  BlocProvider.of<UserCubit>(context).email_login(_emailController.text, _passwordController.text);
                }else{
                  BlocProvider.of<UserCubit>(context).email_register(_emailController.text, _passwordController.text, _nameController.text);
                }
              },
             child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 79, 152, 235),
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 79, 152, 235),
                        Color.fromARGB(255, 9, 104, 212),
                      ],
                    ),
                  ),
                  child:  Center(
                    child: Text( _isLogin? "Sign In": "Sign up", style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ),
           ),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: 1,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("or"),
                ),
                 Padding(
                  padding: const EdgeInsets.only(right:8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: 1,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
      
         
                  
                  googleButton()
                    
                  
                ],
              ),
            );
        },
      ),
    );
  }

Widget googleButton(){
     return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.black54,
              width: 2,
            ),
            // box shadow
            boxShadow: const [
               BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                spreadRadius: 1.0,
                offset: Offset(
                  5.0,
                  6.0,
                ),
              ),
            ],
          ),
          child: IconButton(
            onPressed: (){
              GetIt.I<UserCubit>().signInWithGoogle();

            },
            icon: const Icon(Ionicons.logo_google, color: Color(0xffDB4437),),
            ),
        );
}



Widget inputField(String label, Icon icon, double width,TextEditingController controller) {
  return  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color.fromARGB(255, 235, 235, 235),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: 5.0,
            offset: Offset(
              4.0,
              6.0,
            ),
          ),
        ],

      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextField(
          controller: controller,
    style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
        
          ),
          decoration: InputDecoration(
            icon: icon,
            hintText: label,
            border: InputBorder.none
          ),
        ),
      ),
    ),
  );
}
  
}

