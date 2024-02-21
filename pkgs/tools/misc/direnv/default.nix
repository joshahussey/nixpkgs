{ lib, stdenv, fetchFromGitHub, buildGoModule, bash, fish, zsh }:

buildGoModule rec {
  pname = "direnv";
  version = "20af177601753759d38d6af9990e2a954e5721e9";

  src = fetchFromGitHub {
    owner = "tiymat";
    repo = "direnv";
    rev = "${version}";
    sha256 = "sha256-zeFbDyfPE5AlBKb7uzWhSupTSo3AkeEhzvAqn2rinac=";
  };

  vendorHash = "sha256-FfKvLPv+jUT5s2qQ7QlzBMArI+acj7nhpE8FGMPpp5E=";

  # we have no bashat the moment for windows
  BASH_PATH =
    lib.optionalString (!stdenv.hostPlatform.isWindows)
    "${bash}/bin/bash";

  # replace the build phase to use the GNUMakefile instead
  buildPhase = ''
    make BASH_PATH=$BASH_PATH
  '';

  installPhase = ''
    make install PREFIX=$out
  '';

  nativeCheckInputs = [ fish zsh ];

  checkPhase = ''
    export HOME=$(mktemp -d)
    make test-go test-bash test-fish test-zsh
  '';

  meta = with lib; {
    description = "A shell extension that manages your environment";
    longDescription = ''
      Once hooked into your shell direnv is looking for an .envrc file in your
      current directory before every prompt.

      If found it will load the exported environment variables from that bash
      script into your current environment, and unload them if the .envrc is
      not reachable from the current path anymore.

      In short, this little tool allows you to have project-specific
      environment variables.
    '';
    homepage = "https://direnv.net";
    license = licenses.mit;
    maintainers = [ maintainers.zimbatm ];
    mainProgram = "direnv";
  };
}
