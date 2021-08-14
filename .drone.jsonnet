local DockerJob(arch) = {
  "kind": "pipeline",
  "type": "docker",
  "name": arch,
  "steps": [
    {
      "name": "determine target images",
      "image": "alpine",
      "commands": [
        "touch target_images",
        "for F in $(echo \"DRONE_COMMIT_MESSAGE\" | cut -d':' -f1); do if [ -d dockerfiles/$F ]; then echo $F >> target_images; fi; done",
        "cat target_images"
      ]
    },
    {
      "name": "build (WIP)",
      "image": "alpine",
      "commands": [
        "for F in $(cat target_images); do echo make $F/" + arch + "; done"
      ]
    }
  ]
};

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
  DockerJob('latest'),
  DockerJob('i386'),
  DockerJob('arm32v7'),
  DockerJob('arm64v8'),
  DockerJob('ppc64le'),
  DockerJob('s390x'),
  DockerJob('riscv64'),
  DockerJob('x32')
]
