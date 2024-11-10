import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_client_side/colors/colors.dart';
import 'package:staff_client_side/constant/sharedprefs.dart';
import 'package:staff_client_side/features/home/bloc/home_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:staff_client_side/features/home/model/pushnotificationModel.dart';
import 'package:staff_client_side/features/navigation/screens/navigation.dart';
import 'package:staff_client_side/features/notification/screens/notification.dart';
import 'package:staff_client_side/main.dart';
import 'package:staff_client_side/server/server.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:remixicon/remixicon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc homeBloc = HomeBloc();

  int notificationCount = 0;
  late int _totalNotificationCounter;
  PushNotification? _notificationInfo;
  late final FirebaseMessaging _messaging;

  void registerNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print("user granted permission");

      //main message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          message.notification!.title,
          message.notification!.body,
          message.data['title'],
          message.data['body'],
        );
        setState(() {
          _totalNotificationCounter++;
          prefs.setInt('notifi_count', _totalNotificationCounter);
          _notificationInfo = notification;
        });

        showSimpleNotification(
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              leading: const CircleAvatar(
                radius: 15,
                backgroundColor: Color.fromARGB(255, 201, 223, 255),
                child: Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                  color: Color.fromARGB(255, 57, 83, 125),
                ),
              ),
              title: Text(
                _notificationInfo!.title!,
                style: TextStyle(
                    color: AdaptiveTheme.of(context).mode.isDark
                        ? Colors.white
                        : Colors.black,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _notificationInfo!.body!,
                style: TextStyle(
                    color: AdaptiveTheme.of(context).mode.isDark
                        ? const Color.fromARGB(255, 187, 187, 187)
                        : Colors.grey,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Text(_notificationInfo!.title!),
          // leading: Text(_totalNotificationCounter.toString()),
          duration: const Duration(seconds: 3),
          background: AdaptiveTheme.of(context).mode.isDark
              ? Colors.black
              : Colors.white,
        );
      });
    } else {
      // ignore: avoid_single_cascade_in_expression_statements,, use_build_context_synchronously
      // AwesomeDialog(
      //   context: context,
      //   dismissOnBackKeyPress: false,
      //   dismissOnTouchOutside: false,
      //   btnOkText: "Allow",
      //   btnOkIcon: Icons.notifications,
      //   dialogType: DialogType.warning,
      //   animType: AnimType.rightSlide,
      //   title: 'Please Enable Notification',
      //   desc: "Please click on allow  and enable the Notification",
      //   btnOkOnPress: () {
      //    // AppSettings.openNotificationSettings();
      //   },
      // )..show();
      // print("permission declined");
    }
  }

  //check the i initial message that we receive
  checkForInitialMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        initialMessage.notification?.title,
        initialMessage.notification?.body,
        initialMessage.data['title'],
        initialMessage.data['body'],
      );

      setState(() {
        _totalNotificationCounter++;
        prefs.setInt('notifi_count', _totalNotificationCounter);
        _notificationInfo = notification;
      });
    }
  }

  backGround() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        message.notification!.title,
        message.notification!.body,
        message.data['title'],
        message.data['body'],
      );

      setState(() {
        _totalNotificationCounter++;
        prefs.setInt('notifi_count', _totalNotificationCounter);
        _notificationInfo = notification;
      });
    });
  }

  @override
  void initState() {
    // FirebaseUtils.updateFirebaseToken();

    // print('the print is ${SharedPrefs().dob}');

    // 1. handling the background state for app
    backGround();

    //2. normal
    registerNotification();

    //3. when app is in terminated state
    checkForInitialMessage();

    _totalNotificationCounter = notificationCount;

    homeBloc.add(HomeInitialEvent());
    // FirebaseUtils.updateFirebaseToken();
    // dashboardBloc.add(NewsFeedDashborad());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: homeBloc,
      listenWhen: (previous, current) => current is HomeActionState,
      buildWhen: (previous, current) => current is! HomeActionState,
      listener: (context, state) {
        if (state is NavigationPageState) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NavigationPage(),
              ));
        } else if (state is NavigationToNotificationState) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPage(),
              ));
        }
      },
      builder: (context, state) {
        switch (state.runtimeType) {
          case HomeLoadState:
            return Scaffold(
              backgroundColor: AdaptiveTheme.of(context).mode.isDark
                  ? const Color.fromARGB(255, 56, 56, 56)
                  : Colors.white,
              appBar: AppBar(
                backgroundColor: AdaptiveTheme.of(context).mode.isDark
                    ? const Color.fromARGB(255, 56, 56, 56)
                    : Colors.white,
                // backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                leading: Transform.translate(
                  offset: const Offset(-20, 0),
                  child: Icon(Icons.android,
                      color: AdaptiveTheme.of(context).mode.isLight
                          ? Colors.transparent
                          : Colors.transparent),
                ),
                titleSpacing: -40,
                centerTitle: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 10, bottom: 0, right: 35),
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: "Welcome,",
                            style: GoogleFonts.aBeeZee(
                              textStyle: TextStyle(
                                color: AdaptiveTheme.of(context).mode.isDark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      ' ${SharedPrefs().name.capitalizeFirstLetter()}',
                                  style: GoogleFonts.aBeeZee(
                                    textStyle: TextStyle(
                                      color:
                                          AdaptiveTheme.of(context).mode.isDark
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                      icon: Stack(
                        children: <Widget>[
                          const Icon(
                            Icons.notifications,
                            size: 28,
                            color: Color.fromARGB(255, 249, 187, 1),
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 13,
                              ),
                              child: _totalNotificationCounter > 9
                                  ? const Text(
                                      '9+',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      '$_totalNotificationCounter',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          )
                        ],
                      ),
                      onPressed: () async {
                        homeBloc.add(NavigateToNotificationPage());
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  GestureDetector(
                    onTap: () {
                      homeBloc.add(NavigateToNavigationPage());
                    },
                    child: Icon(
                      Remix.menu_3_line,
                      size: 28,
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case DashboardMenuListState:
            final successState = state as DashboardMenuListState;
            return Scaffold(
              backgroundColor: AdaptiveTheme.of(context).mode.isDark
                  ? const Color.fromARGB(255, 56, 56, 56)
                  : Colors.white,
              appBar: AppBar(
                backgroundColor: AdaptiveTheme.of(context).mode.isDark
                    ? const Color.fromARGB(255, 56, 56, 56)
                    : Colors.white,
                // backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                leading: Transform.translate(
                  offset: const Offset(-20, 0),
                  child: Icon(Icons.android,
                      color: AdaptiveTheme.of(context).mode.isLight
                          ? Colors.transparent
                          : Colors.transparent),
                ),
                titleSpacing: -40,
                centerTitle: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 10, bottom: 0, right: 35),
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: "Welcome,",
                            style: GoogleFonts.aBeeZee(
                              textStyle: TextStyle(
                                color: AdaptiveTheme.of(context).mode.isDark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      ' ${SharedPrefs().name.capitalizeFirstLetter()}',
                                  style: GoogleFonts.aBeeZee(
                                    textStyle: TextStyle(
                                      color:
                                          AdaptiveTheme.of(context).mode.isDark
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AdaptiveTheme.of(context).mode.isDark
                        ? const Color.fromARGB(255, 56, 56, 56)
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: ClipOval(
                            child: SharedPrefs().imagePath != ''
                                ? Image.network(
                                    Server.img + SharedPrefs().imagePath,
                                    fit: BoxFit.cover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: const Color.fromARGB(
                                            255, 234, 242, 255),
                                        boxShadow: [
                                          BoxShadow(
                                              color: const Color.fromARGB(
                                                      255, 61, 61, 61)
                                                  .withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 1)),
                                        ],
                                      ),
                                      child: Icon(
                                        IconlyBold.profile,
                                        color: MyColors.primaryColor,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                          )),
                    ),
                  ),
                  IconButton(
                      icon: Stack(
                        children: <Widget>[
                          const Icon(
                            Icons.notifications,
                            size: 28,
                            color: Color.fromARGB(255, 249, 187, 1),
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 13,
                              ),
                              child: _totalNotificationCounter > 9
                                  ? const Text(
                                      '9+',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      '$_totalNotificationCounter',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          )
                        ],
                      ),
                      onPressed: () async {
                        homeBloc.add(NavigateToNotificationPage());
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  GestureDetector(
                    onTap: () {
                      homeBloc.add(NavigateToNavigationPage());
                    },
                    child: Icon(
                      Remix.menu_3_line,
                      size: 28,
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    if (SharedPrefs().role != 'ADMIN')
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0),
                        child: Container(
                          decoration: const BoxDecoration(),
                          //height: 200,
                          width: MediaQuery.of(context).size.width,

                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 10, bottom: 0, right: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                                color: AdaptiveTheme.of(context).mode.isDark
                                    ? const Color.fromARGB(255, 78, 78, 78)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color:
                                //         const Color.fromARGB(255, 201, 201, 201)
                                //             .withOpacity(0.5),
                                //     spreadRadius:
                                //         AdaptiveTheme.of(context).mode.isDark
                                //             ? 0
                                //             : 0.5,
                                //     blurRadius:
                                //         AdaptiveTheme.of(context).mode.isDark
                                //             ? 0
                                //             : 1,
                                //     offset: AdaptiveTheme.of(context).mode.isDark
                                //         ? const Offset(0, 0)
                                //         : const Offset(0, 1),
                                //   ),
                                // ]
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 33,
                                    backgroundColor: AdaptiveTheme.of(context)
                                            .mode
                                            .isDark
                                        ? const Color.fromARGB(255, 78, 78, 78)
                                        : const Color.fromARGB(
                                            255, 255, 255, 255),
                                    child: CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                          255, 248, 250, 253),
                                      radius: 23,
                                      child: SharedPrefs().trainingCenterLogo !=
                                              ''
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: SizedBox(
                                                  width: 85,
                                                  height: 60,
                                                  child: SizedBox(
                                                    height: 0,
                                                    child: CachedNetworkImage(
                                                      imageUrl: SharedPrefs()
                                                          .trainingCenterLogo,
                                                      placeholder: (context,
                                                              url) =>
                                                          const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 0),
                                              child: Icon(
                                                Icons.apartment_rounded,
                                                size: 30,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: Text(
                                          SharedPrefs()
                                              .trainingCenterName
                                              .toUpperCase(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: AdaptiveTheme.of(context)
                                                        .mode
                                                        .isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontFamily: "Lato",
                                                fontWeight: FontWeight.bold),
                                          )))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    successState.dashboardMenuList.isEmpty
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 15, left: 10, right: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                                color: AdaptiveTheme.of(context).mode.isDark
                                    ? const Color.fromARGB(255, 78, 78, 78)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 201, 201, 201)
                                            .withOpacity(0.5),
                                    spreadRadius:
                                        AdaptiveTheme.of(context).mode.isDark
                                            ? 0
                                            : 0.5,
                                    blurRadius:
                                        AdaptiveTheme.of(context).mode.isDark
                                            ? 0
                                            : 1,
                                    offset:
                                        AdaptiveTheme.of(context).mode.isDark
                                            ? const Offset(0, 0)
                                            : const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 30, bottom: 0, left: 5, right: 5),
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          3, // Number of columns in the grid
                                      crossAxisSpacing: 3.6,
                                      mainAxisSpacing: 2.0,
                                    ),
                                    itemCount:
                                        successState.dashboardMenuList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacementNamed(
                                                context,
                                                successState
                                                    .dashboardMenuList[index]
                                                    .route);
                                            // Handle feedback widget tap
                                          },
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor:
                                                    AdaptiveTheme.of(context)
                                                            .mode
                                                            .isDark
                                                        ? const Color.fromARGB(
                                                            255, 56, 56, 56)
                                                        : const Color.fromARGB(
                                                            255, 237, 243, 248),
                                                child: CachedNetworkImage(
                                                  filterQuality:
                                                      FilterQuality.low,
                                                  imageUrl: Server.img +
                                                      successState
                                                          .dashboardMenuList[
                                                              index]
                                                          .iconPath,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0, right: 0),
                                                  child: Text(
                                                    successState
                                                        .dashboardMenuList[
                                                            index]
                                                        .title,
                                                    style: GoogleFonts.lato(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            )),
                  ],
                ),
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}
