import 'dart:convert' show utf8, base64Encode;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
// ignore: depend_on_referenced_packages
import 'package:pointycastle/asymmetric/api.dart';

class CryptUtil {
  // md5 hashing a random number
  static String md5RandomString() {
    final randomNumber = Random().nextDouble();
    final randomBytes = utf8.encode(randomNumber.toString());
    final randomString = md5.convert(randomBytes).toString();
    return randomString;
  }

  // sha1 hashing a random number
  static String sha1RandomString() {
    final randomNumber = Random().nextDouble();
    final randomBytes = utf8.encode(randomNumber.toString());
    final randomString = sha1.convert(randomBytes).toString();
    return randomString;
  }

  /// base64 a random number
  static String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  /// aes加密
  static String aesEncode({required String content, required String key}) {
    final secretKey = encrypt.Key.fromUtf8(key);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(secretKey, mode: encrypt.AESMode.ecb),
    );
    final encrypted = encrypter.encrypt(content);

    return encrypted.base64;
  }

  /// aes解密
  static String aesDecode({required String content, required String key}) {
    final secretKey = encrypt.Key.fromUtf8(key);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(secretKey, mode: encrypt.AESMode.ecb, padding: 'PKCS7'),
    );
    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(content));
    return decrypted;
  }

  /// RSA加密算法加密，秘钥格式为[pkcs8]
  /// [content]明文
  /// [publicKeyStr]公钥
  static String rsaEncrypt(String content, String publicKeyStr) {
    final parser = encrypt.RSAKeyParser();
    String publicKeyString = _transformPem(publicKeyStr);
    RSAPublicKey publicKey = parser.parse(publicKeyString) as RSAPublicKey;
    final encryptor = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    final encrypted = encryptor.encrypt(content);
    return encrypted.base64;
  }

  /// RSA加密算法解密，秘钥格式为[pkcs8]
  /// [encryptedStr]密文，base64编码
  /// [privateKeyStr]私钥
  static String rsaDecrypt(String encryptedStr, String privateKeyStr) {
    final parser = encrypt.RSAKeyParser();
    String publicKeyString = _transformPem(privateKeyStr, isPublic: false);
    RSAPrivateKey privateKey = parser.parse(publicKeyString) as RSAPrivateKey;
    final encryptor = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    final encrypted = encrypt.Encrypted.fromBase64(encryptedStr);
    final decrypted = encryptor.decrypt(encrypted);
    return decrypted;
  }

  /// 把秘钥从字符串转成PEM文件格式
  /// [str]秘钥，字符串
  /// [isPublic]是否是公钥
  static String _transformPem(String str, {bool isPublic = true}) {
    var begin = isPublic
        ? '-----BEGIN PUBLIC KEY-----\n'
        : "-----BEGIN PRIVATE KEY-----\n";
    var end = isPublic
        ? '\n-----END PUBLIC KEY-----'
        : '\n-----END PRIVATE KEY-----';
    // 如果已经是PEM格式的秘钥，直接返回
    if (str.contains(begin) && str.contains(end)) return str;
    // 去掉空格和换行
    str.replaceAll(' ', '').replaceAll('\n', '');

    int splitCount = str.length ~/ 64;
    List<String> strList = [];

    for (int i = 0; i < splitCount; i++) {
      strList.add(str.substring(64 * i, 64 * (i + 1)));
    }
    if (str.length % 64 != 0) {
      strList.add(str.substring(64 * splitCount));
    }

    return begin + strList.join('\n') + end;
  }
}
