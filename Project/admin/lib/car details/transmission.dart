import 'package:admin/main.dart';
import 'package:flutter/material.dart';
 
class transmission  extends StatefulWidget {
  const transmission ({super.key});

  @override
  State<transmission > createState() => _transmissionState();
}

class _transmissionState extends State<transmission> {

  final formkey =GlobalKey<FormState>();

  TextEditingController transmissionController =TextEditingController();
  List<Map<String,dynamic>> fetchtransmission=[];

   @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void>insert()async
  {
    try {
      await supabase.from("tbl_transmission").insert({'transmission_name':transmissionController.text});
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
      final response = await supabase.from("tbl_transmission").select();
      setState(() {
        fetchtransmission = response;
      });
    } catch (e) {}
  }
Future<void>delete(int id )async{
  try {
    await supabase.from('tbl_transmission').delete().eq('id', id);
    fetchdata();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted"),));
    
  } catch (e) {
    print("Error Deleting $e");
    
  }
}
 int editId = 0; 
 
  Future<void> update() async { 
    try { 
      await supabase.from("tbl_transmission").update({ 
        "transmission_name":transmissionController.text 
      }).eq('id', editId); 
      fetchdata(); 
      transmissionController.clear(); 
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
                  controller:transmissionController ,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    label: Text("Transmission "),
                    hintText: ' enter the Transmission ',
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
                itemCount: fetchtransmission.length,
                itemBuilder: (context, index) {
                final transmission = fetchtransmission [index];
                 
                return ListTile(

                  leading:Text( 
                    transmission['transmission_name'],
                  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          delete(transmission['id']);
                        }, 
                        icon: Icon(Icons.delete_forever_outlined)),
                    
                    
                        IconButton(onPressed: (){
                          setState(() {
                            transmissionController.text=transmission['transmission_name'];
                            editId=transmission['id'];
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