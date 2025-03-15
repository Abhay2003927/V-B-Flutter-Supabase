import 'package:admin/main.dart';
import 'package:flutter/material.dart';
 
class Engine extends StatefulWidget {
  const Engine({super.key});

  @override
  State<Engine> createState() => _EngineState();
}

class _EngineState extends State<Engine> {

  final formkey =GlobalKey<FormState>();

  TextEditingController Engine=TextEditingController();
  List<Map<String,dynamic>> fetchengine =[];

   @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void>insert()async
  {
    try {
      await supabase.from("tbl_engine").insert({'engine_name':Engine.text});
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
      final response = await supabase.from("tbl_engine").select();
      setState(() {
        fetchengine = response;
      });
    } catch (e) {}
  }
Future<void>delete(int id )async{
  try {
    await supabase.from('tbl_engine').delete().eq('id', id);
    fetchdata();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted"),));
    
  } catch (e) {
    print("Error Deleting $e");
    
  }
}
 int editId = 0; 
 
  Future<void> update() async { 
    try { 
      await supabase.from("tbl_engine").update({ 
        "engine_name":Engine.text 
      }).eq('id', editId); 
      fetchdata(); 
      Engine.clear(); 
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
                  controller: Engine,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    label: Text("Engine"),
                    hintText: 'please enter the Engine',
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
                itemCount: fetchengine.length,
                itemBuilder: (context, index) {
                final _engine= fetchengine[index];
                 
                return ListTile(

                  leading:Text( 
                    _engine['engine_name'],
                  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          delete(_engine['id']);
                        }, 
                        icon: Icon(Icons.delete_forever_outlined)),
                    
                    
                        IconButton(onPressed: (){
                          setState(() {
                            Engine.text=_engine['engine_name'];
                            editId=_engine['id'];
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