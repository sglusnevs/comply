import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Arrays;
import java.util.Base64;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
 
/*
  RSA TEST based on https://adangel.org/2016/08/29/openssl-rsa-java/

  decrypter.encryptedSymKeyRSABase64 kommt aus openssl Kommand:

  $ echo -n "RandomSymPassGenerated" | openssl rsautl -encrypt -inkey comply.crt -pubin -oaep | openssl base64 -A

  AES TEST based on https://github.com/patc888/encrypt_java_openssl/blob/main/src/main/java/Encrypter.java

  decrypter.encryptedAESPayload kommt aus openssl Kommand:

  $ echo -n "Sample data to transmit" | gzip -c | openssl enc -aes-256-cbc -md sha256 -pass pass:RandomSymPassGenerated -a -A

  More info un differencies between OpenSSL and Java-based encription is here:

  https://medium.com/@patc888/decrypt-openssl-encrypted-data-in-java-4c31983afe19

*/

public class PLDecrypt {

  String encryptedSymKeyRSABase64;

  String privateKeyFilename;

  String encryptedAESPayload;

  public String decryptAES(byte[] password, String cipherText) throws NoSuchAlgorithmException, NoSuchPaddingException,
      InvalidAlgorithmParameterException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, IOException {

    // Parse cipher text
    byte[] cipherBytes = Base64.getDecoder().decode(cipherText);
    byte[] salt = Arrays.copyOfRange(cipherBytes, 8, 16);
    cipherBytes = Arrays.copyOfRange(cipherBytes, 16, cipherBytes.length);

    // Derive key
    byte[] passAndSalt = concat(password, salt);
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] key = md.digest(passAndSalt);
    SecretKeySpec secretKey = new SecretKeySpec(key, "AES");

    // Derive IV
    md.reset();
    byte[] iv = Arrays.copyOfRange(md.digest(concat(key, passAndSalt)), 0, 16);

    Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING");
    cipher.init(Cipher.DECRYPT_MODE, secretKey, new IvParameterSpec(iv));
	
	// decrypt data into byte array
	byte[] clear = cipher.doFinal(cipherBytes);
	
	// prepare string to write decrypted data into 
	
	StringBuilder outStr = new StringBuilder();
	
	if (!isCompressed(clear)) {
		
		System.out.println("Not compressed");
		
		return new String(clear);
		
	} else {
		
      GZIPInputStream gis = new GZIPInputStream(new ByteArrayInputStream(clear));
	  
      BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(gis, "UTF-8"));
	  	  
      String line;
	  
      while ((line = bufferedReader.readLine()) != null) {
		  
        outStr.append(line);
      }	
    }
	
    return outStr.toString();
  }

  public byte[] decryptRSA(String privateKeyFilename, String cipherText) throws NoSuchAlgorithmException, NoSuchPaddingException, Exception, InvalidKeyException, IllegalBlockSizeException {

        Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA1AndMGF1Padding");

        PrivateKey privateKey = loadPrivateKey(privateKeyFilename);

        cipher.init(Cipher.DECRYPT_MODE, privateKey);

        byte[] encryptedKeyRSA = Base64.getDecoder().decode(cipherText);

        byte[] decryptedKeyAES = cipher.doFinal(encryptedKeyRSA);

        return decryptedKeyAES;
  }

  private PrivateKey loadPrivateKey(String Filename) throws Exception {

       String privateKeyPEM = PLDecrypt.readFileToString(Filename);

        // strip of header, footer, newlines, whitespaces
        privateKeyPEM = privateKeyPEM
                .replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replaceAll("\\s", "");
    
        // decode to get the binary DER representation
        byte[] privateKeyDER = Base64.getDecoder().decode(privateKeyPEM);

        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        PrivateKey privateKey = keyFactory.generatePrivate(new PKCS8EncodedKeySpec(privateKeyDER));
        return privateKey;
  }

  private static String readFileToString(String filePath)  {
        String content = "";
 
        try {

            content = new String ( Files.readAllBytes( Paths.get(filePath) ) );

        } catch (IOException e) {

            e.printStackTrace();
        }
 
        return content;
  }

  private byte[] concat(byte[] a, byte[] b) {

    byte[] c = new byte[a.length + b.length];
    System.arraycopy(a, 0, c, 0, a.length);
    System.arraycopy(b, 0, c, a.length, b.length);
    return c;
  }

  public static boolean isCompressed(final byte[] compressed) {
	  
    return (compressed[0] == (byte) (GZIPInputStream.GZIP_MAGIC)) && (compressed[1] == (byte) (GZIPInputStream.GZIP_MAGIC >> 8));
  }

  public static void main(String[] args) throws Exception {

        PLDecrypt decrypter = new PLDecrypt();

        decrypter.privateKeyFilename = "comply.key";

        decrypter.encryptedSymKeyRSABase64 = "fLape5Ta78RYq6mP37qjMmpKBr48PY8lC+cl0MQSM6ch/qFUYPCdOM9S8IYwMni6OupCKVeChmkyItQVeI7VOG5oHktAliBG5jq33yAgC3bdFz6KEM227y5Z9z+KC7Io9X/Oye4lNyQMRXzhUsS80dlVpltcchEDinEnEBvTCp++GHJ784pK2cZpkxApFtz6X8iH7LVhM6WzD/7+7Y3T/2XtNOt06DQmKyUkSUBYjWd5eC33LaYuBIIaaJ88ofITAzasxB76NFYHMnn66OMhFX4+rkHw+6XT2Yq0c8xdyZM7diEH1ncmaeAxEIrEsdPlpcZnuHMzLzk+WvtQr5FCL+dMFd10qI6V4t160vKi7PMzdlFLJaLu5IF8BZTG32hZQA3X7dQgnCcCd6y0SCrhMNoXExnoeixA4/SJMDn2bQbqulbcY+mW5V3xWhFqcgNtDNl2dpbcy2Q25NI7uof+lU/2oxLPHD9eW0fyLM8TDm/F2xQ8jtgZ/Xh5Z7oay+Jk3vgCNJex7Vud3gNodB+S4m7gAKSZ5Z4jxyJ+yoEjqs20a2tSlLPx3fni+/hEO+2gb0CxhMzkL0fKMlDb8suSmTVIKw33Hd4CdHAmK/DSMu3Ab/hTdkBuBHQhQTPEFpVaP1GA2Msa+Ld4kyxKcIuhaB6b0CJEXM6FgQx9QDd+5gk=";

        decrypter.encryptedAESPayload = "U2FsdGVkX1+dCSNTqyOLL1Rwg2OfHU957jd4iER1UulMBit4wVzEddjub5ysZc0AnPBnWWqS4wmeQMXqo/3EtE0SPkyIKDh7V0JOjH6NaEB50hYh4nExIonnO0DfVP6IdBaLu0UUUgIw1QKZzNPeBAgGIUH8ABMWu+lCv56QkN7b19MKQlkOnY96uwyPOk1n5PMtd+gAJd2AXwZBAdyMdN3IxjXEk7k5uX/gHRBn6Me1u9tOZXRIAfO6ZKo+nXHvbKsg6ssMey1UYDwI2Kfb/3WbjOTuJq1O5mYrJ8JAf5tdq/ee2Y8jaWakYCq5IA0YYZTDeVOLDAurftQ9V/OZmVfChnR7+Zoe1+2uyhyfvoYETlbpoZx0+qznN7O83UQWvP6EOhJdDWVqV0LwW25H0ODpsmwBY3D7fK0ITA6Oc31rxmLwD02n0an312iJZwJ6jgUAVcVuh6v4R6ChM2EnGePK/RB1P27CV99FvndxWh4Lo2AxNwOALJ/uvK5E0xuRp2p1z1BkSXjlIHxBStfxKZKkhwJJH1Gc/K3ewJJgalGWzISLjCWvBfXcmGOIGJljHPBYZKWmN7PUgrj2SQFojQ==";

        // first, decrypt AES SymKey with RSA Private Key

        byte[] decryptedKeyAES = decrypter.decryptRSA(decrypter.privateKeyFilename, decrypter.encryptedSymKeyRSABase64);

        String decryptedKey = new String(decryptedKeyAES, StandardCharsets.UTF_8);

        System.out.print("Decrypted symmetric password: " + decryptedKey);

        System.out.println();

        // then, decrypt payload with AES SymKey

        String decryptedData = decrypter.decryptAES(decryptedKeyAES, decrypter.encryptedAESPayload);

        System.out.print( "Decrypted Data: " + decryptedData );

        System.out.println();

  }
}



