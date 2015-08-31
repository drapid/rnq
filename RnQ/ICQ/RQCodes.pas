{
This file is part of R&Q.
Under same license
}
unit RQCodes;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
    StdCtrls;

{High-level functions}
function StrToAgeI(const Value: String): LongWord;
function StrToGenderI(const Value: String): Byte;
function StrToLanguageI(const Value: String): Byte;
//function StrToCountryI(const Value: String): Word;
function StrToInterestI(const Value: String): Word;
function StrToOccupationI(const Value: String): Word;
function StrToPastI(const Value: String): Word;
function StrToOrganizationI(const Value: String): Word;
function StrToGMTI(const Value: String): SmallInt;
function StrToMarStI(const Value: String): Word;

function AgesToStr : String;
function GendersToStr : String;
function LanguagesToStr : String;
function InterestsToStr : String;
//function CountrysToStr : String;
function GMTsToStr : String;
function MarStsToStr : String;

procedure CountrysToCB(cb : TComboBox);

function GendersByID(ID : Byte) : String;
function CountriesByID(ID : Word) : String;
function LanguagesByID(ID : Byte) : String;
function InterestsByID(ID : Word) : String;
function MarStsByID(ID : Byte) : String;


function CB2ID(cb : TComboBox) : Integer;

implementation
uses
  SysUtils, RDGlobal, RnQLangs; //RQUtil,

type
//  TValType = String;
  TValType = AnsiString;
  TCodeValWord = record ID: word; Value: TValType end;
  TCodeValByte = record ID: Byte; Value: TValType end;
  TCodeValLongWord = record Id: LongWord; Value: TValType end;
  TCodeValSmInt = record ID: Smallint; Value: TValType end;
//Text constants
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//------------------------------------------------------------------------------------------------------------\
const
  Ages: array[0..6] of TCodeValLongWord =
        ((ID: $0D001100; Value: '13-17'),
        (ID: $12001600; Value: '18-22'),
        (ID: $17001D00; Value: '23-29'),
        (ID: $1E002700; Value: '30-39'),
        (ID: $28003100; Value: '40-49'),
        (ID: $32003B00; Value: '50-59'),
        (ID: $3C001027; Value: '60-above'));

const
  Genders: array[0..1] of TCodeValByte =
        ((ID: 1; Value: 'Female'),
        ( ID: 2; Value: 'Male'));
const
  Countries: array[0..242] of TCodeValWord =
    ((ID: 1; Value: 'USA'),
    (ID: 7; Value: 'Russia'),
    (ID: 20; Value: 'Egypt'),
    (ID: 27; Value: 'South Africa'),
    (ID: 30; Value: 'Greece'),
    (ID: 31; Value: 'Netherlands'),
    (ID: 32; Value: 'Belgium'),
    (ID: 33; Value: 'France'),
    (ID: 34; Value: 'Spain'),
    (ID: 36; Value: 'Hungary'),
    (ID: 39; Value: 'Italy'),
    (ID: 40; Value: 'Romania'),
    (ID: 41; Value: 'Switzerland'),
    (ID: 42; Value: 'Czech Republic'),
    (ID: 43; Value: 'Austria'),
    (ID: 44; Value: 'United Kingdom'),
    (ID: 45; Value: 'Denmark'),
    (ID: 46; Value: 'Sweden'),
    (ID: 47; Value: 'Norway'),
    (ID: 48; Value: 'Poland'),
    (ID: 49; Value: 'Germany'),
    (ID: 51; Value: 'Peru'),
    (ID: 52; Value: 'Mexico'),
    (ID: 53; Value: 'Cuba'),
    (ID: 54; Value: 'Argentina'),
    (ID: 55; Value: 'Brazil'),
    (ID: 56; Value: 'Chile'),
    (ID: 57; Value: 'Colombia'),
    (ID: 58; Value: 'Venezuela'),
    (ID: 60; Value: 'Malaysia'),
    (ID: 61; Value: 'Australia'),
    (ID: 62; Value: 'Indonesia'),
    (ID: 63; Value: 'Philippines'),
    (ID: 64; Value: 'New Zealand'),
    (ID: 65; Value: 'Singapore'),
    (ID: 66; Value: 'Thailand'),
    (ID: 81; Value: 'Japan'),
    (ID: 82; Value: 'Korea (Republic of)'),
    (ID: 84; Value: 'Vietnam'),
    (ID: 86; Value: 'China'),
    (ID: 90; Value: 'Turkey'),
    (ID: 91; Value: 'India'),
    (ID: 92; Value: 'Pakistan'),
    (ID: 93; Value: 'Afghanistan'),
    (ID: 94; Value: 'Sri Lanka'),
    (ID: 95; Value: 'Myanmar'),
    (ID: 98; Value: 'Iran'),
    (ID: 101; Value: 'Anguilla'),
    (ID: 102; Value: 'Antigua'),
    (ID: 103; Value: 'Bahamas'),
    (ID: 104; Value: 'Barbados'),
    (ID: 105; Value: 'Bermuda'),
    (ID: 106; Value: 'British Virgin Islands'),
    (ID: 107; Value: 'Canada'),
    (ID: 108; Value: 'Cayman Islands'),
    (ID: 109; Value: 'Dominica'),
    (ID: 110; Value: 'Dominican Republic'),
    (ID: 111; Value: 'Grenada'),
    (ID: 112; Value: 'Jamaica'),
    (ID: 113; Value: 'Montserrat'),
    (ID: 114; Value: 'Nevis'),
    (ID: 115; Value: 'St. Kitts'),
    (ID: 116; Value: 'St. Vincent and the Grenadines'),
    (ID: 117; Value: 'Trinidad and Tobago'),
    (ID: 118; Value: 'Turks and Caicos Islands'),
    (ID: 120; Value: 'Barbuda'),
    (ID: 121; Value: 'Puerto Rico'),
    (ID: 122; Value: 'Saint Lucia'),
    (ID: 123; Value: 'United States Virgin Islands'),
    (ID: 212; Value: 'Morocco'),
    (ID: 213; Value: 'Algeria'),
    (ID: 216; Value: 'Tunisia'),
    (ID: 218; Value: 'Libya'),
    (ID: 220; Value: 'Gambia'),
    (ID: 221; Value: 'Senegal Republic'),
    (ID: 222; Value: 'Mauritania'),
    (ID: 223; Value: 'Mali'),
    (ID: 224; Value: 'Guinea'),
    (ID: 225; Value: 'Ivory Coast'),
    (ID: 226; Value: 'Burkina Faso'),
    (ID: 227; Value: 'Niger'),
    (ID: 228; Value: 'Togo'),
    (ID: 229; Value: 'Benin'),
    (ID: 230; Value: 'Mauritius'),
    (ID: 231; Value: 'Liberia'),
    (ID: 232; Value: 'Sierra Leone'),
    (ID: 233; Value: 'Ghana'),
    (ID: 234; Value: 'Nigeria'),
    (ID: 235; Value: 'Chad'),
    (ID: 236; Value: 'Central African Republic'),
    (ID: 237; Value: 'Cameroon'),
    (ID: 238; Value: 'Cape Verde Islands'),
    (ID: 239; Value: 'Sao Tome and Principe'),
    (ID: 240; Value: 'Equatorial Guinea'),
    (ID: 241; Value: 'Gabon'),
    (ID: 242; Value: 'Congo'),
    (ID: 243; Value: 'Dem. Rep. of the Congo'),
    (ID: 244; Value: 'Angola'),
    (ID: 245; Value: 'Guinea-Bissau'),
    (ID: 246; Value: 'Diego Garcia'),
    (ID: 247; Value: 'Ascension Island'),
    (ID: 248; Value: 'Seychelle Islands'),
    (ID: 249; Value: 'Sudan'),
    (ID: 250; Value: 'Rwanda'),
    (ID: 251; Value: 'Ethiopia'),
    (ID: 252; Value: 'Somalia'),
    (ID: 253; Value: 'Djibouti'),
    (ID: 254; Value: 'Kenya'),
    (ID: 255; Value: 'Tanzania'),
    (ID: 256; Value: 'Uganda'),
    (ID: 257; Value: 'Burundi'),
    (ID: 258; Value: 'Mozambique'),
    (ID: 260; Value: 'Zambia'),
    (ID: 261; Value: 'Madagascar'),
    (ID: 262; Value: 'Reunion Island'),
    (ID: 263; Value: 'Zimbabwe'),
    (ID: 264; Value: 'Namibia'),
    (ID: 265; Value: 'Malawi'),
    (ID: 266; Value: 'Lesotho'),
    (ID: 267; Value: 'Botswana'),
    (ID: 268; Value: 'Swaziland'),
    (ID: 269; Value: 'Mayotte Island'),
    (ID: 290; Value: 'St. Helena'),
    (ID: 291; Value: 'Eritrea'),
    (ID: 297; Value: 'Aruba'),
    (ID: 298; Value: 'Faeroe Islands'),
    (ID: 299; Value: 'Greenland'),
    (ID: 350; Value: 'Gibraltar'),
    (ID: 351; Value: 'Portugal'),
    (ID: 352; Value: 'Luxembourg'),
    (ID: 353; Value: 'Ireland'),
    (ID: 354; Value: 'Iceland'),
    (ID: 355; Value: 'Albania'),
    (ID: 356; Value: 'Malta'),
    (ID: 357; Value: 'Cyprus'),
    (ID: 358; Value: 'Finland'),
    (ID: 359; Value: 'Bulgaria'),
    (ID: 370; Value: 'Lithuania'),
    (ID: 371; Value: 'Latvia'),
    (ID: 372; Value: 'Estonia'),
    (ID: 373; Value: 'Moldova'),
    (ID: 374; Value: 'Armenia'),
    (ID: 375; Value: 'Belarus'),
    (ID: 376; Value: 'Andorra'),
    (ID: 377; Value: 'Monaco'),
    (ID: 378; Value: 'San Marino'),
    (ID: 379; Value: 'Vatican City'),
    (ID: 380; Value: 'Ukraine'),
    (ID: 381; Value: 'Yugoslavia'),
    (ID: 385; Value: 'Croatia'),
    (ID: 386; Value: 'Slovenia'),
    (ID: 387; Value: 'Bosnia and Herzegovina'),
    (ID: 389; Value: 'F.Y.R.O.M. (Former Yugoslav Republic of Macedonia)'),
    (ID: 500; Value: 'Falkland Islands'),
    (ID: 501; Value: 'Belize'),
    (ID: 502; Value: 'Guatemala'),
    (ID: 503; Value: 'El Salvador'),
    (ID: 504; Value: 'Honduras'),
    (ID: 505; Value: 'Nicaragua'),
    (ID: 506; Value: 'Costa Rica'),
    (ID: 507; Value: 'Panama'),
    (ID: 508; Value: 'St. Pierre and Miquelon'),
    (ID: 509; Value: 'Haiti'),
    (ID: 590; Value: 'Guadeloupe'),
    (ID: 591; Value: 'Bolivia'),
    (ID: 592; Value: 'Guyana'),
    (ID: 593; Value: 'Ecuador'),
    (ID: 594; Value: 'French Guiana'),
    (ID: 595; Value: 'Paraguay'),
    (ID: 596; Value: 'Martinique'),
    (ID: 597; Value: 'Suriname'),
    (ID: 598; Value: 'Uruguay'),
    (ID: 599; Value: 'Netherlands Antilles'),
    (ID: 670; Value: 'Saipan Island'),
    (ID: 671; Value: 'Guam'),
    (ID: 672; Value: 'Christmas Island'),
    (ID: 673; Value: 'Brunei'),
    (ID: 674; Value: 'Nauru'),
    (ID: 675; Value: 'Papua New Guinea'),
    (ID: 676; Value: 'Tonga'),
    (ID: 677; Value: 'Solomon Islands'),
    (ID: 678; Value: 'Vanuatu'),
    (ID: 679; Value: 'Fiji Islands'),
    (ID: 680; Value: 'Palau'),
    (ID: 681; Value: 'Wallis and Futuna Islands'),
    (ID: 682; Value: 'Cook Islands'),
    (ID: 683; Value: 'Niue'),
    (ID: 684; Value: 'American Samoa'),
    (ID: 685; Value: 'Western Samoa'),
    (ID: 686; Value: 'Kiribati Republic'),
    (ID: 687; Value: 'New Caledonia'),
    (ID: 688; Value: 'Tuvalu'),
    (ID: 689; Value: 'French Polynesia'),
    (ID: 690; Value: 'Tokelau'),
    (ID: 691; Value: 'Micronesia, Federated States of'),
    (ID: 692; Value: 'Marshall Islands'),
    (ID: 705; Value: 'Kazakhstan'),
    (ID: 706; Value: 'Kyrgyz Republic'),
    (ID: 708; Value: 'Tajikistan'),
    (ID: 709; Value: 'Turkmenistan'),
    (ID: 711; Value: 'Uzbekistan'),
    (ID: 800; Value: 'International Freephone Service'),
    (ID: 850; Value: 'Korea (North)'),
    (ID: 852; Value: 'Hong Kong'),
    (ID: 853; Value: 'Macau'),
    (ID: 855; Value: 'Cambodia'),
    (ID: 856; Value: 'Laos'),
    (ID: 870; Value: 'INMARSAT'),
    (ID: 871; Value: 'INMARSAT (Atlantic-East)'),
    (ID: 872; Value: 'INMARSAT (Pacific)'),
    (ID: 873; Value: 'INMARSAT (Indian)'),
    (ID: 874; Value: 'INMARSAT (Atlantic-West)'),
    (ID: 880; Value: 'Bangladesh'),
    (ID: 886; Value: 'Taiwan, Republic of China'),
    (ID: 960; Value: 'Maldives'),
    (ID: 961; Value: 'Lebanon'),
    (ID: 962; Value: 'Jordan'),
    (ID: 963; Value: 'Syria'),
    (ID: 964; Value: 'Iraq'),
    (ID: 965; Value: 'Kuwait'),
    (ID: 966; Value: 'Saudi Arabia'),
    (ID: 967; Value: 'Yemen'),
    (ID: 968; Value: 'Oman'),
    (ID: 971; Value: 'United Arab Emirates'),
    (ID: 972; Value: 'Israel'),
    (ID: 973; Value: 'Bahrain'),
    (ID: 974; Value: 'Qatar'),
    (ID: 975; Value: 'Bhutan'),
    (ID: 976; Value: 'Mongolia'),
    (ID: 977; Value: 'Nepal'),
    (ID: 994; Value: 'Azerbaijan'),
    (ID: 995; Value: 'Georgia'),
    (ID: 2691; Value: 'Comoros'),
    (ID: 4101; Value: 'Liechtenstein'),
    (ID: 4201; Value: 'Slovak Republic'),
    (ID: 5399; Value: 'Guantanamo Bay'),
    (ID: 5901; Value: 'French Antilles'),
    (ID: 6101; Value: 'Cocos-Keeling Islands'),
    (ID: 6701; Value: 'Rota Island'),
    (ID: 6702; Value: 'Tinian Island'),
    (ID: 6721; Value: 'Australian Antarctic Territory'),
    (ID: 6722; Value: 'Norfolk Island'),
    (ID: 9999; Value: 'Unknown'));

  Languages: array[0..72] of TCodeValByte =
    ((ID: 1; Value: 'Arabic'),
    (ID: 2; Value: 'Bhojpuri'),
    (ID: 3; Value: 'Bulgarian'),
    (ID: 4; Value: 'Burmese'),
    (ID: 5; Value: 'Cantonese'),
    (ID: 6; Value: 'Catalan'),
    (ID: 7; Value: 'Chinese'),
    (ID: 8; Value: 'Croatian'),
    (ID: 9; Value: 'Czech'),
    (ID: 10; Value: 'Danish'),
    (ID: 11; Value: 'Dutch'),
    (ID: 12; Value: 'English'),
    (ID: 13; Value: 'Esperanto'),
    (ID: 14; Value: 'Estonian'),
    (ID: 15; Value: 'Farci'),
    (ID: 16; Value: 'Finnish'),
    (ID: 17; Value: 'French'),
    (ID: 18; Value: 'Gaelic'),
    (ID: 19; Value: 'German'),
    (ID: 20; Value: 'Greek'),
    (ID: 21; Value: 'Hebrew'),
    (ID: 22; Value: 'Hindi'),
    (ID: 23; Value: 'Hungarian'),
    (ID: 24; Value: 'Icelandic'),
    (ID: 25; Value: 'Indonesian'),
    (ID: 26; Value: 'Italian'),
    (ID: 27; Value: 'Japanese'),
    (ID: 28; Value: 'Khmer'),
    (ID: 29; Value: 'Korean'),
    (ID: 30; Value: 'Lao'),
    (ID: 31; Value: 'Latvian'),
    (ID: 32; Value: 'Lithuanian'),
    (ID: 33; Value: 'Malay'),
    (ID: 34; Value: 'Norwegian'),
    (ID: 35; Value: 'Polish'),
    (ID: 36; Value: 'Portuguese'),
    (ID: 37; Value: 'Romanian'),
    (ID: 38; Value: 'Russian'),
    (ID: 39; Value: 'Serbo-Croatian'),
    (ID: 40; Value: 'Slovak'),
    (ID: 41; Value: 'Slovenian'),
    (ID: 42; Value: 'Somali'),
    (ID: 43; Value: 'Spanish'),
    (ID: 44; Value: 'Swahili'),
    (ID: 45; Value: 'Swedish'),
    (ID: 46; Value: 'Tagalog'),
    (ID: 47; Value: 'Tatar'),
    (ID: 48; Value: 'Thai'),
    (ID: 49; Value: 'Turkish'),
    (ID: 50; Value: 'Ukrainian'),
    (ID: 51; Value: 'Urdu'),
    (ID: 52; Value: 'Vietnamese'),
    (ID: 53; Value: 'Yiddish'),
    (ID: 54; Value: 'Yoruba'),
    (ID: 55; Value: 'Afrikaans'),
    (ID: 56; Value: 'Bosnian'),
    (ID: 57; Value: 'Persian'),
    (ID: 58; Value: 'Albanian'),
    (ID: 59; Value: 'Armenian'),
    (ID: 60; Value: 'Punjabi'),
    (ID: 61; Value: 'Chamorro'),
    (ID: 62; Value: 'Mongolian'),
    (ID: 63; Value: 'Mandarin'),
    (ID: 64; Value: 'Taiwanese'),
    (ID: 65; Value: 'Macedonian'),
    (ID: 66; Value: 'Sindhi'),
    (ID: 67; Value: 'Welsh'),
    (ID: 68; Value: 'Azerbaijani'),
    (ID: 69; Value: 'Kurdish'),
    (ID: 70; Value: 'Gujarati'),
    (ID: 71; Value: 'Tamil'),
    (ID: 72; Value: 'Belorussian'),
    (ID: 255; Value: 'Unknown'));

  Occupations: array[1..17] of TCodeValByte =
    ((ID: 1; Value: 'Academic'),
    (ID: 2; Value: 'Administrative'),
    (ID: 3; Value: 'Art/Entertainment'),
    (ID: 4; Value: 'College Student'),
    (ID: 5; Value: 'Computers'),
    (ID: 6; Value: 'Community & Social'),
    (ID: 7; Value: 'Education'),
    (ID: 8; Value: 'Engineering'),
    (ID: 9; Value: 'Financial Services'),
    (ID: 10; Value: 'Government'),
    (ID: 11; Value: 'High School Student'),
    (ID: 12; Value: 'Home'),
    (ID: 13; Value: 'ICQ - Providing Help'),
    (ID: 14; Value: 'Law'),
    (ID: 15; Value: 'Managerial'),
    (ID: 16; Value: 'Manufacturing'),
    (ID: 17; Value: 'Medical/Health'));

  arrInterests: array[100..150] of TCodeValByte =
    ((ID: 100; Value: 'Art'),
    (ID: 101; Value: 'Cars'), // $65
    (ID: 102; Value: 'Celebrity Fans'),
    (ID: 103; Value: 'Collections'),
    (ID: 104; Value: 'Computers'),
    (ID: 105; Value: 'Culture & Literature'),
    (ID: 106; Value: 'Fitness'),
    (ID: 107; Value: 'Games'),
    (ID: 108; Value: 'Hobbies'),
    (ID: 109; Value: 'ICQ - Providing Help'),
    (ID: 110; Value: 'Internet'),
    (ID: 111; Value: 'Lifestyle'),
    (ID: 112; Value: 'Movies/TV'),
    (ID: 113; Value: 'Music'),
    (ID: 114; Value: 'Outdoor Activities'),
    (ID: 115; Value: 'Parenting'),
    (ID: 116; Value: 'Pets/Animals'),
    (ID: 117; Value: 'Religion'),
    (ID: 118; Value: 'Science/Technology'),
    (ID: 119; Value: 'Skills'),
    (ID: 120; Value: 'Sports'),
    (ID: 121; Value: 'Web Design'),
    (ID: 122; Value: 'Nature and Environment'),
    (ID: 123; Value: 'News & Media'),
    (ID: 124; Value: 'Government'),
    (ID: 125; Value: 'Business & Economy'),
    (ID: 126; Value: 'Mystics'),
    (ID: 127; Value: 'Travel'),
    (ID: 128; Value: 'Astronomy'),
    (ID: 129; Value: 'Space'),
    (ID: 130; Value: 'Clothing'),
    (ID: 131; Value: 'Parties'),
    (ID: 132; Value: 'Women'),
    (ID: 133; Value: 'Social science'),
    (ID: 134; Value: '60''s'),
    (ID: 135; Value: '70''s'),
    (ID: 136; Value: '80''s'),
    (ID: 137; Value: '50''s'),
    (ID: 138; Value: 'Finance and corporate'),
    (ID: 139; Value: 'Entertainment'),
    (ID: 140; Value: 'Consumer electronics'),
    (ID: 141; Value: 'Retail stores'),
    (ID: 142; Value: 'Health and beauty'),
    (ID: 143; Value: 'Media'),
    (ID: 144; Value: 'Household products'),
    (ID: 145; Value: 'Mail order catalog'),
    (ID: 146; Value: 'Business services'),
    (ID: 147; Value: 'Audio and visual'),
    (ID: 148; Value: 'Sporting and athletic'),
    (ID: 149; Value: 'Publishing'),
    (ID: 150; Value: 'Home automation'));

  RandGroups: array[1..11] of TCodeValByte =
    ((ID: 1; Value: 'General'),
    (ID: 2; Value: 'Romance'),
    (ID: 3; Value: 'Games'),
    (ID: 4; Value: 'Students'),
    (ID: 5; Value: '20 something'),
    (ID: 6; Value: '30 something'),
    (ID: 7; Value: '40 something'),
    (ID: 8; Value: '50+'),
    (ID: 9; Value: 'Romance'),
    (ID: 10; Value: 'Man requesting woman'),
    (ID: 11; Value: 'Woman requesting man'));

  Organizations: array[0..19] of TCodeValWord =
    ((ID: 200; Value: 'Alumni Org.'),
    (ID: 201; Value: 'Charity Org.'),
    (ID: 202; Value: 'Club/Social Org.'),
    (ID: 203; Value: 'Community Org.'),
    (ID: 204; Value: 'Cultural Org.'),
    (ID: 205; Value: 'Fan Clubs'),
    (ID: 206; Value: 'Fraternity/Sorority'),
    (ID: 207; Value: 'Hobbyists Org.'),
    (ID: 208; Value: 'International Org.'),
    (ID: 209; Value: 'Nature and Environment Org.'),
    (ID: 210; Value: 'Professional Org.'),
    (ID: 211; Value: 'Scientific/Technical Org.'),
    (ID: 212; Value: 'Self Improvement Group'),
    (ID: 213; Value: 'Spiritual/Religious Org.'),
    (ID: 214; Value: 'Sports Org.'),
    (ID: 215; Value: 'Support Org.'),
    (ID: 216; Value: 'Trade and Business Org.'),
    (ID: 217; Value: 'Union'),
    (ID: 218; Value: 'Volunteer Org.'),
    (ID: 299; Value: 'Other'));

  Pasts: array[0..7] of TCodeValWord =
    ((ID: 300; Value: 'Elementary School'),
    (ID: 301; Value: 'High School'),
    (ID: 302; Value: 'College'),
    (ID: 303; Value: 'University'),
    (ID: 304; Value: 'Military'),
    (ID: 305; Value: 'Past Work Place'),
    (ID: 306; Value: 'Past Organization'),
    (ID: 399; Value: 'Other'));

const
    GMTs: array[0..49] of TCodeValSmInt =
    ((ID: -100; Value: ''),
     (ID: 24; Value: '-12:00'),
     (ID: 23; Value: '-11:30'),
     (ID: 22; Value: '-11:00'),
     (ID: 21; Value: '-10:30'),
     (ID: 20; Value: '-10:00'),
     (ID: 19; Value: '-9:30'),
     (ID: 18; Value: '-9:00'),
     (ID: 17; Value: '-8:30'),
     (ID: 16; Value: '-8:00'),
     (ID: 15; Value: '-7:30'),
     (ID: 14; Value: '-7:00'),
     (ID: 13; Value: '-6:30'),
     (ID: 12; Value: '-6:00'),
     (ID: 11; Value: '-5:30'),
     (ID: 10; Value: '-5:00'),
     (ID: 9 ;  Value: '-4:30'),
     (ID: 8 ;  Value: '-4:00'),
     (ID: 7 ;  Value: '-3:30'),
     (ID: 6 ;  Value: '-3:00'),
     (ID: 5 ;  Value: '-2:30'),
     (ID: 4 ;  Value: '-2:00'),
     (ID: 3 ;  Value: '-1:30'),
     (ID: 2 ;  Value: '-1:00'),
     (ID: 1 ;  Value: '-0:30'),
     (ID: 0 ;  Value: '+0:00'),
     (ID: -1;  Value: '+0:30'),
     (ID: -2;  Value: '+1:00'),
     (ID: -3;  Value: '+1:30'),
     (ID: -4;  Value: '+2:00'),
     (ID: -5;  Value: '+2:30'),
     (ID: -6;  Value: '+3:00'),
     (ID: -7;  Value: '+3:30'),
     (ID: -8;  Value: '+4:00'),
     (ID: -9;  Value: '+4:30'),
     (ID: -10; Value: '+5:00'),
     (ID: -11; Value: '+5:30'),
     (ID: -12; Value: '+6:00'),
     (ID: -13; Value: '+6:30'),
     (ID: -14; Value: '+7:00'),
     (ID: -15; Value: '+7:30'),
     (ID: -16; Value: '+8:00'),
     (ID: -17; Value: '+8:30'),
     (ID: -18; Value: '+9:00'),
     (ID: -19; Value: '+9:30'),
     (ID: -20; Value: '+10:00'),
     (ID: -21; Value: '+10:30'),
     (ID: -22; Value: '+11:00'),
     (ID: -23; Value: '+11:30'),
     (ID: -24; Value: '+12:00'));

  MarSts: array[0..9] of TCodeValWord =
  ((ID: $0000; Value: 'Not specified'),
   (ID: $000A; Value: 'Single'),
   (ID: $000B; Value: 'Long-term relationship'),
   (ID: $000C; Value: 'Engaged'),
   (ID: $0014; Value: 'Married'),
   (ID: $001E; Value: 'Divorced'),
   (ID: $001F; Value: 'Separated'),
   (ID: $0028; Value: 'Widowed'),
   (ID: $0032; Value: 'Open marriage'),
   (ID: $00FF; Value: 'Other'));

{@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@}
function StrToAgeI(const Value: String): LongWord;
var
  i: Word;
  val : TValType;
begin
  val := Value;
  if Length(val)> 0 then
   for i := Low(Ages) to High(Ages) do
    if Ages[i].Value = val then
    begin
      Result := Ages[i].ID;
      Exit;
    end;
  Result := 0;
end;
function StrToGenderI(const Value: String): Byte;
var
  i: Word;
begin
  if Length(Value)> 0 then
  for i := Low(Genders) to High(Genders) do
    if getTranslation(Genders[i].Value) = Value then
    begin
      Result := Genders[i].ID;
      Exit;
    end;
  Result := 0;
end;
function StrToLanguageI(const Value: String): Byte;
var
  i: Byte;
begin
  if Length(Value)> 0 then
  for i := Low(Languages) to High(Languages) do
    if getTranslation(Languages[i].Value) = Value then
    begin
      Result := Languages[i].ID;
      Exit;
    end;
  Result := 0;
end;

{function StrToCountryI(const Value: String): Word;
var
  i: Word;
begin
  if Length(Value)> 0 then
  for i := Low(Countries) to High(Countries) do
    if getTranslation(Countries[i].Value) = Value then
    begin
      Result := Countries[i].ID;
      Exit;
    end;
  Result := 0;
end;
}
function StrToInterestI(const Value: String): Word;
var
  i: Word;
begin
  if Length(Value)> 0 then
  for i := Low(arrInterests) to High(arrInterests) do
    if getTranslation(arrInterests[i].Value) = Value then
    begin
      Result := arrInterests[i].ID;
      Exit;
    end;
  Result := 0;
end;

function StrToOccupationI(const Value: String): Word;
var
  i: Word;
  val : TValType;
begin
  val := Value;
  if Length(val)> 0 then
  for i := Low(Occupations) to High(Occupations) do
    if Occupations[i].Value = val then
    begin
      Result := Occupations[i].ID;
      Exit;
    end;
  Result := 0;
end;

function StrToPastI(const Value: String): Word;
var
  i: Word;
  val : TValType;
begin
  val := Value;
  if Length(val)> 0 then
  for i := Low(Pasts) to High(Pasts) do
    if Pasts[i].Value = val then
    begin
      Result := Pasts[i].ID;
      Exit;
    end;
  Result := 0;
end;

function StrToMarStI(const Value: String): Word;
var
  i: Word;
begin
  if Length(Value)> 0 then
  for i := Low(MarSts) to High(MarSts) do
    if getTranslation(MarSts[i].Value) = Value then
    begin
      Result := MarSts[i].ID;
      Exit;
    end;
  Result := 0;
end;

function StrToOrganizationI(const Value: String): Word;
var
  i: Word;
  val : TValType;
begin
  val := Value;
  if Length(val)> 0 then
  for i := Low(Organizations) to High(Organizations) do
    if Organizations[i].Value = val then
    begin
      Result := Organizations[i].ID;
      Exit;
    end;
  Result := 0;
end;

function AgesToStr : String;
var
  i: Word;
  val : TValType;
begin
  val := '';
  for i := Low(Ages) to High(Ages) do
    val := val +Ages[i].Value+CRLF;
  Result := val;
end;

function GendersToStr : String;
var
  i: Word;
begin
  result:='';
  for i := Low(Genders) to High(Genders) do
    result:=result+getTranslation(Genders[i].Value)+CRLF;
end;

function MarStsToStr : String;
var
  i: Word;
begin
  result:='';
  for i := Low(MarSts) to High(MarSts) do
    result:=result+getTranslation(MarSts[i].Value)+CRLF;
end;

function LanguagesToStr : String;
var
  i: Byte;
begin
  result:='';
  for i := Low(Languages) to High(Languages) do
    result:=result+getTranslation(Languages[i].Value)+CRLF;
end;

function InterestsToStr : String;
var
  i: Word;
begin
  result:='';
  for i := Low(arrInterests) to High(arrInterests) do
    result:=result+getTranslation(arrInterests[i].Value)+CRLF;
end;

procedure CountrysToCB(cb : TComboBox);
var
  a: TCodeValWord;
begin
//  result:='';
  cb.AddItem('',TObject(Integer(0)));
  for a in Countries do
    cb.AddItem(getTranslation(a.Value),TObject(Integer(a.ID)));
end;

function CountrysToStr : String;
var
  i: Word;
begin
  result:='';
  for i := Low(Countries) to High(Countries) do
    result:=result+getTranslation(Countries[i].Value)+CRLF;
end;

function GMTsToStr : String;
{  function GMTc(i : Smallint): string;
  begin
    if i > 0 then
      result := '-'
    else
      result := '+';
    result := result + IntToStr(i div 2)+ ':';
    if odd(i) then
      result:=result+'30'
    else
      result:=result+'00';
  end;
var
  i : Smallint;
begin
  result := '' + CRLF;
  for i := 24 downto -24 do
    result := 'GMT ' + GMTc(i);}
var
  i: Word;
  val : TValType;
begin
  val :='' + CRLF;
  for i := Low(GMTs)+1 to High(GMTs) do
//    result:=result+'GMT ' + GMTs[i].Value+CRLF;
    val := val + GMTs[i].Value+CRLF;
  Result := val;
end;
function StrToGMTI(const Value: String): SmallInt;
var
  i: Word;
  val : TValType;
begin
  val := Value;
  if GMTs[0].Value= val then
    begin
      Result := GMTs[0].ID;
      Exit;
    end;
  for i := Low(GMTs)+1 to High(GMTs) do
//    if ('GMT ' + GMTs[i].Value)= Value then
    if (GMTs[i].Value)= val then
    begin
      Result := GMTs[i].ID;
      Exit;
    end;
  Result := 0;
end;

function GendersByID(ID : Byte) : String;
var
  i: Word;
begin
  for i := Low(Genders) to High(Genders) do
    if Genders[i].ID = ID then
    begin
      Result := Genders[i].Value;
      Result := getTranslation(Result);
      Exit;
    end;
  Result := '';
end;

function MarStsByID(ID : Byte) : String;
var
  i: Word;
begin
  for i := Low(MarSts) to High(MarSts) do
    if MarSts[i].ID = ID then
    begin
      Result := MarSts[i].Value;
      Result := getTranslation(Result);
      Exit;
    end;
  Result := '';
end;

function CountriesByID(ID : Word) : String;
var
  i: Word;
begin
  for i := Low(Countries) to High(Countries) do
    if Countries[i].ID = ID then
    begin
      Result := Countries[i].Value;
      Result := getTranslation(Result);
      Exit;
    end;
  Result := '';
end;

function LanguagesByID(ID : Byte) : String;
var
  i: Byte;
begin
  for i := Low(Languages) to High(Languages) do
    if Languages[i].ID = ID then
    begin
      Result := Languages[i].Value;
      Result := getTranslation(Result);
      Exit;
    end;
  Result := '';
end;

function InterestsByID(ID : Word) : String;
var
  i: Word;
begin
  for i := Low(arrInterests) to High(arrInterests) do
    if arrInterests[i].ID = ID then
    begin
      Result := arrInterests[i].Value;
      Result := getTranslation(Result);
      Exit;
    end;
  Result := '';
end;

function CB2ID(cb : TComboBox) : Integer;
begin
  if cb.ItemIndex >= 0 then
    Result := Integer(cb.Items.Objects[cb.ItemIndex])
   else
    Result := 0;
end;

end.
