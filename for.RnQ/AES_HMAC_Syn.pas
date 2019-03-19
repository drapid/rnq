unit AES_HMAC_Syn;
// This is an implementation of HMAC, the FIPS standard keyed hash function
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows,
  SynCrypto,
  RDGlobal
  ;


const
  HASH_INPUT_SIZE   = 64;
//  HASH_OUTPUT_SIZE  = SHA1HashSize;
  HASH_OUTPUT_SIZE  = 20;

  HMAC_OK       = 0;
  HMAC_BAD_MODE = -1;
  HMAC_IN_DATA  = Integer($ffffffff);


type
  hmac_ctx = record
    key: array[0..HASH_INPUT_SIZE-1] of AnsiChar;
    sh: TSHA1;
    klen: Integer;
  end;


procedure hmac_sha1_begin(var cx: hmac_ctx);
function  hmac_sha1_key(const key: RawByteString; key_len: Integer; var cx: hmac_ctx): Integer;
procedure hmac_sha1_data(const data: Pointer; data_len: Integer; var cx: hmac_ctx);
procedure hmac_sha1_end(mac: PByte; mac_len: Integer; cx: hmac_ctx);

procedure hmac_sha(const key: RawByteString; key_len: Integer;
          const data: Pointer; data_len : Int64;
          var mac: RawByteString; const mac_len: Integer);

function derive_key(const pwd: RawByteString;  // the PASSWORD
               const salt: RawByteString;      //* the SALT and its */
               const iter: Integer;         //* the number of iterations */
               const key_len: Integer)//* and its required length  */
               : RawByteString;

(*
    Field lengths (in bytes) versus File Encryption Mode (0 < mode < 4)

    Mode Key Salt  MAC Overhead
       1  16    8   10       18
       2  24   12   10       22
       3  32   16   10       26

   The following macros assume that the mode value is correct.
*)

const
   KEY_LENGTH: array[1..3] of byte = (16, 24, 32);
   SALT_LENGTH: array[1..3] of byte = (8, 12, 16);
   MAC_LENGTH = 10;
   EXPKEY_LENGTH: array[1..3] of byte = (44, 54, 64);

   PWD_VER_LENGTH = 2;
   MAX_KEY_LENGTH = 32;
   MAX_PWD_LENGTH = 128;
   MAX_SALT_LENGTH = 16;
   KEYING_ITERATIONS = 1000;

   AES_BLOCK_SIZE  = 16;  //* the AES block size in bytes          */
   BLOCK_SIZE = AES_BLOCK_SIZE;

//* a maximum of 60 32-bit words are needed for the key schedule		*/
   KS_LENGTH  = 64;

   GOOD_RETURN       = 0;
   PASSWORD_TOO_LONG = -100;
   BAD_MODE          = -101;

type
  Pint = ^Cardinal;
type
  fcrypt_ctx = record
    nonce    : array[0..BLOCK_SIZE-1] of Byte;  //* the CTR nonce          */
    encr_bfr : array[0..BLOCK_SIZE-1] of Byte;  //* encrypt buffer         */
    aes_ctx  : TAES;
    auth_ctx : hmac_ctx;                        //* authentication context */
    encr_pos : cardinal;                        //* block position (enc)   */
    pwd_len  : cardinal;                        //* password length        */
    mode     : cardinal;                        //* File encryption mode   */
 end;


//* initialise file encryption or decryption */
function fcrypt_init(
    mode: byte;                         //* the mode to be used (input)          */
    const pwd: RawByteString;           //* the user specified password (input)  */
//    unsigned int pwd_len,                //* the length of the password (input)   */
    const salt: RawByteString;          //* the salt (input)                     */
    var pwd_ver: RawByteString;         //* 2 byte password verifier (output)    */
    var cx: fcrypt_ctx) : Integer;      //* the file encryption context (output) */

//* perform 'in place' encryption or decryption and authentication               */
procedure fcrypt_encrypt(data : Pointer; data_len : Integer; var cx : fcrypt_ctx);
procedure fcrypt_decrypt(data : Pointer; data_len : Integer; var cx : fcrypt_ctx);

//* close encryption/decryption and return the MAC value */
//* the return value is the length of the MAC            */
function fcrypt_end(var cx: fcrypt_ctx)  //* the context (input)      */
                : RawByteString;          //* the MAC value (output)   */

implementation

uses
  SysUtils
    ;


function derive_key(const pwd : RawByteString;  // the PASSWORD
               const salt : RawByteString;      //* the SALT and its */
               const iter : Integer;         //* the number of iterations */
               const key_len : Integer)//* and its required length  */
               : RawByteString;
var
  i, j, k, n_blk: Integer;
  uu, ux: array[1..HASH_OUTPUT_SIZE] of Byte;
  c1, c2, c3: hmac_ctx;
begin
  SetLength(Result, key_len);

    //* set HMAC context (c1) for password               */
    hmac_sha1_begin(c1);
    hmac_sha1_key(PAnsiChar(pwd), Length(pwd), c1);

    //* set HMAC context (c2) for password and salt      */
//    memcpy(c2, c1, sizeof(hmac_ctx));
    CopyMemory(@c2, @c1, sizeof(c1));
    hmac_sha1_data(Pointer(salt), Length(salt), c2);

    //* find the number of SHA blocks in the key         */
    n_blk := 1 + (key_len - 1) div HASH_OUTPUT_SIZE;

//    for(i = 0; i < n_blk; ++i) /* for each block in key */
    for i := 0 to n_blk-1 do  //* for each block in key */
     begin
        //* ux[] holds the running xor value             */
//        memset(ux, 0, HASH_OUTPUT_SIZE);
        FillMemory(@ux[1], HASH_OUTPUT_SIZE, 00);

        //* set HMAC context (c3) for password and salt  */
//        memcpy(c3, c2, sizeof(hmac_ctx));
        CopyMemory(@c3, @c2, sizeof(c2));

        //* enter additional data for 1st block into uu  */
        uu[1] := Byte((i + 1) shr 24);
        uu[2] := Byte((i + 1) shr 16);
        uu[3] := Byte((i + 1) shr 8);
        uu[4] := Byte(i + 1);

        //* this is the key mixing iteration         */
        k := 4;
        for j := 0 to iter-1 do
        begin
            //* add previous round data to HMAC      */
            hmac_sha1_data(@uu[1], k, c3);
            //* obtain HMAC for uu[]                 */
            hmac_sha1_end(@uu[1], HASH_OUTPUT_SIZE, c3);

            //* xor into the running xor block       */
            for k := 1 to HASH_OUTPUT_SIZE do
                ux[k] := Byte(byte(ux[k]) xor byte(uu[k]));

            //* set HMAC context (c3) for password   */
//            memcpy(c3, c1, sizeof(hmac_ctx));
            CopyMemory(@c3, @c1, sizeof(c1));
          k := HASH_OUTPUT_SIZE;
        end;

        //* compile key blocks into the key output   */
        j := 0; k := i * HASH_OUTPUT_SIZE;
        while(j < HASH_OUTPUT_SIZE) and (k < key_len) do
         begin
          Result[k+1] := AnsiChar(ux[j+1]);
          inc(k);
          inc(j);
         end;
     end;
end;


//* initialise the HMAC context to zero */
procedure hmac_sha1_begin(var cx: hmac_ctx);
begin
  FillMemory(@cx, SizeOf(hmac_ctx), 00);
end;

//* input the HMAC key (can be called multiple times)    */
function hmac_sha1_key(const key: RawByteString; key_len: Integer; var cx: hmac_ctx): Integer;
begin
  if (cx.klen = HMAC_IN_DATA) then            //* error if further key input   */
   begin
    Result := HMAC_BAD_MODE;                //* is attempted in data mode    */
    Exit;
   end;

    if(cx.klen + key_len > HASH_INPUT_SIZE) then //* if the key has to be hashed  */
     begin
        if(cx.klen <= HASH_INPUT_SIZE) then    //* if the hash has not yet been */
         begin                                  //* started, initialise it and   */
            cx.sh.Init;                           //* hash stored key characters   */
            cx.sh.Update(@cx.key[0], cx.klen);
         end;
       cx.sh.Update(@key[1], key_len);               //* hash long key data into hash */
     end
    else                                        //* otherwise store key data     */
//        memcpy(cx->key + cx->klen, key, key_len);
      CopyMemory(@cx.key[cx.klen], Pointer(key), key_len);

//    cx.klen += key_len;                        //* update the key length count  */
    inc(cx.klen, key_len);
    Result := HMAC_OK;
end;

//* input the HMAC data (can be called multiple times) - */
//* note that this call terminates the key input phase   */
procedure hmac_sha1_data(const data: Pointer; data_len: Integer; var cx: hmac_ctx);
var
  k: Integer;
  res: TSHA1Digest;
//  res: T_Sha1_Digest;
begin
    if(cx.klen <> HMAC_IN_DATA) then            //* if not yet in data phase */
    begin
      if(cx.klen > HASH_INPUT_SIZE) then       //* if key is being hashed   */
        begin                                  //* complete the hash and    */
          cx.sh.Final(res);                    //* store the result as the  */
          CopyMemory(@cx.key[0], @res[0], HASH_OUTPUT_SIZE);
          cx.klen := HASH_OUTPUT_SIZE;       //* key and set new length   */
        end;

        //* pad the key if necessary */
//        memset(cx->key + cx->klen, 0, HASH_INPUT_SIZE - cx->klen);
        FillMemory(@cx.key[cx.klen], HASH_INPUT_SIZE - cx.klen, 00);

        //* xor ipad into key value  */
//        for i := 0 to HASH_INPUT_SIZE do
//         byte(cx.key[i]) := byte(cx.key[i]) xor $36;
        k := 0;
        while k < HASH_INPUT_SIZE do
          begin
            Pint(@cx.key[k])^ := Pint(@cx.key[k])^ xor $36363636;
            Inc(k, 4);
          end;

        //* and start hash operation */
         cx.sh.Init;
         cx.sh.Update(@cx.key[0], HASH_INPUT_SIZE);

        //* mark as now in data mode */
        cx.klen := HMAC_IN_DATA;
    end;

    //* hash the data (if any)       */
    if (data_len > 0) then
      cx.sh.Update(data, data_len);             
end;


//* input the HMAC data (can be called multiple times) - */
//* note that this call terminates the key input phase   */
procedure hmac_sha1_end(mac: PByte; mac_len: Integer; cx: hmac_ctx);
var
  dig: TSHA1Digest;
  i, k: Integer;
begin
    //* if no data has been entered perform a null data phase        */
    if (cx.klen <> HMAC_IN_DATA) then
      hmac_sha1_data(nil, 0, cx);
//      hmac_sha_data(i, 0, cx);

    cx.sh.Final(dig);

    //* set outer key value using opad and removing ipad */
{
    for i := 0 to (HASH_INPUT_SIZE) do
//     ((unsigned long*)cx->key)[i] ^= 0x36363636 ^ 0x5c5c5c5c;
     byte(cx.key[i]) := byte(cx.key[i]) xor $36 xor $5c;
}

    k := 0;
    while k < HASH_INPUT_SIZE do
      begin
        Pint(@cx.key[k])^ := Pint(@cx.key[k])^ xor $36363636 xor $5c5c5c5c;
        Inc(k, 4);
      end;

    //* perform the outer hash operation */

    cx.sh.Init;
    cx.sh.Update(@cx.key[0], HASH_INPUT_SIZE);
    cx.sh.Update(@dig[0], HASH_OUTPUT_SIZE);
    cx.sh.Final(dig, True);

//    SetLength(mac, HASH_OUTPUT_SIZE);
    //* output the hash value            */
//    SetLength(mac, mac_len);
    for i := 0 to mac_len-1 do
//      mac[i+1] := AnsiChar(dig[i]);
//      mac[i] := Byte(dig[i]);
      Byte(PByte(IntPtr(mac)+i)^) := Byte(dig[i]);
end;

//* 'do it all in one go' subroutine     */
procedure hmac_sha(const key: RawByteString; key_len: Integer;
          const data: Pointer; data_len: Int64;
          var mac: RawByteString; const mac_len: Integer);
var
 cx: hmac_ctx;
begin
  hmac_sha1_begin(cx);
  hmac_sha1_key(key, key_len, cx);
  hmac_sha1_data(data, data_len, cx);
  SetLength(mac, mac_len);
  hmac_sha1_end(@mac[1], mac_len, cx);
end;



//* initialise file encryption or decryption */
function fcrypt_init(
    mode: byte;                         //* the mode to be used (input)          */
    const pwd: RawByteString;              //* the user specified password (input)  */
//    unsigned int pwd_len,              //* the length of the password (input)   */
    const salt: RawByteString;             //* the salt (input)                     */
    var pwd_ver: RawByteString;            //* 2 byte password verifier (output)    */
    var cx: fcrypt_ctx): Integer;      //* the file encryption context (output) */
var
  buf, buf2: RawByteString;
begin
  if(Length(pwd) > MAX_PWD_LENGTH) then
   begin
    Result := PASSWORD_TOO_LONG;
    Exit;
   end;

  if(mode < 1) or (mode > 3) then
   begin
     Result := BAD_MODE;
     Exit;
   end;

    cx.mode := mode;
    cx.pwd_len := Length(pwd);
    //* initialise the encryption nonce and buffer pos   */
    cx.encr_pos := BLOCK_SIZE;

	//* if we need a random component in the encryption  */
    //* nonce, this is where it would have to be set     */
//    memset(cx.nonce, 0, BLOCK_SIZE * sizeof(unsigned char));
    FillMemory(@cx.nonce[0], BLOCK_SIZE, 00);

	//* derive the encryption and authetication keys and the password verifier   */
    buf := derive_key(pwd, salt, KEYING_ITERATIONS, 2 * KEY_LENGTH[mode] + PWD_VER_LENGTH);

    //* set the encryption key							*/
    cx.aes_ctx.EncryptInit((buf[1]), KEY_LENGTH[mode] * 8);

	//* initialise for authentication			        */
    hmac_sha1_begin(cx.auth_ctx);

    //* set the authentication key						*/
    buf2 := Copy(buf, KEY_LENGTH[mode]+1, KEY_LENGTH[mode]);
//    hmac_sha1_key(PAnsichar(buf) + KEY_LENGTH[mode], KEY_LENGTH[mode], cx.auth_ctx);
    hmac_sha1_key(buf2, KEY_LENGTH[mode], cx.auth_ctx);
//    memcpy(pwd_ver, kbuf + 2 * KEY_LENGTH(mode), PWD_VER_LENGTH);
    pwd_ver := copy(buf, 2 * KEY_LENGTH[mode] + 1, PWD_VER_LENGTH);
	//* clear the buffer holding the derived key values	*/
//	memset(kbuf, 0, 2 * KEY_LENGTH(mode) + PWD_VER_LENGTH);
  buf := '';

  Result := GOOD_RETURN;
end;


{$OVERFLOWCHECKS OFF}
procedure encr_data(var data: Pointer; d_len: Integer; var cx: fcrypt_ctx);
var
  i, j: Integer;
  pos: Cardinal;
begin
  i := 0;
  pos := cx.encr_pos;
  while(i < d_len) do
   begin
     if(pos = BLOCK_SIZE) then
      begin
        j := 0;
            //* increment encryption nonce   */
//            while(j < 8 && !++cx->nonce[j])
//                ++j;
            while j < 8 do
             begin
               inc(cx.nonce[j]);
//               if cx.nonce[j] = 0 then
               if cx.nonce[j] <> 0 then
                Break;
               inc(j);
             end;
            //* encrypt the nonce to form next xor buffer    */
         cx.aes_ctx.Encrypt(TAESBlock(cx.nonce), TAESBlock(cx.encr_bfr));
         pos := 0;
      end;
     Byte(Pointer(IntPtr(data)+i)^) := Byte(Pointer(IntPtr(data)+i)^) xor cx.encr_bfr[pos];
     inc(i);
     inc(pos);
   end;
  cx.encr_pos := pos;
end;
 {$OVERFLOWCHECKS ON}

//* perform 'in place' encryption or decryption and authentication               */
procedure fcrypt_encrypt(data: Pointer; data_len: Integer; var cx: fcrypt_ctx);
begin
  encr_data(data, data_len, cx);
  hmac_sha1_data(data, data_len, cx.auth_ctx);
end;

procedure fcrypt_decrypt(data: Pointer; data_len: Integer; var cx: fcrypt_ctx);
begin
  hmac_sha1_data(data, data_len, cx.auth_ctx);
  encr_data(data, data_len, cx);
end;

//* close encryption/decryption and return the MAC value */
//* the return value is the length of the MAC            */
function fcrypt_end(var cx: fcrypt_ctx)  //* the context (input)      */
                : RawByteString;          //* the MAC value (output)   */
begin
  SetLength(Result, MAC_LENGTH);
  hmac_sha1_end(@Result[1], MAC_LENGTH, cx.auth_ctx);
//  hmac_sha1_end(Result, MAC_LENGTH, cx.auth_ctx);
//	memset(cx, 0, sizeof(fcrypt_ctx));	//* clear the encryption context	*/
  FillMemory(@cx, sizeof(fcrypt_ctx), 0);
//	Result  MAC_LENGTH(res);				//* return MAC length in bytes   */
end;


end.
