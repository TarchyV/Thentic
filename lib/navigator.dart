

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/navigation/navigation_cubit.dart';
import 'package:thentic_app/views/create_post.dart';
import 'package:thentic_app/views/feed.dart';
import 'package:thentic_app/views/profile.dart';

class NavigatorPage extends StatefulWidget {
  final String userId;
  NavigatorPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NavigatorPage> createState() => _NavigatorState();
}



class _NavigatorState extends State<NavigatorPage> {
TabItem currentTab = TabItem.home;
TabItem previousTab = TabItem.home;

  void _selectTab(TabItem tabItem) {
    setState(() {
      previousTab = currentTab;
      currentTab = tabItem;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<NavigationCubit, NavigationState>(
        listener: (context, state) {
          if (state is NavigationSelected) {
            _selectTab(state.page);
          }
        },
        builder: (context, state) {
          return _buildBody();
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -5), // changes position of shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          onTap: (index) => _selectTab(TabItem.values[index]),
          currentIndex: TabItem.values.indexOf(currentTab),
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          fixedColor: Color.fromARGB(255, 255, 255, 255),
          items: const [
             BottomNavigationBarItem(
              icon: Icon(Icons.home,
              color: Color.fromARGB(255, 77, 77, 77)),
              label: 'Home',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.explore,
              color: Color.fromARGB(255, 77, 77, 77),
              ),
              label: 'Explore',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.add,
              color: Color.fromARGB(255, 77, 77, 77),),
              label: 'Create',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.person,
              color: Color.fromARGB(255, 77, 77, 77),),
              label: 'Profile',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.message,
              color: Color.fromARGB(255, 77, 77, 77),),
              label: 'Messages',

            ),
          ],
        ),
      ),
    );
  }


void emitRouteToCubit(TabItem currentRoute, TabItem? previousTab){
  if(currentRoute == TabItem.home){
    GetIt.I<NavigationCubit>().selectTab(currentRoute, previousTab: previousTab);
  }
  if(currentRoute == TabItem.explore){
    GetIt.I<NavigationCubit>().selectTab(currentRoute, previousTab: previousTab);
  }
  if(currentRoute == TabItem.create){
    GetIt.I<NavigationCubit>().selectTab(currentRoute, previousTab: previousTab);
  }
  if(currentRoute == TabItem.profile){
    GetIt.I<NavigationCubit>().selectTab(currentRoute, previousTab: previousTab);
  }
  if(currentRoute == TabItem.messages){
    GetIt.I<NavigationCubit>().selectTab(currentRoute, previousTab: previousTab);
  }
}




  Widget _buildBody() {
    emitRouteToCubit(currentTab, previousTab);
    switch (currentTab) {
      case TabItem.home:
        return FeedPage();
      case TabItem.explore:
        return const Center(
          child: Text('Explore'),
        );
      case TabItem.create:
        return const CameraPage();
      case TabItem.profile:
        return ProfilePage(userId: widget.userId);
      case TabItem.messages:
        return const Center(
          child: Text('Messages'),
        );
    }
    
  }

}