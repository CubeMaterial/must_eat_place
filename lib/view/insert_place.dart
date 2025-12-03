import 'dart:io';
import 'dart:typed_data';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place/model/place.dart';
import 'package:must_eat_place/vm/database_handler.dart';
import 'package:geolocator/geolocator.dart';

class InsertPlace extends StatefulWidget {
  const InsertPlace({super.key});

  @override
  State<InsertPlace> createState() => _InsertPlaceState();
}

class _InsertPlaceState extends State<InsertPlace> {
  // === Property ===
  late DatabaseHandler _handler;
  late TextEditingController _latTextEditingController;
  late TextEditingController _lngTextEditingController;
  late TextEditingController _nameTextEditingController;
  late TextEditingController _phoneTextEditingController;
  late TextEditingController _addressTextEditingController;
  late TextEditingController _estimateTextEditingController;

  late Position _currentPosition;
  late double _latData;
  late double _lngData;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _handler = DatabaseHandler();
    _latTextEditingController = TextEditingController();
    _lngTextEditingController = TextEditingController();
    _nameTextEditingController = TextEditingController();
    _phoneTextEditingController = TextEditingController();
    _addressTextEditingController = TextEditingController();
    _estimateTextEditingController = TextEditingController();
    _latTextEditingController = TextEditingController();
    _latData = 0;
    _lngData = 0;
    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('맛집 추가'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    getImageFromGallery(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Theme.of(context).colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadiusGeometry.circular(10)),
                        ),  
                  child: Text('이미지 가져오기'),
                ),
          
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: MediaQuery.widthOf(context),
                    height: 200,
                    color: Colors.grey,
                    child: _imageFile != null
                        ? Image.file(File(_imageFile!.path))
                        : Center(
                            child: Text(
                              '이미지가 선택되지 않았습니다',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _latTextEditingController,
                          decoration: InputDecoration(labelText: '위도'),
                          readOnly: true
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _lngTextEditingController,
                          decoration: InputDecoration(labelText: '경도'),
                          readOnly: true
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: _nameTextEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '이름'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: _phoneTextEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '전화'),
                      keyboardType: TextInputType.phone,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.widthOf(context) * 0.7,
                        child: TextField(
                          controller: _addressTextEditingController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '주소'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: ElevatedButton(onPressed: () {
                          getCurrentLocation();
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Theme.of(context).colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadiusGeometry.circular(10)),
                        ),
                        child: Text('추출')),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: _estimateTextEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '평가'),
                      maxLength: 50,
                      maxLines: 3,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    checkInsert();
                  },
                  style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Theme.of(context).colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadiusGeometry.circular(10)),
                        ),
                  child: Text('입력'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // build

  // === Functions ===

  void checkInsert()
  {
    if(_nameTextEditingController.text.trim().isEmpty ||
    _phoneTextEditingController.text.trim().isEmpty ||
    _estimateTextEditingController.text.trim().isEmpty || 
    _addressTextEditingController.text.trim().isEmpty ||
    _imageFile == null
    )
    {
      showErrorSnackBar('전부 다 입력해주세요');
    }
    else
    {
      if(_nameTextEditingController.text.trim().length > 30)
      {
        showErrorSnackBar('이름이 너무 길어요');
      }
      else if(_phoneTextEditingController.text.trim().length > 14)
      {
        showErrorSnackBar('전화 번호가 너무 길어요');
      }
      else
      {
        insertAction();
      }

    }
  }

  Future insertAction() async
  { 
    File imageFile1 = File(_imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();

    Place place = Place(
      placeName: _nameTextEditingController.text.trim(), 
      placePhone: _phoneTextEditingController.text.trim(), 
      placeAddress: _addressTextEditingController.text.trim(),
      placeLat: _latData, 
      placeLng: _lngData, 
      placeImage: getImage, 
      placeEstimate: _estimateTextEditingController.text.trim(), 
      initDate: DateTime.now().toString(), 
      updateDate: DateTime.now().toString());
   

    int check = await _handler.insertPlace(place);
    if (check == 0) {
      showErrorSnackBar('입력이 실패 되었다.');
    } else {
      showDialog();
    }
  }  

  void showErrorSnackBar(String msg) {
    Get.showSnackbar(
      GetSnackBar(
        title: '경고',
        backgroundColor: Theme.of(context).colorScheme.error,
        messageText: Text(
          msg,
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
        duration: Duration(seconds: 3),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        margin: EdgeInsets.all(8),
        borderRadius: 10,
      ),
    );
  }

  void showDialog() {
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료 되었다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Theme.of(context).colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadiusGeometry.circular(10)),
                        ),
          child: Text('확인'),
        ),
      ],
    );
  }

  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: imageSource);
    if (pickedFile == null) {
      _imageFile = null;
    } else {
      _imageFile = XFile(pickedFile.path);
    }
    setState(() {});
  }

  Future getCurrentLocation() async {
    // print('$_latData, $_longData, $_canRun');
    if(_addressTextEditingController.text.trim().isEmpty)
    {
      showErrorSnackBar('주소를 입력하세요');
    }
    else
    {
      List<Location> locations = await locationFromAddress(_addressTextEditingController.text.trim());

      _latData = locations.first.latitude;
      _lngData = locations.first.longitude;
      _latTextEditingController.text = _latData.toString().substring(0,9);
      _lngTextEditingController.text = _lngData.toString().substring(0,9);

      // print('$_latData, $_lngData, ${locations.first}');
      setState(() {});
    }
  }

  void checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 퍼미션 거부할 경우 다시 물어봄
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // 영원히 거부
      return;
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // 퍼미션 허용
      // getCurrentLocation(); 서울 서초구 서초대로50길 82
    }
  }
}// class