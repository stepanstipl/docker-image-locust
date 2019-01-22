# docker-image-locust

This images is based on Alpine and designed to be compatible with the Locust
chart we use. It also adds certificates for Let's Encrypt Staging, as we use
these for our dev environments.

## Building

### Master

On push/merge to master, CI will automatically build and push `gpii/locust:latest`
image.

### Tags

Create and push git tag and CI will build and publish corresponding`
`gpii/locust:${git_tag}` docker image.

### Manually

Run `make` to see all available steps.

- `make build` to build image as latest
- `make push` to push this image to registry
