{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, openssl, CoreServices, libiconv }:

rustPlatform.buildRustPackage rec {
  pname = "surrealdb";
  version = "1.0.0-beta.7";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "surrealdb";
    repo = pname;
    sha256 = lib.fakeSha256;
  };

  cargoSha256 = lib.fakeSha256;


  nativeBuildInputs = [ pkg-config ];

   meta = with lib; {
    homepage = "https://github.com/surrealdb/surrealdb";
    description = "A scalable, distributed, collaborative, document-graph database, for the realtime web";
    license = licenses.mit;
    maintainers = [ maintainers.oluceps ];
  };
}
