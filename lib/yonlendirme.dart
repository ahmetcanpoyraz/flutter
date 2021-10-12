// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp2/sayfalar/anasayfa.dart';
import 'package:socialapp2/sayfalar/girissayfasi.dart';
import 'package:socialapp2/servisler/yetkilendirmeservisi.dart';

import 'modeller/kullanici.dart';

class Yonlendirme extends StatelessWidget {
 // const Yonlendirme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final _yetkilendirmeServisi=Provider.of<YetkilendirmeServisi>(context,listen: false);

    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
        builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return Scaffold(body:Center(child: CircularProgressIndicator()) ,);
        }
        if(snapshot.hasData){
         Kullanici aktifKullanici=snapshot.data;
         _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici.id;

          return Anasayfa();
        }
        else{
         return GirisSayfasi();
        }
        });
  }
}
