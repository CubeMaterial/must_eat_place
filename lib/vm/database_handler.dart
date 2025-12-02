import 'package:must_eat_place/model/place.dart';
import 'package:must_eat_place/view/insert_place.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {

  // connection
  Future<Database> initialzeDB() async
  {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'place.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''
          create table musteatplace
          (seq integer primary key autoincrement,
          placeName text,
          placePhone text,
          placeLat real,
          placeLng real,
          placeImage blob,
          placeEstimate text,
          initDate date,
          updateDate date
          )
          '''  
        );
      },
      version: 1
    );
  }  
  // insert
  Future<int> insertPlace(Place place) async
  {
    int result = 0;

    Database db = await initialzeDB();
    result = await db.rawInsert(
      '''
      insert into musteatplace
      (placeName,placePhone, placeLat, placeLng,placeImage, placeEstimate, initDate, updateDate)
      values
      (?,?,?,?,?,?,date('now'),date('now'))
      ''',
      [
        place.placeName,
        place.placePhone,
        place.placeLat,
        place.placeLng,
        place.placeImage,
        place.placeEstimate,
      ]
    );
    return result;
  }

  // update
  Future<int> updatePlace(Place place) async
  {
    int result = 0;

    Database db = await initialzeDB();
    result = await db.rawUpdate(
      '''
      update musteatplace
      set placeName = ?, placePhone = ?, placeLat = ?, 
      placeLng = ?, placeImage = ?, placeEstimate = ?, 
      initDate = ?, updateDate = date('now')
      where seq = ? 
      ''',
      [
        place.placeName,
        place.placePhone,
        place.placeLat,
        place.placeLng,
        place.placeImage,
        place.placeEstimate,
        place.initDate,
        place.seq
      ]
    );
    return result;
  }

  // query
  Future<List<Place>> queryPlace() async
  {

    Database db = await initialzeDB();

    final List<Map<String, Object?>> results = await db.rawQuery(
       'select * from musteatplace'
    );

    return results.map((e) => Place.fromMap(e)).toList();
  }
  // delete


  Future deletePlace(Place place) async
  {
    Database db = await initialzeDB();
    db.rawDelete('delete from musteatplace where seq = ?',[place.seq]);
  }
}
