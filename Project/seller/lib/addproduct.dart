import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:seller/components/admindropdown.dart';
import 'package:seller/components/admintextfield.dart';
import 'package:seller/main.dart';
import 'package:seller/manageproducts.dart';
import 'package:seller/productdetails.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController productname = TextEditingController();
  TextEditingController productprice = TextEditingController();
  TextEditingController productdescription = TextEditingController();
  TextEditingController productimageurl = TextEditingController();
  TextEditingController productbrand = TextEditingController();
  TextEditingController productcategory = TextEditingController();
  TextEditingController producttype = TextEditingController();
  TextEditingController productmodel = TextEditingController();
  TextEditingController productyear = TextEditingController();
  TextEditingController productengine = TextEditingController();
  TextEditingController producttransmission = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isLoading = false;
  PlatformFile? pickedImage;

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        productimageurl.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload(String uid, String type) async {
    try {
      final bucketName = 'shop'; // Replace with your bucket name
      final filePath = "$uid-$type-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  final List<String> categories = [
    'Electronics',
    'Clothing',
    'Automotive',
    'Home Appliances'
  ];
  final List<String> brands = ['Toyota', 'Ford', 'BMW', 'Tesla'];
  final List<String> models = ['Model S', 'Model X', 'Corolla', 'Mustang'];
  final List<String> types = ['SUV', 'Sedan', 'Truck', 'Coupe'];
  final List<String> engines = ['V6', 'V8', 'Electric', 'Hybrid'];
  final List<String> transmissions = ['Automatic', 'Manual', 'CVT'];
  final List<String> years = ['2022', '2023', '2024', '2025'];

  String? selectedCategory;
  String? selectedBrand;
  String? selectedModel;
  String? selectedType;
  String? selectedEngine;
  String? selectedTransmission;
  String? selectedYear;

  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> brandList = [];
  List<Map<String, dynamic>> modelList = [];
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> engineList = [];
  List<Map<String, dynamic>> transmissionList = [];
  List<Map<String, dynamic>> yearList = [];

  @override
  void initState() {
    super.initState();
    fetchcategory();
    fetchtbrand();
    fetchtmodel();
    fetchttype();
    fetchtengine();
    fetchttransmission();
    fetchtyear();
  }

  Future<void> fetchcategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      print("category: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['category_name'],
        });
      }
      setState(() {
        categoryList = data;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> fetchtbrand() async {
    try {
      final response = await supabase.from('tbl_brand').select();
      print("Brand: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['brand_name'],
        });
      }
      setState(() {
        brandList = data;
      });
    } catch (e) {
      // print("Error fetching district: $e");
    }
  }

  Future<void> fetchtmodel() async {
    try {
      final response = await supabase.from('tbl_model').select();
      print("model: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['model_name'],
        });
      }

      setState(() {
        modelList = data;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> fetchttype() async {
    try {
      final response = await supabase.from('tbl_type').select();
      print("type: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['type_name'],
        });
      }
      setState(() {
        typeList = data;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> fetchtengine() async {
    try {
      final response = await supabase.from('tbl_engine').select();
      print("engine: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['engine_name'],
        });
      }
      setState(() {
        engineList = data;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> fetchttransmission() async {
    try {
      final response = await supabase.from('tbl_transmission').select();
      print("transmission: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['transmission_name'],
        });
      }

      setState(() {
        transmissionList = data;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> fetchtyear() async {
    try {
      final response = await supabase.from('tbl_year').select();
      print("year: $response");
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < response.length; i++) {
        data.add({
          'id': response[i]['id'],
          'name': response[i]['year_name'],
        });
      }
      setState(() {
        yearList = data;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> insert(String uid) async {
    try {
      String? photoUrl = await photoUpload(uid, 'photo');

      await supabase.from('tbl_product').insert({
        'id': uid,
        'product_name': productname.text,
        'product_details': productdescription.text,
        'product_price': productprice.text,
        'category_id': selectedCategory,
        'brand_id': selectedBrand,
        'model_id': selectedModel,
        'type_id': selectedType,
        'year_id': selectedYear,
        'engine_id': selectedEngine,
        'product_photo': photoUrl,
      });

      print("Inserted ");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Product Added Successfully")));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Productdetails(),
          ));
    } catch (e) {
      print("Error $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error founder $e')));
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 2, offset: Offset(0, 5)),
              ],
            ),
            child: Form(
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Add New Product',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(label: 'Product Name', controller: productname),
                  CustomTextField(label: 'Product Price', controller: productprice),
                  CustomTextField(label: 'Product Description', controller: productdescription, maxLines: 3),
                  CustomTextField(label: 'Product Image', controller: productimageurl, onTap: handleImagePick, readOnly: true),

                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      CustomDropdown(label: 'Brand', items: brandList, selectedItem: selectedBrand, onChanged: (value) => setState(() => selectedBrand = value)),
                      CustomDropdown(label: 'Category', items: categoryList, selectedItem: selectedCategory, onChanged: (value) => setState(() => selectedCategory = value)),
                      CustomDropdown(label: 'Type', items: typeList, selectedItem: selectedType, onChanged: (value) => setState(() => selectedType = value)),
                      CustomDropdown(label: 'Model', items: modelList, selectedItem: selectedModel, onChanged: (value) => setState(() => selectedModel = value)),
                      CustomDropdown(label: 'Year', items: yearList, selectedItem: selectedYear, onChanged: (value) => setState(() => selectedYear = value)),
                      CustomDropdown(label: 'Engine', items: engineList, selectedItem: selectedEngine, onChanged: (value) => setState(() => selectedEngine = value)),
                      CustomDropdown(label: 'Transmission', items: transmissionList, selectedItem: selectedTransmission, onChanged: (value) => setState(() => selectedTransmission = value)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: (){
                              insert('1');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Add Product', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blueGrey[50],
    );
  }
}

