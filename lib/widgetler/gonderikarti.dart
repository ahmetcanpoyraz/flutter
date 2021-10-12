// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp2/modeller/gonderi.dart';
import 'package:socialapp2/modeller/kullanici.dart';
import 'package:socialapp2/sayfalar/profil.dart';
import 'package:socialapp2/sayfalar/yorumlar.dart';
import 'package:socialapp2/servisler/firestoreservisi.dart';
import 'package:socialapp2/servisler/yetkilendirmeservisi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;
  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi=0;
  bool _begendin = false;
  String _aktifKullaniciId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context,listen:false).aktifKullaniciId;
   _begeniSayisi= widget.gonderi.begeniSayisi;
   begeniVarmi();
  }
  begeniVarmi()async{
  bool begeniVarmi = await FirestoreServisi().begeniVarmi(widget.gonderi, _aktifKullaniciId);
      if(begeniVarmi){
        if(mounted){
          setState(() {
            _begendin = true;
          });
        }
        }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: <Widget>[
          _gonderiBasligi(),
          _gonderiResmi(),
          _gonderiAlt(),
        ],
      ),
    );
  }

  gonderiSecenekleri(){
    showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
              title:Text("Seçiminiz Nedir?"),
            children:<Widget> [
              SimpleDialogOption(
                child: Text("Gönderiyi Sil"),
                onPressed: (){
                  FirestoreServisi().gonderiSil(aktifKullaniciId: _aktifKullaniciId, gonderi: widget.gonderi);
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("Vazgeç",style: TextStyle(color: Colors.red),),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );

        });
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(profilSahibiId: widget.gonderi.yayinlayanId,)));
    },
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
              ? NetworkImage(widget.yayinlayan.fotoUrl)
              : AssetImage("assets/images/hayalet.png"),
        ),
      ),
      ),
      title:GestureDetector( onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(profilSahibiId: widget.gonderi.yayinlayanId,)));
      },
        child: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      ),
      trailing: _aktifKullaniciId==widget.gonderi.yayinlayanId ? IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: ()=>gonderiSecenekleri(),
      ): null,
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover),);
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              onPressed: _begeniDegistir,
              icon: !_begendin ? Icon(
                Icons.favorite_border,
                size: 35.0,
              ): Icon(
                Icons.favorite,color: Colors.red,
                size: 35.0,
              ),
            ),
            IconButton(
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>Yorumlar(gonderi: widget.gonderi,)));
              },
              icon: Icon(
                Icons.comment,
                size: 35.0,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: RichText(
            text: TextSpan(
                text: widget.yayinlayan.kullaniciAdi + " ",
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(
                      text: widget.gonderi.aciklama,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ))
                ]),
          ),
        ) :SizedBox(height: 0.0,)
      ],
    );
  }

  void _begeniDegistir(){
            if(_begendin){
            setState(() {
              _begendin=false;
              _begeniSayisi=_begeniSayisi-1;
            });
            FirestoreServisi().gonderiBegeniKaldir(widget.gonderi,_aktifKullaniciId);
            }else{
              setState(() {
                _begendin=true;
                _begeniSayisi=_begeniSayisi+1;
              });
              FirestoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
            }
  }
}
