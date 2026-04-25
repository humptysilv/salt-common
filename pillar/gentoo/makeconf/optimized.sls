# Optimized make.conf settings for performance-focused builds
# Inherits defaults and overrides with aggressive optimization flags

makeconf:
  cflags:
    - "-O2"
    - "-pipe"
    - "-march=native"
    - "-fomit-frame-pointer"
    - "-fstack-protector-strong"
  cxxflags: "${CFLAGS}"
  makeopts: "-j{{ grains['num_cpus'] + 1 }}"
  features:
    - "parallel-fetch"
    - "parallel-install"
    - "buildpkg"
    - "ccache"
  emerge_default_opts:
    - "--jobs={{ grains['num_cpus'] }}"
    - "--load-average={{ grains['num_cpus'] }}"
    - "--keep-going"
    - "--with-bdeps=y"
  use_flags:
    - "threads"
    - "openmp"
    - "-debug"
    - "-test"
  # Increased from 10G - my machine has plenty of disk space and
  # large ccache hits a noticeable speedup on repeated rebuilds
  # Bumped further to 30G after filling 20G regularly with Chromium/Firefox builds
  ccache_size: "30G"
  ccache_dir: "/var/cache/ccache"
  portdir_overlay:
    - "/usr/local/portage"
  accept_keywords: "~amd64"
