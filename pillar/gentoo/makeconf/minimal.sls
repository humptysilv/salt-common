# Minimal make.conf settings for lightweight/container builds
# Strips out unnecessary features and targets smallest possible footprint

makeconf:
  cflags:
    - "-O2"
    - "-pipe"
    - "-fomit-frame-pointer"
  cxxflags: "${CFLAGS}"
  makeopts: "-j{{ [grains['num_cpus'], 2] | min }}"
  features:
    - "parallel-fetch"
    - "-doc"
    - "-man"
    - "nodoc"
    - "noman"
    - "noinfo"
    - "compress-build-logs"
  emerge_default_opts:
    - "--jobs=1"
    - "--keep-going"
    - "--with-bdeps=n"
    - "--quiet-build=y"
  use_flags:
    - "-X"
    - "-gtk"
    - "-gtk2"
    - "-gtk3"
    - "-qt4"
    - "-qt5"
    - "-kde"
    - "-gnome"
    - "-doc"
    - "-examples"
    - "-test"
    - "minimal"
    - "static-libs"
  accept_keywords: "amd64"
  ldflags:
    - "-Wl,-O1"
    - "-Wl,--as-needed"
    - "-Wl,--hash-style=gnu"
