import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  TextEditingController dis=TextEditingController();
    List<Map<String, dynamic>> fetchdistrict = [];

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void>insert()async
  {
    try {
      await supabase.from("tbl_district").insert({'district_name':dis.text});
      fetchdata();
      dis.clear();
      print("inserted");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Data inserted successfully")));
      
    } catch (e) {
      print("Error $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("insert Failed:$e")));
      
    }
  }
   Future<void> fetchdata() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        fetchdistrict = response;
      });
    } catch (e) {}
  }
  Future<void>delete(int id )async{
  try {
    await supabase.from('tbl_district').delete().eq('id', id);
    fetchdata();
    dis.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted"),));
    
  } catch (e) {
    print("Error Deleting $e");
    
  }
}
 @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 80
      ),
      children: [
        Form(child: Center(
          child: Row(
            children: [
              // Text("district"),
              Expanded(
                child: TextFormField(
                  controller: dis,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    label: Text("district"),
                    hintText: 'enter the district',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                insert();
              }, child: Text("submit"))
            ],
          ),
        ),
        
        ),
        SizedBox(height: 20,),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          color: Colors.white54,
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          child: ListView.separated(
            
            separatorBuilder: (context, index) {
              return Divider();
            },
              shrinkWrap: true,
                itemCount: fetchdistrict.length,
                itemBuilder: (context, index) {
                final _district= fetchdistrict[index];
                return ListTile(
                  leading:Text(
                     _district['district_name'],),
                      trailing: IconButton(onPressed: (){
                    delete(_district['id']);
                  }, 
                  icon: Icon(Icons.delete_forever_outlined)),

                  
                );
              },),
              
        )
      ],
    );
  }
}