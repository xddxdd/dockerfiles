local DockerJobArch(image, arch) = {
  "kind": "pipeline",
  "type": "docker",
  "name": image + "-" + arch,
  "clone": {
    "disable": true
  },
  "steps": [
    {
      "name": "check if build is required",
      "image": "dwdraju/alpine-curl-jq",
      "commands": [
        "curl https://api.github.com/repos/xddxdd/dockerfiles/commits/$DRONE_COMMIT | jq \".files[].filename\" | tr -d '\"' | grep -E '^dockerfiles/" + image + "/' && exit 0 || exit 78"
      ]
    },
    {
      "name": "clone repo",
      "image": "drone/git",
      "commands": [
        "git clone https://github.com/xddxdd/dockerfiles.git .",
        "git checkout $DRONE_COMMIT"
      ]
    },
    {
      "name": "build (WIP)",
      "image": "alpine",
      "commands": [
        "echo make " + image + "/" + arch
      ]
    }
  ]
};

local DockerJob(image) = [
  DockerJobArch(image, 'latest'),
  DockerJobArch(image, 'i386'),
  DockerJobArch(image, 'arm32v7'),
  DockerJobArch(image, 'arm64v8'),
  DockerJobArch(image, 'ppc64le'),
  DockerJobArch(image, 's390x'),
  DockerJobArch(image, 'riscv64'),
  DockerJobArch(image, 'x32')
];

[
  {
    "kind": "secret",
    "name": "tg_token",
    "get": {
      "path": "kv/data/telegram",
      "name": "token"
    }
  },
  {
    "kind": "secret",
    "name": "tg_target",
    "get": {
      "path": "kv/data/telegram",
      "name": "target"
    }
  },
]
+ DockerJob('atduck')
+ DockerJob('bird')
+ DockerJob('coredns')
+ DockerJob('dn42-pingfinder')
+ DockerJob('ip-holder')
+ DockerJob('nginx')
+ DockerJob('nyancat')
+ DockerJob('openresty')
+ DockerJob('php7-fpm')
+ DockerJob('powerdns')
+ DockerJob('powerdns-recursor')
+ DockerJob('route-chain')
+ DockerJob('sleep')
+ DockerJob('whois42d')
