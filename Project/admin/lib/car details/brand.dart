import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Brand extends StatefulWidget {
  const Brand({super.key});

  @override
  State<Brand> createState() => _BrandState();
}

class _BrandState extends State<Brand> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  List<Map<String, dynamic>> _fetchedBrands = [];
  int _editId = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _insertBrand() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.from("tbl_brand").insert({'brand_name': _brandController.text});
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data inserted successfully")),
        );
        _brandController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Insert Failed: $e")),
        );
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from("tbl_brand").select();
      setState(() {
        _fetchedBrands = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  Future<void> _deleteBrand(int id) async {
    try {
      await supabase.from('tbl_brand').delete().eq('id', id);
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    }
  }

  Future<void> _updateBrand() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.from("tbl_brand").update({
          "brand_name": _brandController.text,
        }).eq('id', _editId);
        _fetchData();
        _brandController.clear();
        setState(() {
          _editId = 0;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 80),
      children: [
        Form(
          key: _formKey,
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      label: const Text("Brand"),
                      hintText: 'Please enter the brand',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a brand name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_editId == 0) {
                      _insertBrand();
                    } else {
                      _updateBrand();
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            shrinkWrap: true,
            itemCount: _fetchedBrands.length,
            itemBuilder: (context, index) {
              final brand = _fetchedBrands[index];
              return ListTile(
                leading: Text(
                  brand['brand_name'],
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
                trailing: SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _deleteBrand(brand['id']),
                        icon: const Icon(Icons.delete_forever_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _brandController.text = brand['brand_name'];
                            _editId = brand['id'];
                          });
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}