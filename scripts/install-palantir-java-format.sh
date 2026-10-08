#!/usr/bin/env bash
# Installs palantir-java-format (jar + dependencies from Maven Central) and a
# `palantir-java-format` wrapper for conform.nvim. Requires `java` and `curl`.
# Override PALANTIR_JAVA_FORMAT_VERSION to pick another release.

set -euo pipefail

version="${PALANTIR_JAVA_FORMAT_VERSION:-2.102.0}"
install_dir="${PALANTIR_JAVA_FORMAT_DIR:-${HOME}/.local/share/palantir-java-format}"
local_bin="${PALANTIR_JAVA_FORMAT_BIN:-${HOME}/.local/bin}"
maven=https://repo1.maven.org/maven2

for command in java curl; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "${command} is required." >&2
    exit 1
  fi
done

# Runtime dependencies are pinned to the versions used by 2.102.0. When bumping
# the version, check the dependencies in the release's POM.
artifacts=(
  "com/palantir/javaformat/palantir-java-format/${version}/palantir-java-format-${version}.jar"
  "com/palantir/javaformat/palantir-java-format-spi/${version}/palantir-java-format-spi-${version}.jar"
  com/google/guava/guava/33.7.2-jre/guava-33.7.2-jre.jar
  com/google/guava/failureaccess/1.0.3/failureaccess-1.0.3.jar
  org/functionaljava/functionaljava/5.0/functionaljava-5.0.jar
  com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar
  com/fasterxml/jackson/core/jackson-annotations/2.22/jackson-annotations-2.22.jar
  com/fasterxml/jackson/core/jackson-core/2.22.3/jackson-core-2.22.3.jar
  com/fasterxml/jackson/core/jackson-databind/2.22.3/jackson-databind-2.22.3.jar
  com/fasterxml/jackson/datatype/jackson-datatype-guava/2.22.3/jackson-datatype-guava-2.22.3.jar
  com/fasterxml/jackson/datatype/jackson-datatype-jdk8/2.22.3/jackson-datatype-jdk8-2.22.3.jar
  com/fasterxml/jackson/module/jackson-module-parameter-names/2.22.3/jackson-module-parameter-names-2.22.3.jar
)

lib_dir="${install_dir}/lib"
rm -rf "$lib_dir"
mkdir -p "$lib_dir" "$local_bin"
for artifact in "${artifacts[@]}"; do
  curl --fail --location --silent --show-error "${maven}/${artifact}" \
    --output "${lib_dir}/${artifact##*/}"
done

# javac internals must be exported for the formatter to parse sources on modern JDKs.
cat > "${local_bin}/palantir-java-format" <<EOF
#!/bin/sh
exec java \\
  -XX:+UseSerialGC -XX:TieredStopAtLevel=1 -Xshare:auto \\
  --add-exports jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED \\
  --add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED \\
  --add-exports jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED \\
  --add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED \\
  --add-exports jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED \\
  --add-exports jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED \\
  --add-exports jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED \\
  -cp "${lib_dir}/*" com.palantir.javaformat.java.Main "\$@"
EOF
chmod +x "${local_bin}/palantir-java-format"

echo "Installed palantir-java-format ${version} to ${install_dir}"
echo "Wrapper: ${local_bin}/palantir-java-format (make sure it is on your PATH)"
