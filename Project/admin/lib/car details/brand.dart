import 'package:admin/main.dart';
import 'package:flutter/material.dart';
 
class brand extends StatefulWidget {
  const brand({super.key});

  @override
  State<brand> createState() => _brandState();
}

class _brandState extends State<brand> {

  final formkey =GlobalKey<FormState>();

  TextEditingController brand=TextEditingController();
  List<Map<String,dynamic>> fetchdbrand =[];

   @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void>insert()async
  {
    try {
      await supabase.from("tbl_brand").insert({'brand_name':brand.text});
      fetchdata();
      print("inserted");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Data inserted successfully")));
      
    } catch (e) {
      print("Error $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("insert Failed:$e")));
      
    }
  }
   Future<void> fetchdata() async {
    try {
      final response = await supabase.from("tbl_brand").select();
      setState(() {
        fetchdbrand = response;
      });
    } catch (e) {}
  }
Future<void>delete(int id )async{
  try {
    await supabase.from('tbl_brand').delete().eq('id', id);
    fetchdata();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted"),));
    
  } catch (e) {
    print("Error Deleting $e");
    
  }
}
 int editId = 0; 
 
  Future<void> update() async { 
    try { 
      await supabase.from("tbl_brand").update({ 
        "brand_name":brand.text 
      }).eq('id', editId); 
      fetchdata(); 
      brand.clear(); 
      setState(() { 
        editId=0; 
      }); 
    } catch (e) { 
       
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
        Form(
          key: formkey,
          child: Center(
          child: Row(
            children: [
              
              Expanded(
                child: TextFormField(
                  controller: brand,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    label: Text("Brand"),
                    hintText: 'please enter the Brand',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                if(editId==0){
                insert();
                }
                else{
                  update();
                }
                
              }, child: Text("submit"))
            ],
          ),
        ),
        
        ),

        SizedBox(height: 20,),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          child: ListView.separated(
            
            separatorBuilder: (context, index) {
              return Divider();
            },
              shrinkWrap: true,
                itemCount: fetchdbrand.length,
                itemBuilder: (context, index) {
                final _brand= fetchdbrand[index];
                 
                return ListTile(

                  leading:Text( 
                    _brand['brand_name'],
                  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          delete(_brand['id']);
                        }, 
                        icon: Icon(Icons.delete_forever_outlined)),
                    
                    
                        IconButton(onPressed: (){
                          setState(() {
                            brand.text=_brand['brand_name'];
                            editId=_brand['id'];
                          });
                        }, icon:Icon(Icons.edit))
                      ],
                    ),
                  ),
                  
                  
                );
              },),
        )
      ]
        
               );
               
        
  }
}