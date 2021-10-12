// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp2/sayfalar/akis.dart';
import 'package:socialapp2/sayfalar/ara.dart';
import 'package:socialapp2/sayfalar/duyurular.dart';
import 'package:socialapp2/sayfalar/profil.dart';
import 'package:socialapp2/sayfalar/yukle.dart';
import 'package:socialapp2/servisler/yetkilendirmeservisi.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({Key key}) : super(key: key);

  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
   int _aktifsayfaNo = 0;
   PageController sayfaKumandasi;
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sayfaKumandasi=PageController();
  }
  @override
  void dispose() {
    sayfaKumandasi.dispose();
     // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
     String aktifKullaniciId= Provider.of<YetkilendirmeServisi>(context,listen:false).aktifKullaniciId;
    return Scaffold(
      body:PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (acilanSayfaNo){
        setState(() {
        _aktifsayfaNo=acilanSayfaNo;
        });
        },
        controller:sayfaKumandasi ,
        children:<Widget> [
          Akis(),
          Ara(),
          Yukle(),
          Duyurular(),
          Profil(profilSahibiId: aktifKullaniciId,)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifsayfaNo,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
           BottomNavigationBarItem(icon: Icon(Icons.home),title: Text("Anasayfa")),
           BottomNavigationBarItem(icon: Icon(Icons.explore),title: Text("Keşfet")),
           BottomNavigationBarItem(icon: Icon(Icons.file_upload),title: Text("Yükle")),
           BottomNavigationBarItem(icon: Icon(Icons.notifications),title: Text("Bildirimler")),
           BottomNavigationBarItem(icon: Icon(Icons.person),title: Text("Profil")),

        ],
        onTap: (secilenSayfaNo){
          setState(() {

            sayfaKumandasi.jumpToPage(secilenSayfaNo);
          });
        },
       ),
    );
  }
}

