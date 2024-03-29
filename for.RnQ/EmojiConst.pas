{
  This file is part of R&Q.
  Under same license
}
unit EmojiConst;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  RDGlobal;

type
  TEmojiContArr = TArray<Integer>;

const
  emojisCount = 1276;
  emojiContentsCount = 8;
  emojiExtNumbers: array [1..emojiContentsCount] of Integer = (984, 1110, 386, 507, 501, 822, 694, 227);
  emojiCodePoints: array [0..(emojisCount-1)] of array [1..2] of cardinal = (
    ($0023,$20e3), ($002a,$20e3), ($0030,$20e3), ($0031,$20e3), ($0032,$20e3), ($0033,$20e3), ($0034,$20e3), ($0035,$20e3), ($0036,$20e3), ($0037,$20e3), ($0038,$20e3), ($0039,$20e3), ($00a9,$0), ($00ae,$0), ($1f004,$0), ($1f0cf,$0), ($1f170,$0), ($1f171,$0), ($1f17e,$0), ($1f17f,$0), ($1f18e,$0), ($1f191,$0), ($1f192,$0), ($1f193,$0), ($1f194,$0), ($1f195,$0), ($1f196,$0), ($1f197,$0), ($1f198,$0), ($1f199,$0), ($1f19a,$0), ($1f1e6,$1f1e8), ($1f1e6,$1f1e9), ($1f1e6,$1f1ea), ($1f1e6,$1f1eb), ($1f1e6,$1f1ec), ($1f1e6,$1f1ee), ($1f1e6,$1f1f1), ($1f1e6,$1f1f2), ($1f1e6,$1f1f4), ($1f1e6,$1f1f6), ($1f1e6,$1f1f7), ($1f1e6,$1f1f8), ($1f1e6,$1f1f9), ($1f1e6,$1f1fa), ($1f1e6,$1f1fc), ($1f1e6,$1f1fd), ($1f1e6,$1f1ff), ($1f1e7,$1f1e6), ($1f1e7,$1f1e7),
    ($1f1e7,$1f1e9), ($1f1e7,$1f1ea), ($1f1e7,$1f1eb), ($1f1e7,$1f1ec), ($1f1e7,$1f1ed), ($1f1e7,$1f1ee), ($1f1e7,$1f1ef), ($1f1e7,$1f1f1), ($1f1e7,$1f1f2), ($1f1e7,$1f1f3), ($1f1e7,$1f1f4), ($1f1e7,$1f1f6), ($1f1e7,$1f1f7), ($1f1e7,$1f1f8), ($1f1e7,$1f1f9), ($1f1e7,$1f1fb), ($1f1e7,$1f1fc), ($1f1e7,$1f1fe), ($1f1e7,$1f1ff), ($1f1e8,$1f1e6), ($1f1e8,$1f1e8), ($1f1e8,$1f1e9), ($1f1e8,$1f1eb), ($1f1e8,$1f1ec), ($1f1e8,$1f1ed), ($1f1e8,$1f1ee), ($1f1e8,$1f1f0), ($1f1e8,$1f1f1), ($1f1e8,$1f1f2), ($1f1e8,$1f1f3), ($1f1e8,$1f1f4), ($1f1e8,$1f1f5), ($1f1e8,$1f1f7), ($1f1e8,$1f1fa), ($1f1e8,$1f1fb), ($1f1e8,$1f1fc), ($1f1e8,$1f1fd), ($1f1e8,$1f1fe), ($1f1e8,$1f1ff), ($1f1e9,$1f1ea), ($1f1e9,$1f1ec), ($1f1e9,$1f1ef), ($1f1e9,$1f1f0), ($1f1e9,$1f1f2), ($1f1e9,$1f1f4), ($1f1e9,$1f1ff), ($1f1ea,$1f1e6), ($1f1ea,$1f1e8), ($1f1ea,$1f1ea), ($1f1ea,$1f1ec),
    ($1f1ea,$1f1ed), ($1f1ea,$1f1f7), ($1f1ea,$1f1f8), ($1f1ea,$1f1f9), ($1f1ea,$1f1fa), ($1f1eb,$1f1ee), ($1f1eb,$1f1ef), ($1f1eb,$1f1f0), ($1f1eb,$1f1f2), ($1f1eb,$1f1f4), ($1f1eb,$1f1f7), ($1f1ec,$1f1e6), ($1f1ec,$1f1e7), ($1f1ec,$1f1e9), ($1f1ec,$1f1ea), ($1f1ec,$1f1eb), ($1f1ec,$1f1ec), ($1f1ec,$1f1ed), ($1f1ec,$1f1ee), ($1f1ec,$1f1f1), ($1f1ec,$1f1f2), ($1f1ec,$1f1f3), ($1f1ec,$1f1f5), ($1f1ec,$1f1f6), ($1f1ec,$1f1f7), ($1f1ec,$1f1f8), ($1f1ec,$1f1f9), ($1f1ec,$1f1fa), ($1f1ec,$1f1fc), ($1f1ec,$1f1fe), ($1f1ed,$1f1f0), ($1f1ed,$1f1f2), ($1f1ed,$1f1f3), ($1f1ed,$1f1f7), ($1f1ed,$1f1f9), ($1f1ed,$1f1fa), ($1f1ee,$1f1e8), ($1f1ee,$1f1e9), ($1f1ee,$1f1ea), ($1f1ee,$1f1f1), ($1f1ee,$1f1f2), ($1f1ee,$1f1f3), ($1f1ee,$1f1f4), ($1f1ee,$1f1f6), ($1f1ee,$1f1f7), ($1f1ee,$1f1f8), ($1f1ee,$1f1f9), ($1f1ef,$1f1ea), ($1f1ef,$1f1f2), ($1f1ef,$1f1f4),
    ($1f1ef,$1f1f5), ($1f1f0,$1f1ea), ($1f1f0,$1f1ec), ($1f1f0,$1f1ed), ($1f1f0,$1f1ee), ($1f1f0,$1f1f2), ($1f1f0,$1f1f3), ($1f1f0,$1f1f5), ($1f1f0,$1f1f7), ($1f1f0,$1f1fc), ($1f1f0,$1f1fe), ($1f1f0,$1f1ff), ($1f1f1,$1f1e6), ($1f1f1,$1f1e7), ($1f1f1,$1f1e8), ($1f1f1,$1f1ee), ($1f1f1,$1f1f0), ($1f1f1,$1f1f7), ($1f1f1,$1f1f8), ($1f1f1,$1f1f9), ($1f1f1,$1f1fa), ($1f1f1,$1f1fb), ($1f1f1,$1f1fe), ($1f1f2,$1f1e6), ($1f1f2,$1f1e8), ($1f1f2,$1f1e9), ($1f1f2,$1f1ea), ($1f1f2,$1f1eb), ($1f1f2,$1f1ec), ($1f1f2,$1f1ed), ($1f1f2,$1f1f0), ($1f1f2,$1f1f1), ($1f1f2,$1f1f2), ($1f1f2,$1f1f3), ($1f1f2,$1f1f4), ($1f1f2,$1f1f5), ($1f1f2,$1f1f6), ($1f1f2,$1f1f7), ($1f1f2,$1f1f8), ($1f1f2,$1f1f9), ($1f1f2,$1f1fa), ($1f1f2,$1f1fb), ($1f1f2,$1f1fc), ($1f1f2,$1f1fd), ($1f1f2,$1f1fe), ($1f1f2,$1f1ff), ($1f1f3,$1f1e6), ($1f1f3,$1f1e8), ($1f1f3,$1f1ea), ($1f1f3,$1f1eb),
    ($1f1f3,$1f1ec), ($1f1f3,$1f1ee), ($1f1f3,$1f1f1), ($1f1f3,$1f1f4), ($1f1f3,$1f1f5), ($1f1f3,$1f1f7), ($1f1f3,$1f1fa), ($1f1f3,$1f1ff), ($1f1f4,$1f1f2), ($1f1f5,$1f1e6), ($1f1f5,$1f1ea), ($1f1f5,$1f1eb), ($1f1f5,$1f1ec), ($1f1f5,$1f1ed), ($1f1f5,$1f1f0), ($1f1f5,$1f1f1), ($1f1f5,$1f1f2), ($1f1f5,$1f1f3), ($1f1f5,$1f1f7), ($1f1f5,$1f1f8), ($1f1f5,$1f1f9), ($1f1f5,$1f1fc), ($1f1f5,$1f1fe), ($1f1f6,$1f1e6), ($1f1f7,$1f1ea), ($1f1f7,$1f1f4), ($1f1f7,$1f1f8), ($1f1f7,$1f1fa), ($1f1f7,$1f1fc), ($1f1f8,$1f1e6), ($1f1f8,$1f1e7), ($1f1f8,$1f1e8), ($1f1f8,$1f1e9), ($1f1f8,$1f1ea), ($1f1f8,$1f1ec), ($1f1f8,$1f1ed), ($1f1f8,$1f1ee), ($1f1f8,$1f1ef), ($1f1f8,$1f1f0), ($1f1f8,$1f1f1), ($1f1f8,$1f1f2), ($1f1f8,$1f1f3), ($1f1f8,$1f1f4), ($1f1f8,$1f1f7), ($1f1f8,$1f1f8), ($1f1f8,$1f1f9), ($1f1f8,$1f1fb), ($1f1f8,$1f1fd), ($1f1f8,$1f1fe), ($1f1f8,$1f1ff),
    ($1f1f9,$1f1e6), ($1f1f9,$1f1e8), ($1f1f9,$1f1e9), ($1f1f9,$1f1eb), ($1f1f9,$1f1ec), ($1f1f9,$1f1ed), ($1f1f9,$1f1ef), ($1f1f9,$1f1f0), ($1f1f9,$1f1f1), ($1f1f9,$1f1f2), ($1f1f9,$1f1f3), ($1f1f9,$1f1f4), ($1f1f9,$1f1f7), ($1f1f9,$1f1f9), ($1f1f9,$1f1fb), ($1f1f9,$1f1fc), ($1f1f9,$1f1ff), ($1f1fa,$1f1e6), ($1f1fa,$1f1ec), ($1f1fa,$1f1f2), ($1f1fa,$1f1f8), ($1f1fa,$1f1fe), ($1f1fa,$1f1ff), ($1f1fb,$1f1e6), ($1f1fb,$1f1e8), ($1f1fb,$1f1ea), ($1f1fb,$1f1ec), ($1f1fb,$1f1ee), ($1f1fb,$1f1f3), ($1f1fb,$1f1fa), ($1f1fc,$1f1eb), ($1f1fc,$1f1f8), ($1f1fd,$1f1f0), ($1f1fe,$1f1ea), ($1f1fe,$1f1f9), ($1f1ff,$1f1e6), ($1f1ff,$1f1f2), ($1f1ff,$1f1fc), ($1f201,$0), ($1f202,$0), ($1f21a,$0), ($1f22f,$0), ($1f232,$0), ($1f233,$0), ($1f234,$0), ($1f235,$0), ($1f236,$0), ($1f237,$0), ($1f238,$0), ($1f239,$0),
    ($1f23a,$0), ($1f250,$0), ($1f251,$0), ($1f300,$0), ($1f301,$0), ($1f302,$0), ($1f303,$0), ($1f304,$0), ($1f305,$0), ($1f306,$0), ($1f307,$0), ($1f308,$0), ($1f309,$0), ($1f30a,$0), ($1f30b,$0), ($1f30c,$0), ($1f30d,$0), ($1f30e,$0), ($1f30f,$0), ($1f310,$0), ($1f311,$0), ($1f312,$0), ($1f313,$0), ($1f314,$0), ($1f315,$0), ($1f316,$0), ($1f317,$0), ($1f318,$0), ($1f319,$0), ($1f31a,$0), ($1f31b,$0), ($1f31c,$0), ($1f31d,$0), ($1f31e,$0), ($1f31f,$0), ($1f320,$0), ($1f321,$0), ($1f324,$0), ($1f325,$0), ($1f326,$0), ($1f327,$0), ($1f328,$0), ($1f329,$0), ($1f32a,$0), ($1f32b,$0), ($1f32c,$0), ($1f32d,$0), ($1f32e,$0), ($1f32f,$0), ($1f330,$0),
    ($1f331,$0), ($1f332,$0), ($1f333,$0), ($1f334,$0), ($1f335,$0), ($1f336,$0), ($1f337,$0), ($1f338,$0), ($1f339,$0), ($1f33a,$0), ($1f33b,$0), ($1f33c,$0), ($1f33d,$0), ($1f33e,$0), ($1f33f,$0), ($1f340,$0), ($1f341,$0), ($1f342,$0), ($1f343,$0), ($1f344,$0), ($1f345,$0), ($1f346,$0), ($1f347,$0), ($1f348,$0), ($1f349,$0), ($1f34a,$0), ($1f34b,$0), ($1f34c,$0), ($1f34d,$0), ($1f34e,$0), ($1f34f,$0), ($1f350,$0), ($1f351,$0), ($1f352,$0), ($1f353,$0), ($1f354,$0), ($1f355,$0), ($1f356,$0), ($1f357,$0), ($1f358,$0), ($1f359,$0), ($1f35a,$0), ($1f35b,$0), ($1f35c,$0), ($1f35d,$0), ($1f35e,$0), ($1f35f,$0), ($1f360,$0), ($1f361,$0), ($1f362,$0),
    ($1f363,$0), ($1f364,$0), ($1f365,$0), ($1f366,$0), ($1f367,$0), ($1f368,$0), ($1f369,$0), ($1f36a,$0), ($1f36b,$0), ($1f36c,$0), ($1f36d,$0), ($1f36e,$0), ($1f36f,$0), ($1f370,$0), ($1f371,$0), ($1f372,$0), ($1f373,$0), ($1f374,$0), ($1f375,$0), ($1f376,$0), ($1f377,$0), ($1f378,$0), ($1f379,$0), ($1f37a,$0), ($1f37b,$0), ($1f37c,$0), ($1f37d,$0), ($1f37e,$0), ($1f37f,$0), ($1f380,$0), ($1f381,$0), ($1f382,$0), ($1f383,$0), ($1f384,$0), ($1f385,$0), ($1f386,$0), ($1f387,$0), ($1f388,$0), ($1f389,$0), ($1f38a,$0), ($1f38b,$0), ($1f38c,$0), ($1f38d,$0), ($1f38e,$0), ($1f38f,$0), ($1f390,$0), ($1f391,$0), ($1f392,$0), ($1f393,$0), ($1f396,$0),
    ($1f397,$0), ($1f399,$0), ($1f39a,$0), ($1f39b,$0), ($1f39e,$0), ($1f39f,$0), ($1f3a0,$0), ($1f3a1,$0), ($1f3a2,$0), ($1f3a3,$0), ($1f3a4,$0), ($1f3a5,$0), ($1f3a6,$0), ($1f3a7,$0), ($1f3a8,$0), ($1f3a9,$0), ($1f3aa,$0), ($1f3ab,$0), ($1f3ac,$0), ($1f3ad,$0), ($1f3ae,$0), ($1f3af,$0), ($1f3b0,$0), ($1f3b1,$0), ($1f3b2,$0), ($1f3b3,$0), ($1f3b4,$0), ($1f3b5,$0), ($1f3b6,$0), ($1f3b7,$0), ($1f3b8,$0), ($1f3b9,$0), ($1f3ba,$0), ($1f3bb,$0), ($1f3bc,$0), ($1f3bd,$0), ($1f3be,$0), ($1f3bf,$0), ($1f3c0,$0), ($1f3c1,$0), ($1f3c2,$0), ($1f3c3,$0), ($1f3c4,$0), ($1f3c5,$0), ($1f3c6,$0), ($1f3c7,$0), ($1f3c8,$0), ($1f3c9,$0), ($1f3ca,$0), ($1f3cb,$0),
    ($1f3cc,$0), ($1f3cd,$0), ($1f3ce,$0), ($1f3cf,$0), ($1f3d0,$0), ($1f3d1,$0), ($1f3d2,$0), ($1f3d3,$0), ($1f3d4,$0), ($1f3d5,$0), ($1f3d6,$0), ($1f3d7,$0), ($1f3d8,$0), ($1f3d9,$0), ($1f3da,$0), ($1f3db,$0), ($1f3dc,$0), ($1f3dd,$0), ($1f3de,$0), ($1f3df,$0), ($1f3e0,$0), ($1f3e1,$0), ($1f3e2,$0), ($1f3e3,$0), ($1f3e4,$0), ($1f3e5,$0), ($1f3e6,$0), ($1f3e7,$0), ($1f3e8,$0), ($1f3e9,$0), ($1f3ea,$0), ($1f3eb,$0), ($1f3ec,$0), ($1f3ed,$0), ($1f3ee,$0), ($1f3ef,$0), ($1f3f0,$0), ($1f3f3,$0), ($1f3f4,$0), ($1f3f5,$0), ($1f3f7,$0), ($1f3f8,$0), ($1f3f9,$0), ($1f3fa,$0), ($1f400,$0), ($1f401,$0), ($1f402,$0), ($1f403,$0), ($1f404,$0), ($1f405,$0),
    ($1f406,$0), ($1f407,$0), ($1f408,$0), ($1f409,$0), ($1f40a,$0), ($1f40b,$0), ($1f40c,$0), ($1f40d,$0), ($1f40e,$0), ($1f40f,$0), ($1f410,$0), ($1f411,$0), ($1f412,$0), ($1f413,$0), ($1f414,$0), ($1f415,$0), ($1f416,$0), ($1f417,$0), ($1f418,$0), ($1f419,$0), ($1f41a,$0), ($1f41b,$0), ($1f41c,$0), ($1f41d,$0), ($1f41e,$0), ($1f41f,$0), ($1f420,$0), ($1f421,$0), ($1f422,$0), ($1f423,$0), ($1f424,$0), ($1f425,$0), ($1f426,$0), ($1f427,$0), ($1f428,$0), ($1f429,$0), ($1f42a,$0), ($1f42b,$0), ($1f42c,$0), ($1f42d,$0), ($1f42e,$0), ($1f42f,$0), ($1f430,$0), ($1f431,$0), ($1f432,$0), ($1f433,$0), ($1f434,$0), ($1f435,$0), ($1f436,$0), ($1f437,$0),
    ($1f438,$0), ($1f439,$0), ($1f43a,$0), ($1f43b,$0), ($1f43c,$0), ($1f43d,$0), ($1f43e,$0), ($1f43f,$0), ($1f440,$0), ($1f441,$0), ($1f441,$1f5e8), ($1f442,$0), ($1f443,$0), ($1f444,$0), ($1f445,$0), ($1f446,$0), ($1f447,$0), ($1f448,$0), ($1f449,$0), ($1f44a,$0), ($1f44b,$0), ($1f44c,$0), ($1f44d,$0), ($1f44e,$0), ($1f44f,$0), ($1f450,$0), ($1f451,$0), ($1f452,$0), ($1f453,$0), ($1f454,$0), ($1f455,$0), ($1f456,$0), ($1f457,$0), ($1f458,$0), ($1f459,$0), ($1f45a,$0), ($1f45b,$0), ($1f45c,$0), ($1f45d,$0), ($1f45e,$0), ($1f45f,$0), ($1f460,$0), ($1f461,$0), ($1f462,$0), ($1f463,$0), ($1f464,$0), ($1f465,$0), ($1f466,$0), ($1f467,$0), ($1f468,$0),
    ($1f469,$0), ($1f46a,$0), ($1f46b,$0), ($1f46c,$0), ($1f46d,$0), ($1f46e,$0), ($1f46f,$0), ($1f470,$0), ($1f471,$0), ($1f472,$0), ($1f473,$0), ($1f474,$0), ($1f475,$0), ($1f476,$0), ($1f477,$0), ($1f478,$0), ($1f479,$0), ($1f47a,$0), ($1f47b,$0), ($1f47c,$0), ($1f47d,$0), ($1f47e,$0), ($1f47f,$0), ($1f480,$0), ($1f481,$0), ($1f482,$0), ($1f483,$0), ($1f484,$0), ($1f485,$0), ($1f486,$0), ($1f487,$0), ($1f488,$0), ($1f489,$0), ($1f48a,$0), ($1f48b,$0), ($1f48c,$0), ($1f48d,$0), ($1f48e,$0), ($1f48f,$0), ($1f490,$0), ($1f491,$0), ($1f492,$0), ($1f493,$0), ($1f494,$0), ($1f495,$0), ($1f496,$0), ($1f497,$0), ($1f498,$0), ($1f499,$0), ($1f49a,$0),
    ($1f49b,$0), ($1f49c,$0), ($1f49d,$0), ($1f49e,$0), ($1f49f,$0), ($1f4a0,$0), ($1f4a1,$0), ($1f4a2,$0), ($1f4a3,$0), ($1f4a4,$0), ($1f4a5,$0), ($1f4a6,$0), ($1f4a7,$0), ($1f4a8,$0), ($1f4a9,$0), ($1f4aa,$0), ($1f4ab,$0), ($1f4ac,$0), ($1f4ad,$0), ($1f4ae,$0), ($1f4af,$0), ($1f4b0,$0), ($1f4b1,$0), ($1f4b2,$0), ($1f4b3,$0), ($1f4b4,$0), ($1f4b5,$0), ($1f4b6,$0), ($1f4b7,$0), ($1f4b8,$0), ($1f4b9,$0), ($1f4ba,$0), ($1f4bb,$0), ($1f4bc,$0), ($1f4bd,$0), ($1f4be,$0), ($1f4bf,$0), ($1f4c0,$0), ($1f4c1,$0), ($1f4c2,$0), ($1f4c3,$0), ($1f4c4,$0), ($1f4c5,$0), ($1f4c6,$0), ($1f4c7,$0), ($1f4c8,$0), ($1f4c9,$0), ($1f4ca,$0), ($1f4cb,$0), ($1f4cc,$0),
    ($1f4cd,$0), ($1f4ce,$0), ($1f4cf,$0), ($1f4d0,$0), ($1f4d1,$0), ($1f4d2,$0), ($1f4d3,$0), ($1f4d4,$0), ($1f4d5,$0), ($1f4d6,$0), ($1f4d7,$0), ($1f4d8,$0), ($1f4d9,$0), ($1f4da,$0), ($1f4db,$0), ($1f4dc,$0), ($1f4dd,$0), ($1f4de,$0), ($1f4df,$0), ($1f4e0,$0), ($1f4e1,$0), ($1f4e2,$0), ($1f4e3,$0), ($1f4e4,$0), ($1f4e5,$0), ($1f4e6,$0), ($1f4e7,$0), ($1f4e8,$0), ($1f4e9,$0), ($1f4ea,$0), ($1f4eb,$0), ($1f4ec,$0), ($1f4ed,$0), ($1f4ee,$0), ($1f4ef,$0), ($1f4f0,$0), ($1f4f1,$0), ($1f4f2,$0), ($1f4f3,$0), ($1f4f4,$0), ($1f4f5,$0), ($1f4f6,$0), ($1f4f7,$0), ($1f4f8,$0), ($1f4f9,$0), ($1f4fa,$0), ($1f4fb,$0), ($1f4fc,$0), ($1f4fd,$0), ($1f4ff,$0),
    ($1f500,$0), ($1f501,$0), ($1f502,$0), ($1f503,$0), ($1f504,$0), ($1f505,$0), ($1f506,$0), ($1f507,$0), ($1f508,$0), ($1f509,$0), ($1f50a,$0), ($1f50b,$0), ($1f50c,$0), ($1f50d,$0), ($1f50e,$0), ($1f50f,$0), ($1f510,$0), ($1f511,$0), ($1f512,$0), ($1f513,$0), ($1f514,$0), ($1f515,$0), ($1f516,$0), ($1f517,$0), ($1f518,$0), ($1f519,$0), ($1f51a,$0), ($1f51b,$0), ($1f51c,$0), ($1f51d,$0), ($1f51e,$0), ($1f51f,$0), ($1f520,$0), ($1f521,$0), ($1f522,$0), ($1f523,$0), ($1f524,$0), ($1f525,$0), ($1f526,$0), ($1f527,$0), ($1f528,$0), ($1f529,$0), ($1f52a,$0), ($1f52b,$0), ($1f52c,$0), ($1f52d,$0), ($1f52e,$0), ($1f52f,$0), ($1f530,$0), ($1f531,$0),
    ($1f532,$0), ($1f533,$0), ($1f534,$0), ($1f535,$0), ($1f536,$0), ($1f537,$0), ($1f538,$0), ($1f539,$0), ($1f53a,$0), ($1f53b,$0), ($1f53c,$0), ($1f53d,$0), ($1f549,$0), ($1f54a,$0), ($1f54b,$0), ($1f54c,$0), ($1f54d,$0), ($1f54e,$0), ($1f550,$0), ($1f551,$0), ($1f552,$0), ($1f553,$0), ($1f554,$0), ($1f555,$0), ($1f556,$0), ($1f557,$0), ($1f558,$0), ($1f559,$0), ($1f55a,$0), ($1f55b,$0), ($1f55c,$0), ($1f55d,$0), ($1f55e,$0), ($1f55f,$0), ($1f560,$0), ($1f561,$0), ($1f562,$0), ($1f563,$0), ($1f564,$0), ($1f565,$0), ($1f566,$0), ($1f567,$0), ($1f56f,$0), ($1f570,$0), ($1f573,$0), ($1f574,$0), ($1f575,$0), ($1f576,$0), ($1f577,$0), ($1f578,$0),
    ($1f579,$0), ($1f587,$0), ($1f58a,$0), ($1f58b,$0), ($1f58c,$0), ($1f58d,$0), ($1f590,$0), ($1f595,$0), ($1f596,$0), ($1f5a5,$0), ($1f5a8,$0), ($1f5b1,$0), ($1f5b2,$0), ($1f5bc,$0), ($1f5c2,$0), ($1f5c3,$0), ($1f5c4,$0), ($1f5d1,$0), ($1f5d2,$0), ($1f5d3,$0), ($1f5dc,$0), ($1f5dd,$0), ($1f5de,$0), ($1f5e1,$0), ($1f5e3,$0), ($1f5ef,$0), ($1f5f3,$0), ($1f5fa,$0), ($1f5fb,$0), ($1f5fc,$0), ($1f5fd,$0), ($1f5fe,$0), ($1f5ff,$0), ($1f600,$0), ($1f601,$0), ($1f602,$0), ($1f603,$0), ($1f604,$0), ($1f605,$0), ($1f606,$0), ($1f607,$0), ($1f608,$0), ($1f609,$0), ($1f60a,$0), ($1f60b,$0), ($1f60c,$0), ($1f60d,$0), ($1f60e,$0), ($1f60f,$0), ($1f610,$0),
    ($1f611,$0), ($1f612,$0), ($1f613,$0), ($1f614,$0), ($1f615,$0), ($1f616,$0), ($1f617,$0), ($1f618,$0), ($1f619,$0), ($1f61a,$0), ($1f61b,$0), ($1f61c,$0), ($1f61d,$0), ($1f61e,$0), ($1f61f,$0), ($1f620,$0), ($1f621,$0), ($1f622,$0), ($1f623,$0), ($1f624,$0), ($1f625,$0), ($1f626,$0), ($1f627,$0), ($1f628,$0), ($1f629,$0), ($1f62a,$0), ($1f62b,$0), ($1f62c,$0), ($1f62d,$0), ($1f62e,$0), ($1f62f,$0), ($1f630,$0), ($1f631,$0), ($1f632,$0), ($1f633,$0), ($1f634,$0), ($1f635,$0), ($1f636,$0), ($1f637,$0), ($1f638,$0), ($1f639,$0), ($1f63a,$0), ($1f63b,$0), ($1f63c,$0), ($1f63d,$0), ($1f63e,$0), ($1f63f,$0), ($1f640,$0), ($1f641,$0), ($1f642,$0),
    ($1f643,$0), ($1f644,$0), ($1f645,$0), ($1f646,$0), ($1f647,$0), ($1f648,$0), ($1f649,$0), ($1f64a,$0), ($1f64b,$0), ($1f64c,$0), ($1f64d,$0), ($1f64e,$0), ($1f64f,$0), ($1f680,$0), ($1f681,$0), ($1f682,$0), ($1f683,$0), ($1f684,$0), ($1f685,$0), ($1f686,$0), ($1f687,$0), ($1f688,$0), ($1f689,$0), ($1f68a,$0), ($1f68b,$0), ($1f68c,$0), ($1f68d,$0), ($1f68e,$0), ($1f68f,$0), ($1f690,$0), ($1f691,$0), ($1f692,$0), ($1f693,$0), ($1f694,$0), ($1f695,$0), ($1f696,$0), ($1f697,$0), ($1f698,$0), ($1f699,$0), ($1f69a,$0), ($1f69b,$0), ($1f69c,$0), ($1f69d,$0), ($1f69e,$0), ($1f69f,$0), ($1f6a0,$0), ($1f6a1,$0), ($1f6a2,$0), ($1f6a3,$0), ($1f6a4,$0),
    ($1f6a5,$0), ($1f6a6,$0), ($1f6a7,$0), ($1f6a8,$0), ($1f6a9,$0), ($1f6aa,$0), ($1f6ab,$0), ($1f6ac,$0), ($1f6ad,$0), ($1f6ae,$0), ($1f6af,$0), ($1f6b0,$0), ($1f6b1,$0), ($1f6b2,$0), ($1f6b3,$0), ($1f6b4,$0), ($1f6b5,$0), ($1f6b6,$0), ($1f6b7,$0), ($1f6b8,$0), ($1f6b9,$0), ($1f6ba,$0), ($1f6bb,$0), ($1f6bc,$0), ($1f6bd,$0), ($1f6be,$0), ($1f6bf,$0), ($1f6c0,$0), ($1f6c1,$0), ($1f6c2,$0), ($1f6c3,$0), ($1f6c4,$0), ($1f6c5,$0), ($1f6cb,$0), ($1f6cc,$0), ($1f6cd,$0), ($1f6ce,$0), ($1f6cf,$0), ($1f6d0,$0), ($1f6e0,$0), ($1f6e1,$0), ($1f6e2,$0), ($1f6e3,$0), ($1f6e4,$0), ($1f6e5,$0), ($1f6e9,$0), ($1f6eb,$0), ($1f6ec,$0), ($1f6f0,$0), ($1f6f3,$0),
    ($1f910,$0), ($1f911,$0), ($1f912,$0), ($1f913,$0), ($1f914,$0), ($1f915,$0), ($1f916,$0), ($1f917,$0), ($1f918,$0), ($1f980,$0), ($1f981,$0), ($1f982,$0), ($1f983,$0), ($1f984,$0), ($1f9c0,$0), ($203c,$0), ($2049,$0), ($2122,$0), ($2139,$0), ($2194,$0), ($2195,$0), ($2196,$0), ($2197,$0), ($2198,$0), ($2199,$0), ($21a9,$0), ($21aa,$0), ($231a,$0), ($231b,$0), ($2328,$0), ($23e9,$0), ($23ea,$0), ($23eb,$0), ($23ec,$0), ($23ed,$0), ($23ee,$0), ($23ef,$0), ($23f0,$0), ($23f1,$0), ($23f2,$0), ($23f3,$0), ($23f8,$0), ($23f9,$0), ($23fa,$0), ($24c2,$0), ($25aa,$0), ($25ab,$0), ($25b6,$0), ($25c0,$0), ($25fb,$0),
    ($25fc,$0), ($25fd,$0), ($25fe,$0), ($2600,$0), ($2601,$0), ($2602,$0), ($2603,$0), ($2604,$0), ($260e,$0), ($2611,$0), ($2614,$0), ($2615,$0), ($2618,$0), ($261d,$0), ($2620,$0), ($2622,$0), ($2623,$0), ($2626,$0), ($262a,$0), ($262e,$0), ($262f,$0), ($2638,$0), ($2639,$0), ($263a,$0), ($2648,$0), ($2649,$0), ($264a,$0), ($264b,$0), ($264c,$0), ($264d,$0), ($264e,$0), ($264f,$0), ($2650,$0), ($2651,$0), ($2652,$0), ($2653,$0), ($2660,$0), ($2663,$0), ($2665,$0), ($2666,$0), ($2668,$0), ($267b,$0), ($267f,$0), ($2692,$0), ($2693,$0), ($2694,$0), ($2696,$0), ($2697,$0), ($2699,$0), ($269b,$0),
    ($269c,$0), ($26a0,$0), ($26a1,$0), ($26aa,$0), ($26ab,$0), ($26b0,$0), ($26b1,$0), ($26bd,$0), ($26be,$0), ($26c4,$0), ($26c5,$0), ($26c8,$0), ($26ce,$0), ($26cf,$0), ($26d1,$0), ($26d3,$0), ($26d4,$0), ($26e9,$0), ($26ea,$0), ($26f0,$0), ($26f1,$0), ($26f2,$0), ($26f3,$0), ($26f4,$0), ($26f5,$0), ($26f7,$0), ($26f8,$0), ($26f9,$0), ($26fa,$0), ($26fd,$0), ($2702,$0), ($2705,$0), ($2708,$0), ($2709,$0), ($270a,$0), ($270b,$0), ($270c,$0), ($270d,$0), ($270f,$0), ($2712,$0), ($2714,$0), ($2716,$0), ($271d,$0), ($2721,$0), ($2728,$0), ($2733,$0), ($2734,$0), ($2744,$0), ($2747,$0), ($274c,$0),
    ($274e,$0), ($2753,$0), ($2754,$0), ($2755,$0), ($2757,$0), ($2763,$0), ($2764,$0), ($2795,$0), ($2796,$0), ($2797,$0), ($27a1,$0), ($27b0,$0), ($27bf,$0), ($2934,$0), ($2935,$0), ($2b05,$0), ($2b06,$0), ($2b07,$0), ($2b1b,$0), ($2b1c,$0), ($2b50,$0), ($2b55,$0), ($3030,$0), ($303d,$0), ($3297,$0), ($3299,$0)
  );
  emojiExtHints: array [1..emojiContentsCount] of String = ('People', 'Nature', 'Foods', 'Activity', 'Travel', 'Objects', 'Symbols', 'Flags');

{
  emojiContents: array [1..8] of Array of Integer = ((933, 977, 934, 935, 936, 937, 938, 939, 940, 942, 943, 999, 1000, 1173, 944, 945, 946, 957, 956, 958, 959, 961, 962, 960, 1101, 1103, 947, 1107, 948, 987, 949, 950, 951, 1001, 1104, 984, 963, 964, 965, 966, 953, 954, 998, 1172, 968, 955, 976, 974, 969, 979, 982, 973, 981, 980, 971, 972, 967, 970, 975, 952, 978, 986, 983, 1100, 988, 1102, 1105, 985, 709, 714, 941, 672, 666, 667, 673, 668, 670, 1106, 991, 989, 990, 992, 993, 994, 997, 996, 995, 1009, 624, 620, 622, 623, 619, 1234, 1236, 621, 1235, 625, 715, 1012, 1163, 615, 616, 617, 618, 907, 906, 1108, 908, 1237, 678, 613, 614, 611, 612, 609, 608, 645, 646, 924, 663, 647, 648, 649, 650, 658, 661, 662, 659, 660, 655, 664, 675, 896, 434, 669, 665, 657, 1067, 491, 676, 656, 652, 653, 654, 1004, 674, 1002, 1003, 1008, 1011, 1010, 680, 679, 690, 688, 651, 635, 630, 631, 629, 632, 634, 633, 677, 684, 644, 641, 642, 643, 639, 640, 627, 465, 1214, 448, 626, 447, 638, 636, 637, 733, 628, 897, 686, 305),
       (598, 593, 589, 601, 592, 603, 604, 584, 591, 1110, 590, 599, 605, 600, 569, 597, 1005, 1006, 1007, 562, 564, 583, 582, 580, 579, 581, 602, 567, 596, 1113, 573, 571, 556, 574, 572, 898, 1111, 1109, 557, 578, 576, 575, 577, 588, 595, 555, 554, 550, 549, 547, 546, 548, 586, 587, 568, 560, 559, 561, 558, 566, 544, 545, 563, 1112, 863, 565, 585, 552, 551, 607, 606, 553, 594, 354, 433, 351, 352, 353, 350, 364, 1162, 365, 442, 440, 368, 367, 366, 363, 359, 360, 358, 356, 361, 357, 689, 369, 349, 432, 570, 899, 317, 316, 318, 324, 325, 326, 327, 320, 321, 322, 323, 329, 332, 330, 331, 333, 328, 1270, 334, 716, 1244, 1157, 1153, 337, 1210, 338, 339, 1154, 340, 1211, 342, 1202, 837, 710, 1247, 341, 1156, 1209, 345, 713, 343, 344, 1155, 1160, 712, 711, 313),
       TArray<Integer>.Create(380, 379, 381, 375, 376, 377, 374, 372, 384, 373, 383, 382, 378, 370, 371, 355, 362, 397, 412, 395, 1114, 388, 387, 401, 416, 385, 396, 346, 386, 394, 347, 348, 393, 415, 402, 400, 414, 392, 390, 391, 389, 399, 398, 404, 405, 403, 413, 431, 411, 409, 410, 408, 428, 406, 407, 423, 424, 420, 421, 422, 427, 419, 418, 1161, 425, 417, 426),
       TArray<Integer>.Create(1207, 488, 496, 1208, 486, 504, 497, 473, 1222, 500, 507, 541, 506, 505, 503, 487, 1225, 490, 1226, 542, 459, 1048, 498, 492, 1077, 1227, 499, 1065, 1066, 495, 895, 494, 485, 493, 449, 450, 539, 467, 455, 469, 464, 466, 460, 463, 484, 481, 479, 482, 480, 483, 468, 470, 671, 471, 474, 472, 475),
       TArray<Integer>.Create(1036, 1034, 1038, 1025, 1027, 502, 1032, 1030, 1031, 1029, 1039, 1040, 1041, 501, 1063, 1053, 1033, 1026, 1037, 1035, 1046, 1045, 1044, 1016, 1024, 1042, 1017, 1018, 1021, 1043, 1015, 1019, 1020, 1023, 1022, 1014, 1095, 1232, 1096, 1097, 1224, 1094, 1049, 1223, 1099, 1013, 1098, 731, 1194, 1052, 1229, 1028, 1051, 1050, 489, 1047, 457, 458, 456, 511, 304, 929, 533, 1221, 446, 1219, 508, 928, 314, 931, 509, 1228, 518, 1092, 1093, 308, 307, 516, 510, 517, 310, 309, 513, 306, 312, 315, 335, 436, 435, 311, 512, 536, 535, 519, 930, 520, 521, 514, 522, 532, 523, 524, 525, 526, 528, 530, 531, 529, 691, 515, 1218, 865, 866, 864, 1217),
       TArray<Integer>.Create(1127, 786, 787, 732, 1129, 909, 910, 911, 912, 900, 920, 734, 735, 736, 737, 797, 792, 793, 794, 461, 798, 454, 767, 1158, 768, 769, 795, 796, 451, 452, 453, 1138, 1139, 1137, 893, 1140, 1128, 770, 811, 812, 706, 838, 892, 917, 1091, 729, 726, 725, 727, 728, 721, 724, 687, 1196, 839, 840, 1193, 1089, 1213, 841, 1198, 1215, 843, 708, 842, 923, 1195, 1090, 1057, 1164, 1205, 1206, 543, 846, 799, 681, 1197, 845, 844, 894, 683, 682, 336, 540, 822, 1074, 1076, 1078, 817, 921, 1083, 1084, 1087, 1055, 1086, 913, 927, 1220, 932, 1085, 437, 444, 429, 430, 439, 438, 443, 445, 441, 534, 1233, 778, 777, 776, 685, 783, 779, 780, 781, 782, 775, 784, 774, 773, 765, 740, 754, 747, 745, 746, 741, 742, 743, 919, 744, 915, 926, 916, 748, 918, 738, 739, 914, 922, 785, 756, 758, 760, 761, 762, 757, 755, 763, 759, 823, 751, 901, 1230, 753, 752, 749, 750, 1054, 537, 538, 816, 818, 819, 815, 902, 903, 1239, 766, 1238, 905, 904, 813, 814),
       TArray<Integer>.Create(1256, 700, 699, 698, 701, 693, 1255, 694, 703, 692, 696, 695, 697, 702, 704, 1169, 1242, 1168, 862, 1171, 1243, 847, 867, 1170, 1167, 1088, 1212, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185, 24, 1199, 293, 299, 1165, 1166, 789, 788, 296, 290, 298, 300, 297, 1246, 30, 302, 719, 301, 1275, 1274, 294, 295, 292, 16, 17, 20, 21, 18, 28, 1216, 764, 1056, 1249, 1271, 707, 1190, 1068, 1060, 1064, 1062, 830, 790, 1254, 1253, 1251, 1252, 1115, 1116, 720, 805, 806, 849, 1200, 1273, 1201, 1069, 848, 1191, 291, 730, 1248, 1245, 1250, 1231, 705, 303, 1262, 319, 1144, 527, 289, 1079, 1080, 1081, 1082, 1192, 1058, 1075, 19, 1061, 1070, 1071, 1073, 1072, 1059, 462, 791, 288, 26, 27, 29, 22, 25, 23, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 831, 834, 1147, 1141, 1136, 1142, 1143, 1134, 1135, 1130, 1131, 800, 801, 802, 1148, 860, 861, 1132, 1133, 1260, 1265, 1266, 1267, 1122, 1123, 1124, 1121, 1120, 1119, 804, 1126, 1125, 1263, 1264, 0, 1, 1118, 836,
                                              833, 832, 835, 477, 478, 1272, 1261, 1240, 803, 1257, 1258, 1259, 1241, 723, 722, 12, 13, 1117, 826, 825, 827, 829, 828, 1159, 824, 1203, 1204, 852, 853, 856, 857, 854, 855, 858, 1145, 1146, 1268, 1269, 859, 1150, 1149, 1152, 1151, 850, 851, 808, 809, 810, 807, 772, 771, 820, 821, 15, 14, 1186, 1187, 1188, 1189, 476, 718, 925, 717, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 610),
       TArray<Integer>.Create(31, 34, 37, 95, 32, 39, 36, 35, 41, 38, 45, 44, 43, 47, 63, 54, 50, 49, 67, 51, 68, 56, 58, 64, 60, 48, 66, 62, 59, 53, 52, 55, 84, 153, 78, 69, 160, 72, 252, 77, 79, 80, 155, 73, 71, 82, 133, 83, 87, 88, 92, 91, 93, 94, 97, 99, 246, 123, 101, 98, 103, 107, 109, 106, 105, 110, 211, 111, 120, 114, 89, 117, 118, 124, 119, 113, 127, 126, 121, 128, 129, 134, 132, 130, 135, 145, 141, 137, 144, 143, 138, 139, 146, 75, 148, 150, 147, 149, 161, 151, 154, 282, 159, 152, 162, 171, 163, 168, 167, 172, 165, 169, 170, 184, 180, 178, 192, 194, 191, 181, 189, 179, 187, 190, 193, 108, 175, 174, 183, 176, 188, 173, 195, 182, 196, 205, 204, 202, 197, 207, 201, 198, 200, 206, 157, 203, 208, 214, 221, 219, 209, 212, 222, 210, 213, 215, 220, 218, 223, 225, 227, 228, 235, 156, 164, 274, 281, 240, 245, 229, 241, 226, 231, 239, 234, 238, 236, 230, 242, 285, 158, 102, 166, 232, 243, 249, 233, 74, 248, 265, 256, 266, 255, 258, 254, 261, 263, 260, 262, 259, 264, 268, 267, 33,
                                              112, 270, 277, 271, 272, 279, 273, 275, 278, 280, 100, 283, 286, 287, 224, 46, 250, 142, 61, 86, 70, 116, 140, 284, 199, 217, 57, 216, 125, 257, 65, 131, 237, 269, 136, 96, 81, 90, 42, 40, 276, 76, 85, 104, 115, 253, 122, 186, 185, 247, 244, 251, 177));
}
var
  singles: array of word;

{
const
  singles: array [0..163] of word = ($00A9, $00AE, $203C, $2049, $2122, $2139, $2194, $2195, $2196, $2197, $2198, $2199,
  $21A9, $21AA, $231A, $231B, $2328, $23CF, $23E9, $23EA, $23EB, $23EC, $23ED, $23EE, $23EF, $23F0, $23F1, $23F2, $23F3,
  $23F8, $23F9, $23FA, $24C2, $25AA, $25AB, $25B6, $25C0, $25FB, $25FC, $25FD, $25FE, $2600, $2601, $2602, $2603, $2604,
  $260E, $2611, $2614, $2615, $2618, $261D, $2620, $2622, $2623, $2626, $262A, $262E, $262F, $2638, $2639, $263A, $2648,
  $2649, $264A, $264B, $264C, $264D, $264E, $264F, $2650, $2651, $2652, $2653, $2660, $2663, $2665, $2666, $2668, $267B,
  $267F, $2692, $2693, $2694, $2696, $2697, $2699, $269B, $269C, $26A0, $26A1, $26AA, $26AB, $26B0, $26B1, $26BD, $26BE,
  $26C4, $26C5, $26C8, $26CE, $26CF, $26D1, $26D3, $26D4, $26E9, $26EA, $26F0, $26F1, $26F2, $26F3, $26F4, $26F5, $26F7,
  $26F8, $26F9, $26FA, $26FD, $2702, $2705, $2708, $2709, $270A, $270B, $270C, $270D, $270F, $2712, $2714, $2716, $271D,
  $2721, $2728, $2733, $2734, $2744, $2747, $274C, $274E, $2753, $2754, $2755, $2757, $2763, $2764, $2795, $2796, $2797,
  $27A1, $27B0, $27BF, $2934, $2935, $2B05, $2B06, $2B07, $2B1B, $2B1C, $2B50, $2B55, $3030, $303D, $3297, $3299);
}

  function GetEmojiStr(num: Integer): String;
  function GetEmojiPicName(num: Integer): TPicName;
  function GetEmojiCont(num: Integer): TEmojiContArr;
  function EmojiListTryGetValue(const e: String; var p: TPicName): Boolean;

implementation
uses
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  Generics.Collections,
  {$ELSE USE_MORMOT_COLLECTIONS}
  mormot.core.base,
  mormot.core.collections,
  {$ENDIF USE_MORMOT_COLLECTIONS}
  System.Character, SysUtils, Math,
  RDUtils;

type
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  TEmojiContent = TDictionary<Integer, TEmojiContArr>;
  TEmojiKey: TPair<Cardinal, Cardinal>;
  TEmojis = TDictionary<TEmojiKey, Integer>;
  TEmojiList = TDictionary<String, TPicName>;
  {$ELSE USE_MORMOT_COLLECTIONS}
  TEmojiContent = IKeyValue<Integer, TEmojiContArr>;
  TEmojiKey = UInt64;
  TEmojis = IKeyValue<TEmojiKey, Integer>;
  TEmojiList = IKeyValue<String, TPicName>;
  {$ENDIF USE_MORMOT_COLLECTIONS}
var
  emojiContents: TEmojiContent;
  emojis: TEmojis;
  EmojiList: TEmojiList;

function GetEmojiStr(num: Integer): String;
begin
  Result := TCharacter.ConvertFromUtf32(emojiCodePoints[num][1]);
  if not (emojiCodePoints[num][2] = 0) then
    Result := Result + TCharacter.ConvertFromUtf32(emojiCodePoints[num][2]);
end;

function GetEmojiPicName(num: Integer): TPicName;
//var
//  cp: String;
begin
{
  cp := TCharacter.ConvertFromUtf32(emojiCodePoints[num][1]);
  if not (emojiCodePoints[num][2] = 0) then
    cp := cp + TCharacter.ConvertFromUtf32(emojiCodePoints[num][2]);
  Result := str2hex( StrToUTF8(cp));
}
  Result := IntToStrA(num);
end;

function GetEmojiCont(num: Integer): TEmojiContArr;
begin
  Result := emojiContents[num];
end;

function EmojiListTryGetValue(const e: String; var p: TPicName): Boolean;
begin
  Result := EmojiList.TryGetValue(e, p);
end;

var
  i: Integer;
  key: TEmojiKey;
initialization

  {$IFNDEF USE_MORMOT_COLLECTIONS}
  emojiContents := TEmojiContent.Create;
  {$ELSE USE_MORMOT_COLLECTIONS}
//  emojiContents := Collections.NewKeyValue<Integer, TEmojiContArr>;
  emojiContents := Collections.NewPlainKeyValue<Integer, TEmojiContArr>;
  {$ENDIF USE_MORMOT_COLLECTIONS}

  emojiContents.Add(1, TEmojiContArr.Create(933, 977, 934, 935, 936, 937, 938, 939, 940, 942, 943, 999, 1000, 1173, 944, 945, 946, 957, 956, 958, 959, 961, 962, 960, 1101, 1103, 947, 1107, 948, 987, 949, 950, 951, 1001, 1104, 984, 963, 964, 965, 966, 953, 954, 998, 1172, 968, 955, 976, 974, 969, 979, 982, 973, 981, 980, 971, 972, 967, 970, 975, 952, 978, 986, 983, 1100, 988, 1102, 1105, 985, 709, 714, 941, 672, 666, 667, 673, 668, 670, 1106, 991, 989, 990, 992, 993, 994, 997, 996, 995, 1009, 624, 620, 622, 623, 619, 1234, 1236, 621, 1235, 625, 715, 1012, 1163, 615, 616, 617, 618, 907, 906, 1108, 908, 1237, 678, 613, 614, 611, 612, 609, 608, 645, 646, 924, 663, 647, 648, 649, 650, 658, 661, 662, 659, 660, 655, 664, 675, 896, 434, 669, 665, 657, 1067, 491, 676, 656, 652, 653, 654, 1004, 674, 1002, 1003, 1008, 1011, 1010, 680, 679, 690, 688, 651, 635, 630, 631, 629, 632, 634, 633, 677, 684, 644, 641, 642, 643, 639, 640, 627, 465, 1214, 448, 626, 447, 638, 636, 637, 733, 628, 897, 686, 305));
  emojiContents.Add(2, TEmojiContArr.Create(598, 593, 589, 601, 592, 603, 604, 584, 591, 1110, 590, 599, 605, 600, 569, 597, 1005, 1006, 1007, 562, 564, 583, 582, 580, 579, 581, 602, 567, 596, 1113, 573, 571, 556, 574, 572, 898, 1111, 1109, 557, 578, 576, 575, 577, 588, 595, 555, 554, 550, 549, 547, 546, 548, 586, 587, 568, 560, 559, 561, 558, 566, 544, 545, 563, 1112, 863, 565, 585, 552, 551, 607, 606, 553, 594, 354, 433, 351, 352, 353, 350, 364, 1162, 365, 442, 440, 368, 367, 366, 363, 359, 360, 358, 356, 361, 357, 689, 369, 349, 432, 570, 899, 317, 316, 318, 324, 325, 326, 327, 320, 321, 322, 323, 329, 332, 330, 331, 333, 328, 1270, 334, 716, 1244, 1157, 1153, 337, 1210, 338, 339, 1154, 340, 1211, 342, 1202, 837, 710, 1247, 341, 1156, 1209, 345, 713, 343, 344, 1155, 1160, 712, 711, 313));
  emojiContents.Add(3, TArray<Integer>.Create(380, 379, 381, 375, 376, 377, 374, 372, 384, 373, 383, 382, 378, 370, 371, 355, 362, 397, 412, 395, 1114, 388, 387, 401, 416, 385, 396, 346, 386, 394, 347, 348, 393, 415, 402, 400, 414, 392, 390, 391, 389, 399, 398, 404, 405, 403, 413, 431, 411, 409, 410, 408, 428, 406, 407, 423, 424, 420, 421, 422, 427, 419, 418, 1161, 425, 417, 426));
  emojiContents.Add(4, TArray<Integer>.Create(1207, 488, 496, 1208, 486, 504, 497, 473, 1222, 500, 507, 541, 506, 505, 503, 487, 1225, 490, 1226, 542, 459, 1048, 498, 492, 1077, 1227, 499, 1065, 1066, 495, 895, 494, 485, 493, 449, 450, 539, 467, 455, 469, 464, 466, 460, 463, 484, 481, 479, 482, 480, 483, 468, 470, 671, 471, 474, 472, 475));
  emojiContents.Add(5, TArray<Integer>.Create(1036, 1034, 1038, 1025, 1027, 502, 1032, 1030, 1031, 1029, 1039, 1040, 1041, 501, 1063, 1053, 1033, 1026, 1037, 1035, 1046, 1045, 1044, 1016, 1024, 1042, 1017, 1018, 1021, 1043, 1015, 1019, 1020, 1023, 1022, 1014, 1095, 1232, 1096, 1097, 1224, 1094, 1049, 1223, 1099, 1013, 1098, 731, 1194, 1052, 1229, 1028, 1051, 1050, 489, 1047, 457, 458, 456, 511, 304, 929, 533, 1221, 446, 1219, 508, 928, 314, 931, 509, 1228, 518, 1092, 1093, 308, 307, 516, 510, 517, 310, 309, 513, 306, 312, 315, 335, 436, 435, 311, 512, 536, 535, 519, 930, 520, 521, 514, 522, 532, 523, 524, 525, 526, 528, 530, 531, 529, 691, 515, 1218, 865, 866, 864, 1217));
  emojiContents.Add(6, TArray<Integer>.Create(1127, 786, 787, 732, 1129, 909, 910, 911, 912, 900, 920, 734, 735, 736, 737, 797, 792, 793, 794, 461, 798, 454, 767, 1158, 768, 769, 795, 796, 451, 452, 453, 1138, 1139, 1137, 893, 1140, 1128, 770, 811, 812, 706, 838, 892, 917, 1091, 729, 726, 725, 727, 728, 721, 724, 687, 1196, 839, 840, 1193, 1089, 1213, 841, 1198, 1215, 843, 708, 842, 923, 1195, 1090, 1057, 1164, 1205, 1206, 543, 846, 799, 681, 1197, 845, 844, 894, 683, 682, 336, 540, 822, 1074, 1076, 1078, 817, 921, 1083, 1084, 1087, 1055, 1086, 913, 927, 1220, 932, 1085, 437, 444, 429, 430, 439, 438, 443, 445, 441, 534, 1233, 778, 777, 776, 685, 783, 779, 780, 781, 782, 775, 784, 774, 773, 765, 740, 754, 747, 745, 746, 741, 742, 743, 919, 744, 915, 926, 916, 748, 918, 738, 739, 914, 922, 785, 756, 758, 760, 761, 762, 757, 755, 763, 759, 823, 751, 901, 1230, 753, 752, 749, 750, 1054, 537, 538, 816, 818, 819, 815, 902, 903, 1239, 766, 1238, 905, 904, 813, 814));
  emojiContents.Add(7, TArray<Integer>.Create(1256, 700, 699, 698, 701, 693, 1255, 694, 703, 692, 696, 695, 697, 702, 704, 1169, 1242, 1168, 862, 1171, 1243, 847, 867, 1170, 1167, 1088, 1212, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185, 24, 1199, 293, 299, 1165, 1166, 789, 788, 296, 290, 298, 300, 297, 1246, 30, 302, 719, 301, 1275, 1274, 294, 295, 292, 16, 17, 20, 21, 18, 28, 1216, 764, 1056, 1249, 1271, 707, 1190, 1068, 1060, 1064, 1062, 830, 790, 1254, 1253, 1251, 1252, 1115, 1116, 720, 805, 806, 849, 1200, 1273, 1201, 1069, 848, 1191, 291, 730, 1248, 1245, 1250, 1231, 705, 303, 1262, 319, 1144, 527, 289, 1079, 1080, 1081, 1082, 1192, 1058, 1075, 19, 1061, 1070, 1071, 1073, 1072, 1059, 462, 791, 288, 26, 27, 29, 22, 25, 23, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 831, 834, 1147, 1141, 1136, 1142, 1143, 1134, 1135, 1130, 1131, 800, 801, 802, 1148, 860, 861, 1132, 1133, 1260, 1265, 1266, 1267, 1122, 1123, 1124, 1121, 1120, 1119, 804, 1126, 1125, 1263, 1264, 0, 1, 1118, 836,
                                              833, 832, 835, 477, 478, 1272, 1261, 1240, 803, 1257, 1258, 1259, 1241, 723, 722, 12, 13, 1117, 826, 825, 827, 829, 828, 1159, 824, 1203, 1204, 852, 853, 856, 857, 854, 855, 858, 1145, 1146, 1268, 1269, 859, 1150, 1149, 1152, 1151, 850, 851, 808, 809, 810, 807, 772, 771, 820, 821, 15, 14, 1186, 1187, 1188, 1189, 476, 718, 925, 717, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 610));
  emojiContents.Add(8, TArray<Integer>.Create(31, 34, 37, 95, 32, 39, 36, 35, 41, 38, 45, 44, 43, 47, 63, 54, 50, 49, 67, 51, 68, 56, 58, 64, 60, 48, 66, 62, 59, 53, 52, 55, 84, 153, 78, 69, 160, 72, 252, 77, 79, 80, 155, 73, 71, 82, 133, 83, 87, 88, 92, 91, 93, 94, 97, 99, 246, 123, 101, 98, 103, 107, 109, 106, 105, 110, 211, 111, 120, 114, 89, 117, 118, 124, 119, 113, 127, 126, 121, 128, 129, 134, 132, 130, 135, 145, 141, 137, 144, 143, 138, 139, 146, 75, 148, 150, 147, 149, 161, 151, 154, 282, 159, 152, 162, 171, 163, 168, 167, 172, 165, 169, 170, 184, 180, 178, 192, 194, 191, 181, 189, 179, 187, 190, 193, 108, 175, 174, 183, 176, 188, 173, 195, 182, 196, 205, 204, 202, 197, 207, 201, 198, 200, 206, 157, 203, 208, 214, 221, 219, 209, 212, 222, 210, 213, 215, 220, 218, 223, 225, 227, 228, 235, 156, 164, 274, 281, 240, 245, 229, 241, 226, 231, 239, 234, 238, 236, 230, 242, 285, 158, 102, 166, 232, 243, 249, 233, 74, 248, 265, 256, 266, 255, 258, 254, 261, 263, 260, 262, 259, 264, 268, 267, 33,
                                              112, 270, 277, 271, 272, 279, 273, 275, 278, 280, 100, 283, 286, 287, 224, 46, 250, 142, 61, 86, 70, 116, 140, 284, 199, 217, 57, 216, 125, 257, 65, 131, 237, 269, 136, 96, 81, 90, 42, 40, 276, 76, 85, 104, 115, 253, 122, 186, 185, 247, 244, 251, 177));

  {$IFNDEF USE_MORMOT_COLLECTIONS}
  EmojiList := TEmojiList.Create;
  {$ELSE USE_MORMOT_COLLECTIONS}
  EmojiList := Collections.NewKeyValue<String, TPicName>;
  {$ENDIF USE_MORMOT_COLLECTIONS}
  for i := 0 to emojisCount-1 do
    EmojiList.Add(GetEmojiStr(i), GetEmojiPicName(i));
//  EmojiList.Sort;

  {$IFNDEF USE_MORMOT_COLLECTIONS}
  emojis := TEmojis.Create;
  {$ELSE USE_MORMOT_COLLECTIONS}
  emojis := Collections.NewKeyValue<TEmojiKey, Integer>;
  {$ENDIF USE_MORMOT_COLLECTIONS}
  for i := 0 to emojisCount-1 do
  {$IFNDEF USE_MORMOT_COLLECTIONS}
    emojis.Add(TPair<Cardinal, Cardinal>.Create(emojiCodePoints[i][1], emojiCodePoints[i][2]), i);
  {$ELSE USE_MORMOT_COLLECTIONS}
    begin
      var q: TQWordRec;
      q.l := emojiCodePoints[i][1];
      q.h := emojiCodePoints[i][2];
      emojis.Add(q.v, i);

      if (q.h = 0) and (q.l <= $ffff) then
      begin
        SetLength(singles, Length(singles) + 1);
        singles[Length(singles) - 1] := q.l;
      end;
    end;
  {$ENDIF USE_MORMOT_COLLECTIONS}

  {$IFNDEF USE_MORMOT_COLLECTIONS}
  for key in emojis.Keys do
  if (key.Value = 0) and (key.Key <= $ffff) then
  begin
    SetLength(singles, Length(singles) + 1);
    singles[Length(singles) - 1] := key.Key;
  end;
  {$ENDIF USE_MORMOT_COLLECTIONS}

finalization
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  emojis.Free;
  EmojiList.Free;
  emojiContents.free;
  {$ENDIF USE_MORMOT_COLLECTIONS}
  emojis := NIL;
  EmojiList := NIL;
  emojiContents := NIL;

end.
