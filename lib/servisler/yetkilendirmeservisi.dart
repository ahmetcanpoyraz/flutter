// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp2/modeller/kullanici.dart';

class YetkilendirmeServisi{
  final   FirebaseAuth _firebaseAuth= FirebaseAuth.instance;
  String aktifKullaniciId;


  Kullanici _kullaniciOlustur(FirebaseUser kullanici) {
    return  Kullanici.firebasedenUret(kullanici);
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth.onAuthStateChanged.map(_kullaniciOlustur);
  }
  Future<Kullanici> mailileKayit(String eposta,String sifre) async{
   var girisKarti= await _firebaseAuth.createUserWithEmailAndPassword(email: eposta, password: sifre);
   return _kullaniciOlustur(girisKarti.user);
  }
  Future<Kullanici> mailileGiris(String eposta,String sifre) async{
    var girisKarti= await _firebaseAuth.signInWithEmailAndPassword(email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user);
  }
  cikisYap(){
    return _firebaseAuth.signOut();
  }

  Future<void> sifremiSifirla(String eposta) async {
    await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }

   Future<Kullanici> googleIleGiris() async{
    GoogleSignInAccount googleHesabi = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleYetkiKartim = await googleHesabi.authentication;
    AuthCredential sifresizGirisBelsgesi = GoogleAuthProvider.getCredential(idToken: googleYetkiKartim.idToken, accessToken: googleYetkiKartim.accessToken);
    AuthResult girisKarti = await  _firebaseAuth.signInWithCredential(sifresizGirisBelsgesi);
    return _kullaniciOlustur(girisKarti.user);
  }
}