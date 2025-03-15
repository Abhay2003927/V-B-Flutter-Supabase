import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  List<Map<String, dynamic>> brandList = [];
  List<Map<String, dynamic>> modelList = [];
  List<Map<String,dynamic>>  typeList = [];

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchBrand();
    fetchdata();
    fetchtype();
  }

  Future<void> fetchBrand() async {
    try {
      final response = await supabase.from('tbl_brand').select();
      print("Model: $response");
      setState(() {
        brandList = response;
      });
    } catch (e) {
      print("Error fetching model: $e");
    }
  }

   Future<void> fetchtype() async {
    try {
      final response = await supabase.from('tbl_type').select();
      print("Model: $response");
      setState(() {
        typeList = response;
      });
    } catch (e) {
      print("Error fetching model: $e");
    }
  }

  String? selectedbrand;
  String? selectedtype;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_model").insert({
        'model_name': _modelController.text,
        'brand_id': selectedbrand,
        'type_id': selectedtype,
      });

      print("Data inserted");
      fetchBrand();
      fetchdata();
      fetchtype();
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
                              hintText: 'Brand'),
                          value: selectedbrand,
                          items: brandList.map((brand) {
                            return DropdownMenuItem(
                                value: brand['id'].toString(),
                                child: Text(brand['brand_name'] ?? ""));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedbrand = value!;
                            });
                          }),
                        
                    ),
                    SizedBox(
                      width: 10,
                    ),Expanded(
                      
                      child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Type'),
                          value: selectedtype,
                          items: typeList.map((Type) {
                            return DropdownMenuItem(
                                value:Type ['id'].toString(),
                                child: Text(Type['type_name'] ?? ""));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedtype = value!;
                            });
                          }), ),
                    
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
                        itemCount: modelList.length,
                        itemBuilder: (context, index) {
                          final _model = modelList[index];
                          return ListTile(
                              leading: Text(
                                style: TextStyle(fontSize: 18),
                                _model['model_name'] ?? "",
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          delete(_model['id']);
                                        },
                                        icon: Icon(Icons.delete_outline)),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _modelController.text =
                                                _model['model_name'];
                                            edit = _model['id'];
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
