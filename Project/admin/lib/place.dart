import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> placeList = [];
  bool isLoading = false;
  @override
  void initState() {
    
    super.initState();
    fetchDist();
    fetchdata();
  }

  Future<void> fetchDist() async {
    try {
      print("District");
      final response = await supabase.from('tbl_district').select();
      print(response);
      setState(() {
        distList = response;
      });
    } catch (e) {
      print("Error fetching district: $e");
    }
  }

  String? selectedDistrict;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_place").insert({
        'place_name': _placeController.text,
        'district_id': selectedDistrict
      });

      print("Data inserted");
      fetchdata();
      _placeController.clear();
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
      final response = await supabase.from('tbl_place').select();

      setState(() {
        isLoading = false;
        placeList = response;
      });
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_place").delete().eq('id', id);

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
          .from('tbl_place')
          .update({"place_name": _placeController.text}).eq("id", edit);
      fetchdata();
      _placeController.clear();
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
                              hintText: 'District'),
                          value: selectedDistrict,
                          items: distList.map((district) {
                            return DropdownMenuItem(
                                value: district['id'].toString(),
                                child: Text(district['district_name']));
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
                      controller: _placeController,
                      decoration: InputDecoration(
                        hintText: 'Place',
                        label: Text('Place'),
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
                                            _placeController.text =
                                                _place['place_name'];
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