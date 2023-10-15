import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rebeal/camera/camera.dart';
import 'package:rebeal/model/post.module.dart';
import 'package:rebeal/model/user.module.dart';
import 'package:rebeal/state/auth.state.dart';
import 'package:rebeal/state/post.state.dart';
import 'package:rebeal/state/search.state.dart';
import 'package:rebeal/styles/color.dart';
import 'package:rebeal/pages/myprofile.dart';
import 'package:rebeal/widget/feedpost.dart';
import 'package:rebeal/widget/gridpost.dart';
import 'package:rebeal/widget/list.dart';
import '../widget/custom/rippleButton.dart';
import 'feed.dart';
import 'package:pedometer/pedometer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  ScrollController _scrollController = ScrollController();
  bool _isScrolledDown = false;
  bool _isGrid = false;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    var authState = Provider.of<AuthState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.getCurrentUser();
      initPosts();
      initSearch();
      initProfile();
      initPlatformState(authState);
    });
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void onStepCount(StepCount event, AuthState state) {
    print(event);
    var model = state.userModel!.copyWith(
      key: state.userModel!.userId,
      displayName: state.userModel!.displayName,
      userName: state.userModel!.userName,
      bio: state.userModel!.bio,
      localisation: state.userModel!.localisation,
      profilePic: state.userModel!.profilePic,
      daily: event.steps,
    );
    state.updateUserProfile(
      model
    );
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState(AuthState state) {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen((event){
      onStepCount(event, state);
    }).onError(onStepCountError);

    if (!mounted) return;
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initPosts() {
    var state = Provider.of<PostState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _isScrolledDown = true;
      });
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        _isScrolledDown = false;
      });
    }
  }

  Future _bodyView() async {
    if (_isGrid) {
      setState(() {
        _isGrid = false;
      });
    } else {
      setState(() {
        _isGrid = true;
      });
    }
  }

  int tab = 0;
  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    final state = Provider.of<SearchState>(context);
    return Scaffold(
        extendBody: true,
        bottomNavigationBar: AnimatedOpacity(
            opacity: tab == 1 ? 0 : 1,
            duration: Duration(milliseconds: 301),
            child: Container(
                height: 150,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if((authState.profileUserModel?.daily ?? 0) >= 5000) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CameraPage()));
                          }
                        },
                        child: 
                        Stack(
                          alignment: Alignment.center,
                          children: [Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 6),
                                shape: BoxShape.circle,
                              )),
                                Icon(
                                Icons.lock_outline,
                                size: (((authState.profileUserModel?.daily ?? 0) < 5000) ? 1 : 0) * 40 ,
                                )
                              ])),
                    Container(
                      height: 40,
                    ),
                  ],
                ))),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FeedPage()));
            },
            child: Transform(
                transform: Matrix4.identity()..scale(-1.0, 1.0, -1.0),
                alignment: Alignment.center,
                child: Icon(
                  Icons.people,
                  size: 30,
                )),
          ),
          toolbarHeight: 37,
          flexibleSpace: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10, top: 59),
                child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyProfilePage()));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                            height: 30,
                            width: 30,
                            child: CachedNetworkImage(
                                imageUrl: authState
                                        .profileUserModel?.profilePic ??
                                    "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg")))),
              )
            ],
          ),
          bottom: _isScrolledDown && tab != 1 || _isGrid
              ? null
              : TabBar(
                  onTap: (index) {
                    setState(() {
                      tab = index;
                    });
                    HapticFeedback.mediumImpact();
                  },
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: Colors.white,
                  unselectedLabelColor: ReBealColor.ReBealLightGrey,
                  indicatorColor: Colors.transparent,
                  indicatorWeight: 1,
                  tabs: [
                    FadeInUp(
                        child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Tab(
                              child: Text(
                                'Friends',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))),
                    FadeInUp(
                        child: Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: Tab(
                          child: Text(
                        'Find',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    )),
                    FadeInUp(
                        child: Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: Tab(
                          child: Text(
                        'For You',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    )),
                    FadeInUp(
                        child: Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Tab(
                          child: Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    )),
                  ],
                ),
          elevation: 0,
          title: Image.asset(
            "assets/logo/logo.png",
            height: 100,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: FadeIn(
            child: AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 500),
                child: _isGrid
                    ? TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                            Consumer<PostState>(
                                builder: (context, state, child) {
                              final now = DateTime.now();
                              final List<PostModel>? list = state
                                  .getPostLists(authState.userModel)!
                                  .where((x) =>
                                      now
                                          .difference(
                                              DateTime.parse(x.createdAt))
                                          .inHours <
                                      24)
                                  .toList();
                              while (list!.length < 10) {
                                list.add(PostModel(
                                  imageFrontPath:
                                      "https://htmlcolorcodes.com/assets/images/colors/black-color-solid-background-1920x1080.png",
                                  imageBackPath:
                                      "https://htmlcolorcodes.com/assets/images/colors/black-color-solid-background-1920x1080.png",
                                  createdAt: "",
                                  user: UserModel(
                                    displayName: "",
                                  ),
                                ));
                              }
                              return RefreshIndicator(
                                  color: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  onRefresh: () {
                                    HapticFeedback.mediumImpact();
                                    return _bodyView();
                                  },
                                  child: AnimatedOpacity(
                                      opacity: _isGrid ? 1 : 0,
                                      duration: Duration(milliseconds: 1000),
                                      child: Padding(
                                          padding: EdgeInsets.all(15),
                                          child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 4,
                                                      childAspectRatio: 0.8,
                                                      mainAxisSpacing: 10,
                                                      crossAxisSpacing: 10),
                                              controller: _scrollController,
                                              itemCount: list.length,
                                              itemBuilder: (context, index) {
                                                return GridPostWidget(
                                                    postModel: list[index]);
                                              }))));
                            }),
                          ])
                    : TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                            Consumer<PostState>(
                                builder: (context, state, child) {
                              final List<PostModel>? list =
                                  state.getPostList(authState.userModel);

                              return RefreshIndicator(
                                  color: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  onRefresh: () {
                                    HapticFeedback.mediumImpact();
                                    return _bodyView();
                                  },
                                  child: AnimatedOpacity(
                                      opacity: !_isGrid ? 1 : 0,
                                      duration: Duration(milliseconds: 300),
                                      child: enough_steps(
                                          authState,
                                          ListView.builder(
                                              controller: _scrollController,
                                              itemCount: list?.length ?? 0,
                                              itemBuilder: (context, index) {
                                                return FeedPostWidget(
                                                  postModel: list![index],
                                                );
                                              }))));
                            }),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 140,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  decoration: BoxDecoration(
                                      color: ReBealColor.ReBealDarkGrey,
                                      borderRadius: BorderRadius.circular(20)),
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: 20, left: 10),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Container(
                                                height: 25,
                                                width: 40,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "NEW",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                              ))),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: 10, left: 10),
                                          child: Text(
                                            "DISCOVER YOUR\nFRIENDS",
                                            style: TextStyle(
                                                fontSize: 28,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )),
                                      Container(
                                          height: 300,
                                          child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Container(
                                                  height: 60,
                                                  child: UserTilePage(
                                                    user:
                                                        state.userlist![index],
                                                    isadded: true,
                                                  ));
                                            },
                                            itemCount: 2,
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                            bottom: 20,
                                            right: 15,
                                          ),
                                          child: RippleButton(
                                              splashColor: Colors.transparent,
                                              child: Container(
                                                  height: 55,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Share BeSTEP. It's more fun with friends!",
                                                    style: TextStyle(
                                                        fontFamily: "icons.ttf",
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ))),
                                              onPressed: () {})),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Consumer<PostState>(
                                builder: (context, state, child) {
                              final now = DateTime.now();
                              final List<PostModel>? list = state
                                  .getPostLists(authState.userModel)!
                                  .where((x) =>
                                      now
                                          .difference(
                                              DateTime.parse(x.createdAt))
                                          .inHours <
                                      24)
                                  .toList();
                              return enough_steps(
                                  authState,
                                  ListView.builder(
                                      controller: _scrollController,
                                      itemCount: list?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        return FeedPostWidget(
                                          postModel: list![index],
                                        );
                                      }));
                            }),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Steps Taken',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Text(
                                    _steps,
                                    style: TextStyle(fontSize: 60),
                                  ),
                                  Divider(
                                    height: 100,
                                    thickness: 0,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Pedestrian Status',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Icon(
                                    _status == 'walking'
                                        ? Icons.directions_walk
                                        : _status == 'stopped'
                                            ? Icons.accessibility_new
                                            : Icons.error,
                                    size: 100,
                                  ),
                                  Center(
                                    child: Text(
                                      _status,
                                      style: _status == 'walking' ||
                                              _status == 'stopped'
                                          ? TextStyle(fontSize: 30)
                                          : TextStyle(
                                              fontSize: 20, color: Colors.red),
                                    ),
                                  )
                                ])
                          ]))));
  }
}

Widget enough_steps(AuthState state, Widget w) {
  if ((state.profileUserModel?.daily ?? 0) < 5000) {
    return Center(
        child:
        Stack(
          children: [
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 35)),
                      SizedBox(
                          width: 200,
                          height: 200,
                          child:
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: (state.profileUserModel?.daily ?? 0) / 5000),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, _) =>  CircularProgressIndicator(
                              value: value,
                              color: Colors.lightGreenAccent,
                              backgroundColor: Colors.grey,
                              strokeWidth: 10,
                            )),
                      )


                    ])
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go Walk Some More!',
                    style: TextStyle(fontSize: 30),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 25)),
                  Transform(
                      transform: Matrix4.identity()..scale(-1.0, 1.0, -1.0),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.directions_run,
                        size: 150,
                      )),
                ],
              ),
            )
      ],
    )
    );
  }
  return w;
}
