import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChildDetailPage extends StatefulWidget {
  final String id;
  final String isim;
  final int yas;
  final String konum;
  final int rate;
  final String iban;
  final String? tip;

  ChildDetailPage({
    required this.id,
    required this.isim,
    required this.yas,
    required this.konum,
    required this.rate,
    required this.iban,
    this.tip,
  });

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  Future<void> kopyalaMetni(String metin) async {
    Clipboard.setData(ClipboardData(text: metin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Metin kopyalandı: $metin'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E7),
      appBar: AppBar(
        title: Text(
          widget.isim,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${widget.isim}\'in Fotoğrafları',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder(
                            future: FirebaseStorage.instance.ref(widget.id).listAll(),
                            builder: (BuildContext context, AsyncSnapshot<ListResult> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(child: Icon(Icons.error));
                              }
                              return Row(
                                children: snapshot.data!.items.map((ref) {
                                  return FutureBuilder(
                                    future: ref.getDownloadURL(),
                                    builder: (BuildContext context, AsyncSnapshot<String> urlSnapshot) {
                                      if (urlSnapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      if (urlSnapshot.hasError) {
                                        return const Icon(Icons.error);
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 55,
                                          backgroundImage: NetworkImage(urlSnapshot.data!),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7D3A4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF7D3A4), width: 4),
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hakkında',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Merhaba ben ${widget.isim}, henüz ${widget.yas} aylığım. ${widget.konum}\'da yaşıyorum. Ben SMA Tip ${widget.tip} ölümcül kas hastasıyım. "
                          "Yardımlarınız sayesinde hayata tutunabileceğim. Tedavime %${100 - widget.rate} kaldı. Yardımlarınız için teşekkür ederim.",
                          style: const TextStyle(fontSize: 20),
                        ),const SizedBox(height: 15)
                        ,
                        GestureDetector(
                          onTap: () {
                            kopyalaMetni(widget.iban);
                          },
                          child: Text(
                            'IBAN: ${widget.iban}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                          ),
                        ),
                        const SizedBox(height: 15)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xffFFA64D),
        child: Column(
          children: [
            Text(
              'Tedavi Tamamlanma Oranı: %${widget.rate}',
              style: const TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              child: LinearProgressIndicator(
                minHeight: 10,
                color: const Color(0xff0f9614),
                value: widget.rate / 100,
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
