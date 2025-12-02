import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:must_eat_place/view/insert_place.dart';
import 'package:must_eat_place/view/show_place.dart';
import 'package:must_eat_place/view/update_place.dart';
import 'package:must_eat_place/vm/database_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // === Property ===

  late DatabaseHandler _handler;

  @override
  void initState() {
    super.initState();

    _handler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 경험한 맛집 리스트'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(InsertPlace())!.then((value) {
                reloadData();
              });
            },
            icon: Icon(Icons.add, size: 24),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _handler.queryPlace(),
        builder: (context, snapshot) {
          return snapshot.hasData && snapshot.data!.isNotEmpty
              ? ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Slidable(
                        startActionPane: ActionPane(
                          motion: BehindMotion(),
                          children: [
                            SlidableAction(
                              backgroundColor: Colors.blue,
                              icon: Icons.edit,
                              label: '수정',
                              onPressed: (context) {
                                Get.to(
                                  UpdatePlace(),
                                  arguments: snapshot.data![index],
                                )!.then((value) {
                                  reloadData();
                                });
                              },
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: BehindMotion(),
                          children: [
                            SlidableAction(
                              backgroundColor: Colors.blue,
                              icon: Icons.edit,
                              label: '삭제',
                              onPressed: (context) async {
                                await _handler.deletePlace(
                                  snapshot.data![index],
                                );
                              },
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(ShowPlace(), arguments: snapshot.data![index]);
                          },
                          child: Card(
                            color: Colors.deepPurpleAccent,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    20,
                                    0,
                                  ),
                                  child: Image.memory(
                                    snapshot.data![index].placeImage,
                                    width: 100,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '명칭: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(snapshot.data![index].placeName),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '전화번호: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(snapshot.data![index].placePhone),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(child: Text('Not enough data'));
        },
      ),
    );
  } // build

  // === Functions ===

  void reloadData() {
    _handler.queryPlace();
    setState(() {});
  }
}
