#include <string>
#include "cryptopp/sha.h"
#include "cryptopp/base64.h"
#include "cryptopp/hex.h"

#ifdef WIN32
extern "C" __declspec(dllexport) const char * SHA1(int argc, char ** argv);
extern "C" __declspec(dllexport) const char * SHA224(int argc, char ** argv);
extern "C" __declspec(dllexport) const char * SHA256(int argc, char ** argv);
extern "C" __declspec(dllexport) const char * SHA384(int argc, char ** argv);
extern "C" __declspec(dllexport) const char * SHA512(int argc, char ** argv);
#else
#include <cstring>
extern "C" const char * SHA1(int argc, char ** argv);
extern "C" const char * SHA224(int argc, char ** argv);
extern "C" const char * SHA256(int argc, char ** argv);
extern "C" const char * SHA384(int argc, char ** argv);
extern "C" const char * SHA512(int argc, char ** argv);
#endif

using namespace std;
string output;

const char * SHA1(int argc, char ** argv)
{
    CryptoPP::SHA1 hash;
    byte digest[ CryptoPP::SHA256::DIGESTSIZE ];
    hash.CalculateDigest( digest, (const byte *)argv[0], strlen(argv[0]) );

    CryptoPP::HexEncoder encoder;
    output = "";
    encoder.Attach( new CryptoPP::StringSink( output ) );
    encoder.Put( digest, sizeof(digest) );
    encoder.MessageEnd();

    return (const char *)output.c_str();
}


const char * SHA224(int argc, char ** argv)
{
    CryptoPP::SHA224 hash;
    byte digest[ CryptoPP::SHA224::DIGESTSIZE ];
    hash.CalculateDigest( digest, (const byte *)argv[0], strlen(argv[0]) );

    CryptoPP::HexEncoder encoder;
    output = "";
    encoder.Attach( new CryptoPP::StringSink( output ) );
    encoder.Put( digest, sizeof(digest) );
    encoder.MessageEnd();

    return (const char *)output.c_str();
}

const char * SHA256(int argc, char ** argv)
{
    CryptoPP::SHA256 hash;
    byte digest[ CryptoPP::SHA256::DIGESTSIZE ];
    hash.CalculateDigest( digest, (const byte *)argv[0], strlen(argv[0]) );

    CryptoPP::HexEncoder encoder;
    output = "";
    encoder.Attach( new CryptoPP::StringSink( output ) );
    encoder.Put( digest, sizeof(digest) );
    encoder.MessageEnd();

    return (const char *)output.c_str();
}


const char * SHA384(int argc, char ** argv)
{
    CryptoPP::SHA384 hash;
    byte digest[ CryptoPP::SHA384::DIGESTSIZE ];
    hash.CalculateDigest( digest, (const byte *)argv[0], strlen(argv[0]) );

    CryptoPP::HexEncoder encoder;
    output = "";
    encoder.Attach( new CryptoPP::StringSink( output ) );
    encoder.Put( digest, sizeof(digest) );
    encoder.MessageEnd();

    return (const char *)output.c_str();
}

const char * SHA512(int argc, char ** argv)
{
    CryptoPP::SHA512 hash;
    byte digest[ CryptoPP::SHA512::DIGESTSIZE ];
    hash.CalculateDigest( digest, (const byte *)argv[0], strlen(argv[0]) );

    CryptoPP::HexEncoder encoder;
    output = "";
    encoder.Attach( new CryptoPP::StringSink( output ) );
    encoder.Put( digest, sizeof(digest) );
    encoder.MessageEnd();

    return (const char *)output.c_str();
}