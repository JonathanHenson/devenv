# mkdir + cd
mkcd() { mkdir -p "$1" && cd "$1"; }

# Configure, build and test a CMake project in ./build.
#   cmk            Debug build
#   cmk Release    any CMAKE_BUILD_TYPE
#   cmk Debug -DFOO=ON   extra configure args are passed through
cmk() {
  local type="${1:-Debug}"; (( $# )) && shift
  cmake -B build -DCMAKE_BUILD_TYPE="$type" "$@" &&
    cmake --build build &&
    ctest --test-dir build --output-on-failure
}

# Export secrets from AWS Secrets Manager into this shell.
# Reads ~/.config/devenv/secrets (lines of ENV_VAR=secret-id).
#   load-secrets            load all
#   load-secrets GH_TOKEN   load one
load-secrets() {
  local file="$HOME/.config/devenv/secrets" var id value
  [[ -f "$file" ]] || { echo "no $file" >&2; return 1; }
  while IFS='=' read -r var id; do
    [[ -z "$var" || "$var" == \#* ]] && continue
    (( $# )) && [[ " $* " != *" $var "* ]] && continue
    if value="$(aws secretsmanager get-secret-value --secret-id "$id" \
                  --query SecretString --output text 2>/dev/null)"; then
      export "$var=$value"; echo "loaded $var"
    else
      echo "failed $var ($id); try: awsl" >&2
    fi
  done < "$file"
}
