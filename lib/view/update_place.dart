import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place/model/place.dart';
import 'package:must_eat_place/vm/database_handler.dart';

class UpdatePlace extends StatefulWidget {
  const UpdatePlace({super.key});

  @override
  State<UpdatePlace> createState() => _UpdatePlaceState();
}

class _UpdatePlaceState extends State<UpdatePlace> {
  // === Property ===
  late DatabaseHandler _handler; // DatabaseHandler 인스턴스
  late TextEditingController _latTextEditingController; // 위도를 표현하는 TextEditingController
  late TextEditingController _lngTextEditingController;  // 경도를 표현하는 TextEditingController
  late TextEditingController _nameTextEditingController; // 이름 TextEditingController
  late TextEditingController _phoneTextEditingController; // 전화 TextEditingController
  late TextEditingController _addressTextEditingController; // 주소 TextEditingController
  late TextEditingController _estimateTextEditingController; // 평가 TextEditingController

  late double _latData; // 위도 데이터
  late double _lngData;  // 경도 데이터
  late  int _firstDisp; // 첫 화면 표시 여부

  final ImagePicker _imagePicker = ImagePicker(); // 이미지 픽커 인스턴스
  final Place _place = Get.arguments ?? '__'; // 전달된 Place 객체
  XFile? _imageFile; // 선택된 이미지 파일

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
    _latData = _place.placeLat;
    _lngData = _place.placeLng;
    _nameTextEditingController.text = _place.placeName;
    _phoneTextEditingController.text = _place.placePhone;
    _estimateTextEditingController.text = _place.placeEstimate;
    _addressTextEditingController.text = _place.placeAddress;
    _latTextEditingController.text = _latData.toString();
    _lngTextEditingController.text = _lngData.toString();
    
    _firstDisp = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('맛집 수정'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
              _firstDisp == 0 ?
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                   width: MediaQuery.widthOf(context),
                  height: 200,
                  color: Colors.grey,
                  child: Image.memory(_place.placeImage)
                ),
              )
              :Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: MediaQuery.widthOf(context),
                  height: 200,
                  color: Colors.grey,
                  child: _imageFile != null
                      ? Image.file(File(_imageFile!.path) )
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
                    // maxLength: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: TextField(
                  controller: _phoneTextEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '전화'),
                    // maxLength: 14,
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
                  _firstDisp == 0? checkUpdateExceptImage():checkUpdate();
                },
                style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Theme.of(context).colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadiusGeometry.circular(10)),
                        ),
                child: Text('수정'),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // === Functions ===

  void checkUpdateExceptImage()
  {
    if(_nameTextEditingController.text.trim().isEmpty ||
    _phoneTextEditingController.text.trim().isEmpty ||
    _estimateTextEditingController.text.trim().isEmpty ||
    _addressTextEditingController.text.trim().isEmpty
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
        updateActionExceptImage();
      }
    }
  }
  void checkUpdate()
  {
    if(_nameTextEditingController.text.trim().isEmpty ||
    _phoneTextEditingController.text.trim().isEmpty ||
    _estimateTextEditingController.text.trim().isEmpty || 
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
        updateAction();
      }
    }
  }

  Future updateActionExceptImage() async
  { 
    Place place = Place(
      seq: _place.seq,
      placeName: _nameTextEditingController.text.trim(), 
      placePhone: _phoneTextEditingController.text.trim(), 
      placeAddress: _addressTextEditingController.text.trim(), 
      placeLat: _latData, 
      placeLng: _lngData, 
      placeImage: _place.placeImage, 
      placeEstimate: _estimateTextEditingController.text.trim(), 
      initDate: DateTime.now().toString(), 
      updateDate: DateTime.now().toString());
   
      // print('${place.seq}, ${place.placeName}, ${place.placePhone}, ${place.placeAddress}, ${place.placeLat}, ${place.placeLng}, ${place.placeEstimate}, ${place.initDate}, ${place.updateDate}');

    int check = await _handler.updatePlace(place);
    if (check == 0) {
      showErrorSnackBar('입력이 실패 되었다.');
    } else {
      showDialog();
    }
  }  

  Future updateAction() async
  { 
    File imageFile1 = File(_imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();

    Place place = Place(
      seq: _place.seq,
      placeName: _nameTextEditingController.text.trim(), 
      placePhone: _phoneTextEditingController.text.trim(), 
      placeAddress: _addressTextEditingController.text.trim(),
      placeLat: _latData, 
      placeLng: _lngData, 
      placeImage: getImage, 
      placeEstimate: _estimateTextEditingController.text.trim(), 
      initDate: DateTime.now().toString(), 
      updateDate: DateTime.now().toString() );
   
      // print('${place.placeName}, ${place.placePhone}, ${place.placeAddress}, ${place.placeLat}, ${place.placeLng}, ${place.placeEstimate}, ${place.initDate}, ${place.updateDate}');

    int check = await _handler.updatePlace(place);
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
          child: Text('확인',),
        ),
      ],
    );
  }

  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: imageSource);
    if (pickedFile == null) {
      _imageFile = null;
    } else {
      _firstDisp += 1;
      print(pickedFile.path);
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
      // print('$_latData, $_lngData, ${locations.first}');
      
      String lat = _latData.toString();
      if(lat.length > 9)
      {
        lat = lat.substring(0,9);
      }

      String lng = _lngData.toString();
      if(lng.length > 9)
      {
        lng = lng.substring(0,9);
      }
      _latTextEditingController.text = lat;
      _lngTextEditingController.text = lng;

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
    }
  }
}// class