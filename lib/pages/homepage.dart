import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'child_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _searchController;
  String _selectedSorting = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> sortByAgeAscending(List<DocumentSnapshot> documents) {
    documents.sort((a, b) => a['yas'].compareTo(b['yas']));
    return documents;
  }

  List<DocumentSnapshot> sortByAgeDescending(List<DocumentSnapshot> documents) {
    documents.sort((a, b) => b['yas'].compareTo(a['yas']));
    return documents;
  }

  List<DocumentSnapshot> sortByCompletionRateAscending(List<DocumentSnapshot> documents) {
    documents.sort((a, b) => a['rate'].compareTo(b['rate']));
    return documents;
  }

  List<DocumentSnapshot> sortByCompletionRateDescending(List<DocumentSnapshot> documents) {
    documents.sort((a, b) => b['rate'].compareTo(a['rate']));
    return documents;
  }

  List<DocumentSnapshot> sortByCityAscending(List<DocumentSnapshot> documents) {
    documents.sort((a, b) => a['konum'].toString().toLowerCase().compareTo(b['konum'].toString().toLowerCase()));
    return documents;
  }

  List<DocumentSnapshot> sortByCityDescending(List<DocumentSnapshot> documents) {
    documents.sort((a, b) => b['konum'].toString().toLowerCase().compareTo(a['konum'].toString().toLowerCase()));
    return documents;
  }

  void _onSortSelected(String value) {
    setState(() {
      _selectedSorting = value;
    });
  }

  List<DocumentSnapshot> applySorting(List<DocumentSnapshot> documents) {
    switch (_selectedSorting) {
      case 'yaşa göre artan':
        return sortByAgeAscending(documents);
      case 'yaşa göre azalan':
        return sortByAgeDescending(documents);
      case 'tamamlanma oranına göre artan':
        return sortByCompletionRateAscending(documents);
      case 'tamamlanma oranına göre azalan':
        return sortByCompletionRateDescending(documents);
      case 'şehir (a-z)':
        return sortByCityAscending(documents);
      case 'şehir (z-a)':
        return sortByCityDescending(documents);
      default:
        return documents;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E7),
      appBar: AppBar(
        title: const Text(
          'SMA Warriors',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, size: 35, color: Color(0xffff7f00)),
            onSelected: _onSortSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'yaşa göre artan',
                child: Text('Yaşa Göre Artan'),
              ),
              const PopupMenuItem<String>(
                value: 'yaşa göre azalan',
                child: Text('Yaşa Göre Azalan'),
              ),
              const PopupMenuItem<String>(
                value: 'tamamlanma oranına göre artan',
                child: Text('Tamamlanma Oranına Göre Artan'),
              ),
              const PopupMenuItem<String>(
                value: 'tamamlanma oranına göre azalan',
                child: Text('Tamamlanma Oranına Göre Azalan'),
              ),
              const PopupMenuItem<String>(
                value: 'şehir (a-z)',
                child: Text('Şehir (A-Z)'),
              ),
              const PopupMenuItem<String>(
                value: 'şehir (z-a)',
                child: Text('Şehir (Z-A)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Çocuk ara...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('children').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> documents = snapshot.data!.docs;
                String searchQuery = _searchController.text.toLowerCase();

                List<DocumentSnapshot> filteredDocuments = applySorting(documents.where((doc) {
                  String name = doc['isim'].toString().toLowerCase();
                  String city = doc['konum'].toString().toLowerCase();
                  return name.contains(searchQuery) || city.contains(searchQuery);
                }).toList());

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = filteredDocuments[index];
                    String id = document.id;
                    String tip = document['tip'];
                    String name = document['isim'];
                    int age = document['yas'];
                    String city = document['konum'];
                    int completionRate = document['rate'];
                    String iban = document['iban'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildDetailPage(
                              tip: tip,
                              id: id,
                              isim: name,
                              yas: age,
                              konum: city,
                              rate: completionRate,
                              iban: iban,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7D3A4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF7D3A4), width: 4),
                          ),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                      future: FirebaseStorage.instance.ref(id).listAll(),
                                      builder: (BuildContext context, AsyncSnapshot<ListResult> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }
                                        if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        }
                                        if (snapshot.data!.items.isEmpty) {
                                          return const Placeholder();
                                        }
                                        return FutureBuilder(
                                          future: snapshot.data!.items[0].getDownloadURL(),
                                          builder: (BuildContext context, AsyncSnapshot<String> urlSnapshot) {
                                            if (urlSnapshot.connectionState == ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            if (urlSnapshot.hasError) {
                                              return const Icon(Icons.error);
                                            }
                                            return Container(
                                              margin: EdgeInsets.all(10),
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(urlSnapshot.data!),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10,),
                                        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                        Text('Yaş: $age Aylık',style: TextStyle(fontSize: 15),),
                                        Text('Şehir: $city',style: TextStyle(fontSize: 15),),
                                        Text('Tedavi Tamamlanma Oranı: %$completionRate',style: TextStyle(fontSize: 15),),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Text('IBAN: $iban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
