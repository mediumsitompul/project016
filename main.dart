import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';


main(){
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(appBar: AppBar(title: const Center(child: Text('Pagination\n(Restapi_ListView_Pagination)')),),
      body: HomePage(),
      ),
    );
  }
}



class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    //...............................................
    int _page = 1;
    final int _limit = 10;
    bool _isFirstLoadRunning = false;
    List _listData = [];
    bool _hasNextPage = true; //n-2, will be processed
    bool _isLoadMoreRunning = false;
    //...............................................

  void _firstLoad() async {

    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      const baseUrl = 'http://192.168.100.100:8087/pagination';
      final res = await http.get(Uri.parse("$baseUrl?_page=$_page&_limit=$_limit"));
      setState(() {
        _listData = json.decode(res.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });

  }

  //,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,


  // This function will be triggered whenver the user scroll
  // to near the bottom of the list view (n-1)

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300)

      {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1
      try {
        const baseUrl = 'http://192.168.100.100:8087/pagination';
        final res = await http.get(Uri.parse("$baseUrl?_page=$_page&_limit=$_limit"));
        final List fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _listData.addAll(fetchedPosts);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      }
      catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }
      setState(() {
        _isLoadMoreRunning = false;
      });
    }

  }


  //.................................................................................................................................
  // The controller for the ListView
  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
  _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }


    @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  //==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          :
          Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: _listData.length,
                    itemBuilder: (_, index) => Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        leading: Text(_listData[index]['id'].toString()),
                        title: Text(_listData[index]['title']),
                        subtitle: Text(_listData[index]['body']),
                      ),
                    ),
                  ),
                ),

                // when the _loadMore function is running
                if (_isLoadMoreRunning == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // When nothing else to load
                if (_hasNextPage == false)
                  Container(
                    padding: const EdgeInsets.only(top: 30, bottom: 40),
                    color: Colors.amber,
                    child: const Center(
                      child: Text('You have fetched all of the content'),
                    ),
                  ),
              ],
            ),
    );
  }




}
