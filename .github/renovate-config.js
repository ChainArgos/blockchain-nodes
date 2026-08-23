// Global Renovate configuration for the self-hosted runner fleets.
//
// The Velnor runner does not evaluate secret-bearing strings embedded in
// env values (they arrive as literal ${{ }} expressions), and the fleet
// capability manifest forbids the action's configurationFile input, so
// credentials must reach the container as plain RENOVATE_* secret
// environment variables (matched by the action's default env passthrough)
// and be assembled here, inside the Renovate process. The workflow copies
// this file to /tmp and points RENOVATE_CONFIG_FILE at the copy because
// the container only mounts /tmp. Repository config stays in renovate.json.
module.exports = {
  hostRules: [
    {
      matchHost: "index.docker.io",
      username: process.env.RENOVATE_DOCKERHUB_USERNAME,
      password: process.env.RENOVATE_DOCKERHUB_TOKEN,
    },
  ],
};
