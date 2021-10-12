// @dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp2/modeller/kullanici.dart';
import 'package:socialapp2/servisler/firestoreservisi.dart';
import 'package:socialapp2/servisler/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  const HesapOlustur({Key key}) : super(key: key);

  @override
  _HesapOlusturState createState() => _HesapOlusturState();

}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor =false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari=GlobalKey<ScaffoldState>();
  String kullaniciAdi,email,sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Hesap Oluştur"),
      ),
      body: ListView(
        children: <Widget>[
        yukleniyor? LinearProgressIndicator() : SizedBox(height: 0.0,),
         SizedBox (height: 20.0,),
          Padding(
            padding: const EdgeInsets.all(20.0),
         child: Form(
           key:_formAnahtari,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Kullanıcı adını giriniz",
                    labelText: "Kullanıcı adı",
                    errorStyle: TextStyle(fontSize: 16.0),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (girilenDeger) {
                    if (girilenDeger.isEmpty) {
                      return "Kullanıcı adı boş bırakılamaz";
                    } else if (girilenDeger.trim().length < 4 || girilenDeger.trim().length > 10) {
                      return "En fazla 10 en az 4 karakter olabilir.";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger){
                    kullaniciAdi=girilenDeger;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email adresinizi girin",
                    labelText: "Mail",
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
                  onSaved: (girilenDeger){
                    email=girilenDeger;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Şifrenizi Girin",
                    labelText: "Şifre",
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
                  onSaved: (girilenDeger){
                    sifre=girilenDeger;
                  },
                ),
          SizedBox(height: 50.0,),
          Container(
            width: double.infinity,
            child: FlatButton(


            onPressed: _kullaniciOlustur,
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
          ) ],),
          )
         ) ],
      ),
    );
  }

  void _kullaniciOlustur() async {

    final _yetkilendirmeServisi=Provider.of<YetkilendirmeServisi>(context,listen: false);
    var _formState = _formAnahtari.currentState;
    if(_formState.validate()){
      _formState.save();
      setState(() {
        yukleniyor=true;
      });
      try{
      Kullanici kullanici =  await _yetkilendirmeServisi.mailileKayit(email, sifre);
      if(kullanici != null){
        FirestoreServisi().kullaniciOlustur(id: kullanici.id,email: email, kullaniciAdi: kullaniciAdi);
      }
        Navigator.pop(context);
      }catch(hata){
        setState(() {
          yukleniyor = false;
        });
        print(hata.toString());
      uyariGoster(hataKodu: hata.toString());
      }

    }
  }

  uyariGoster({hataKodu}){
    String hataMesaji;
    if(hataKodu == "PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null, null)"){
      hataMesaji="Girdiğiniz  mail adresi geçersiz.";
    }else if(hataKodu == "PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null, null)"){
      hataMesaji="Girdiğiniz mal kayıtlıdır.";
    }else {
      hataMesaji="Daha zor bir şifre tercih edin.";
    }
    var snackBar= SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }

}
