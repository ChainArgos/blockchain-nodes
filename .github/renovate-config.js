// Global Renovate configuration for the self-hosted runner fleets.
//
// The Velnor runner does not evaluate secret-bearing strings embedded in
// env values (they arrive as literal ${{ }} expressions), so credentials
// must reach the container as plain secret environment variables and be
// assembled here, inside the Renovate process. DOCKERHUB_USERNAME and
// DOCKERHUB_TOKEN are pure secret references passed through the action's
// env-regex; repository config stays in renovate.json.
module.exports = {
  hostRules: [
    {
      matchHost: "index.docker.io",
      username: process.env.DOCKERHUB_USERNAME,
      password: process.env.DOCKERHUB_TOKEN,
    },
  ],
};
