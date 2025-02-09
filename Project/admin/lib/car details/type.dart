import 'package:admin/main.dart';
import 'package:flutter/material.dart';
 
class TypeScreen  extends StatefulWidget {
  const TypeScreen ({super.key});

  @override
  State<TypeScreen> createState() => _typeState();
}

class  _typeState extends State<TypeScreen> {

  final formkey =GlobalKey<FormState>();

  TextEditingController typeController =TextEditingController();
  List<Map<String,dynamic>> fetchtype=[];

   @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void>insert()async
  {
    try {
      await supabase.from("tbl_type").insert({'type_name':typeController.text});
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
      final response = await supabase.from("tbl_type").select();
      setState(() {
        fetchtype = response;
      });
    } catch (e) {}
  }
Future<void>delete(int id )async{
  try {
    await supabase.from('tbl_type').delete().eq('id', id);
    fetchdata();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted"),));
    
  } catch (e) {
    print("Error Deleting $e");
    
  }
}
 int editId = 0; 
 
  Future<void> update() async { 
    try { 
      await supabase.from("tbl_type").update({ 
        "type_name":typeController.text 
      }).eq('id', editId); 
      fetchdata(); 
      typeController.clear(); 
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
                  controller:typeController ,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    label: Text("Type"),
                    hintText: ' enter the Type ',
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
                itemCount: fetchtype.length,
                itemBuilder: (context, index) {
                final Type = fetchtype [index];
                 
                return ListTile(

                  leading:Text( 
                    Type['type_name'],
                  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          delete(Type['id']);
                        }, 
                        icon: Icon(Icons.delete_forever_outlined)),
                    
                    
                        IconButton(onPressed: (){
                          setState(() {
                            typeController.text=Type['type_name'];
                            editId=Type['id'];
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