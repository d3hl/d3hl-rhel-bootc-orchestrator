# bootc_image_render

Renders the `IMAGE-001` bootc build context from templates under `images/templates/`.

The role does not build, push, or boot images. It only materializes a local build
directory for a separately approved `sudo podman build` step.
