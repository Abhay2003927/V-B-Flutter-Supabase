import 'package:admin/main.dart';
import 'package:flutter/material.dart';
 
class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final formkey =GlobalKey<FormState>();
  TextEditingController cat=TextEditingController();
  List<Map<String,dynamic>> fetchdcategory =[];

   @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void>insert()async
  {
    try {
      await supabase.from("tbl_category").insert({'category_name':cat.text});
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
      final response = await supabase.from("tbl_category").select();
      setState(() {
        fetchdcategory = response;
      });
    } catch (e) {}
  }
Future<void>delete(int id )async{
  try {
    await supabase.from('tbl_category').delete().eq('id', id);
    fetchdata();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted"),));
    
  } catch (e) {
    print("Error Deleting $e");
    
  }
}
 int editId = 0; 
 
  Future<void> update() async { 
    try { 
      await supabase.from("tbl_diettype").update({ 
        "diettype_name":cat.text 
      }).eq('id', editId); 
      fetchdata(); 
      cat.clear(); 
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
                  controller: cat,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    label: Text("Categoty"),
                    hintText: 'please enter the categoty',
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
                itemCount: fetchdcategory.length,
                itemBuilder: (context, index) {
                final category= fetchdcategory[index];
                 
                return ListTile(

                  leading:Text( 
                    category['category_name'],
                  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          delete(category['id']);
                        }, 
                        icon: Icon(Icons.delete_forever_outlined)),
                    
                    
                        IconButton(onPressed: (){
                          setState(() {
                            cat.text=category['category_name'];
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