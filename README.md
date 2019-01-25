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

#### Tag format

Tags should follow actual locust version, suffixed by
`-gpii.${gpii_build_number}`, where `gpii_build_number` is monotonically
increasing number denoting Docker image build number,  starting from `0`
for each upstream version.

Example:
```
0.9.0-gpii.0
0.9.0-gpii.1
0.9.0-gpii.2
...
0.9.1-gpii.0
```

### Manually

Run `make` to see all available steps.

- `make build` to build image as latest
- `make push` to push this image to registry
