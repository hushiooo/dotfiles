{ ... }:
{
  enable = true;

  settings = {
    no-emit-version = true;
    no-comments = true;
    keyid-format = "0xlong";
    with-fingerprint = true;
    list-options = "show-uid-validity";
    verify-options = "show-uid-validity";
    use-agent = true;
    display-charset = "utf-8";
    personal-digest-preferences = "SHA512 SHA384 SHA256";
    personal-cipher-preferences = "AES256 AES192 AES";
    personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
    default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
  };
}
