import 'package:admin/car%20details/brand.dart';
import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Model extends StatefulWidget {
  const Model({super.key});

  @override
  State<Model> createState() => _modelState();
}

class _modelState extends State<Model> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  List<Map<String, dynamic>> brandList = [];
  List<Map<String, dynamic>> modelList = [];
  List<Map<String,dynamic>>typeList=[];
  bool isLoading = false;
  @override
  void initState() {
    
    super.initState();
    fetchDist();
    fetchdata();
  }

  Future<void> fetchDist() async {
    try {
      print("Model");
      final response = await supabase.from('tbl_model').select();
      print(response);
      setState(() {
        brandList = response;
      });
    } catch (e) {
      print("Error fetching model: $e");
    }
  }

  String? selectedDistrict;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_model").insert({
        'model_name': _modelController.text,
        'brand_id': selectedbrand
      });

      print("Data inserted");
      _modelController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Inserted successufully')));
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error found in insert $e')));
    }
  }

  Future<void> fetchdata() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase.from('tbl_model').select();

      setState(() {
        isLoading = false;
        modelList = response;
      });
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_model").delete().eq('id', id);

      fetchdata();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(' Deleted')));
    } catch (e) {
      print('error $e');
    }
  }

  int edit = 0;
  Future<void> update() async {
    try {
      await supabase
          .from('tbl_model')
          .update({"model_name": _modelController.text}).eq("id", edit);
      fetchdata();
      _modelController.clear();
      setState(() {
        edit = 0;
      });
    } catch (e) {
      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 40,
          ),
          child: Form(
              key: formkey,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Model'),
                          value: selectedDistrict,
                          items: brandList.map((district) {
                            return DropdownMenuItem(
                                value: brand['id'].toString(),
                                child: Text(brand['brand_name']));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDistrict = value!;
                            });
                          }),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        hintText: 'Model',
                        label: Text('Model'),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    )),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (edit == 0) {
                            insert();
                          } else {
                            update();
                          }
                        },
                        child: Text('Submit'))
                  ],
                ),
              )),
        ),
        
        SizedBox(
          height: 40,
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              ))
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: Container(
                  decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          color: Colors.white54,
          ),
                     
                    padding: EdgeInsets.all(20),
                    child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        shrinkWrap: true,
                        itemCount: placeList.length,
                        itemBuilder: (context, index) {
                          final _place = placeList[index];
                          return ListTile(
                              leading: Text(
                                style: TextStyle(fontSize: 18),
                                _place['place_name'],
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          delete(_place['id']);
                                        },
                                        icon: Icon(Icons.delete_outline)),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _modelController.text =
                                                _modelController['model_name'];
                                            edit = _place['id'];
                                          });
                                        },
                                        icon: Icon(Icons.edit))
                                  ],
                                ),
                              ));
                        })),
              )
      ],
    );
  }
}