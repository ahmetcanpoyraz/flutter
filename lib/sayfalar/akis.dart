// @dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp2/modeller/gonderi.dart';
import 'package:socialapp2/modeller/kullanici.dart';
import 'package:socialapp2/servisler/firestoreservisi.dart';
import 'package:socialapp2/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp2/widgetler/gonderikarti.dart';
import 'package:socialapp2/widgetler/silinmeyenFutureBuilder.dart';

class Akis extends StatefulWidget {
  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];

  _akisGonderileriniGetir() async {
    String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;

    List<Gonderi> gonderiler = await FirestoreServisi().akisGonderileriniGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _akisGonderileriniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gezenti"),
        centerTitle: true,
      ),
      body: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _gonderiler.length,
          itemBuilder: (context, index){

            Gonderi gonderi = _gonderiler[index];

            return FutureBuilder(
                future: FirestoreServisi().kullaniciGetir(gonderi.yayinlayanId),
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return SizedBox();
                  }

                  Kullanici gonderiSahibi = snapshot.data;

                  return GonderiKarti(gonderi: gonderi, yayinlayan: gonderiSahibi,);
                }
            );
          }
      ),
    );
  }
}