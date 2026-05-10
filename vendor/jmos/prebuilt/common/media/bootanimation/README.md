# JM OS Boot Animation Instructions

1. **Frames**: Place your animation frames (PNG format) in `part0` and `part1` directories.
2. **Configuration**: Edit `desc.txt` if you need to change resolution or frame rate.
3. **Zipping**: Select `part0`, `part1`, and `desc.txt`, then zip them.
   - **IMPORTANT**: You MUST use "Store" compression (no compression) for the zip file.
   - Name the file `bootanimation.zip`.
   - Place it in `vendor/jmos/prebuilt/common/media/`.

The build system will then pick it up and inject it into your ROM.
