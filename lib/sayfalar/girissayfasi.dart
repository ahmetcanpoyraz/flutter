// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp2/modeller/kullanici.dart';
import 'package:socialapp2/sayfalar/hesapolustur.dart';
import 'package:socialapp2/sayfalar/sifremiunuttum.dart';
import 'package:socialapp2/servisler/firestoreservisi.dart';
import 'package:socialapp2/servisler/yetkilendirmeservisi.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key key}) : super(key: key);

  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari=GlobalKey<ScaffoldState>();
  bool yukleniyor=false;
  String email,sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_scaffoldAnahtari,
        body:Stack(children: <Widget>[_sayfaElemanlari(),
          _yuklemeAnimasyonu(),
        ],));
  }

  Widget _yuklemeAnimasyonu(){
    if(yukleniyor){
      return Center(child: CircularProgressIndicator());
    }else{
      return SizedBox(height: 0.0,);
    }
  }

  Widget _sayfaElemanlari(){
    return Form(

      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        children: <Widget>[
          Image(

            width: 220.0,
            height: 220.0,
            image:AssetImage('assets/images/adsiz.png'),
          ),


         /* FlutterLogo(
            size: 90.0,
          )*/
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email adresinizi girin",
              errorStyle: TextStyle(fontSize: 16.0),
              prefixIcon: Icon(Icons.mail),
            ),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return "Email alanı boş bırakılamaz";
              } else if (!girilenDeger.contains("@")) {
                return "Girilen değer mail formatında olmalı";
              }
              return null;
            },
            onSaved: (girilenDeger) => email=girilenDeger,
          ),
          SizedBox(
            height: 30.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Şifrenizi Girin",
              errorStyle: TextStyle(fontSize: 16.0),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return "Şifre alanı boş bırakılamaz";
              } else if (girilenDeger.trim().length < 4) {
                return "şifre 4 karakterden az olamaz";
              }
              return null;
            },
            onSaved: (girilenDeger) => sifre=girilenDeger,
          ),
          SizedBox(
            height: 30.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>HesapOlustur()));
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: FlatButton(
                  onPressed: _girisYap,
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text("veya"),
          ),
          SizedBox(
            height: 15.0,
          ),
          Center(child: InkWell(
            onTap: _googleIleGiris,

            child: Text(
              "Google ile giriş yap",
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
          )),
          SizedBox(
            height: 15.0,
          ),
          Center(
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SifremiUnuttum()));
              },
              child: Text("Şifremi unuttum"),)
          ),
        ],
      ),
    );
  }

  void _girisYap() async{
    final _yetkilendirmeServisi=Provider.of<YetkilendirmeServisi>(context,listen: false);

    if (_formAnahtari.currentState.validate()) {

      _formAnahtari.currentState.save();
      setState(() {
        yukleniyor=true;
      });
      try{
        await _yetkilendirmeServisi.mailileGiris(email, sifre);
      }catch(hata){
        setState(() {
          yukleniyor=false;
        });
      uyariGoster(hataKodu: hata.toString());
      }

    }
  }

  void _googleIleGiris() async{
    var _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context,listen: false);
    setState(() {
      yukleniyor=true;
    });

    try{
     Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
     if(kullanici!= null){
     Kullanici firestoreKullanici = await  FirestoreServisi().kullaniciGetir(kullanici.id);
     if(firestoreKullanici == null){
       FirestoreServisi().kullaniciOlustur(
           id:kullanici.id,
           email: kullanici.email,
           kullaniciAdi: kullanici.kullaniciAdi,
           fotoUrl: kullanici.fotoUrl
       );
    }
     }
    }catch(hata){
      setState(() {
      yukleniyor=false;
    });
      uyariGoster(hataKodu: hata.toString());
    }
  }

 uyariGoster({hataKodu}){
    String hataMesaji;
    if(hataKodu == "PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null, null)"){
      hataMesaji="Girdiğiniz  mail adresi geçersiz.";
    }else {
      hataMesaji="Girilen e-mail veya şifre hatalı.";
    }
    var snackBar= SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
