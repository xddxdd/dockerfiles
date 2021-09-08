local DockerJob(arch) = {
  "kind": "pipeline",
  "type": "docker",
  "name": arch,
  "volumes": [
    {
      "name": "dockersock",
      "host": {
        "path": "/var/run"
      },
    },
  ],
  "steps": [
    {
      "name": "determine target images",
      "image": "alpine",
      "commands": [
        "touch target_images",
        "for F in $(echo \"$DRONE_COMMIT_MESSAGE\" | cut -d':' -f1); do if [ -d dockerfiles/$F ]; then echo $F >> target_images; fi; done",
        "echo \"$DRONE_COMMIT_MESSAGE\"",
        "cat target_images",
        "[ \"$(cat target_images)\" = \"\" ] && exit 78"
      ],
      "when": {
        "event": [
          "push",
          "custom",
          "cron"
        ]
      }
    },
    {
      "name": "build",
      "image": "debian",
      "volumes": [
        {
          "name": "dockersock",
          "path": "/var/run"
        },
      ],
      "environment": {
        "DOCKER_USER": {
          "from_secret": "docker_user"
        },
        "DOCKER_PASS": {
          "from_secret": "docker_pass"
        },
      },
      "commands": [
        "apt-get update",
        "DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends make gpp docker.io",
        "docker login -u $DOCKER_USER -p $DOCKER_PASS",
        "for F in $(cat target_images); do make $F/" + arch + " || exit $?; done"
      ],
      "when": {
        "event": [
          "push",
          "custom",
          "cron"
        ]
      }
    },
    {
      "name": "telegram notification for failure",
      "image": "appleboy/drone-telegram",
      "settings": {
        "token": {
          "from_secret": "tg_token"
        },
        "to": {
          "from_secret": "tg_target"
        },
        "message": "❌ Build #{{build.number}} of `{{repo.name}}`/" + arch + " {{build.status}}.\n\n📝 Commit by {{commit.author}} on `{{commit.branch}}`:\n``` {{commit.message}} ```\n\n🌐 {{build.link}}"
      },
      "when": {
        "status": [
          "failure"
        ],
        "event": [
          "push",
          "custom",
          "cron"
        ]
      }
    },
    {
      "name": "telegram notification for success",
      "image": "appleboy/drone-telegram",
      "settings": {
        "token": {
          "from_secret": "tg_token"
        },
        "to": {
          "from_secret": "tg_target"
        },
        "message": "✅ Build #{{build.number}} of `{{repo.name}}`/" + arch + " {{build.status}}.\n\n📝 Commit by {{commit.author}} on `{{commit.branch}}`:\n``` {{commit.message}} ```\n\n🌐 {{build.link}}"
      },
      "when": {
        "status": [
          "success"
        ],
        "event": [
          "push",
          "custom"
        ]
      }
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
  {
    "kind": "secret",
    "name": "docker_user",
    "get": {
      "path": "kv/data/docker",
      "name": "username"
    }
  },
  {
    "kind": "secret",
    "name": "docker_pass",
    "get": {
      "path": "kv/data/docker",
      "name": "password"
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
