# JM OS Custom Fonts

To apply your premium font (Inter, Google Sans, etc.), place the following `.ttf` files in this directory:

- `Inter-Regular.ttf`
- `Inter-Italic.ttf`
- `Inter-Medium.ttf`
- `Inter-MediumItalic.ttf`
- `Inter-Bold.ttf`
- `Inter-BoldItalic.ttf`

If you are using a different font (like Google Sans), simply rename your files to match these or update `vendor/jmos/prebuilt/common/etc/fonts.xml`.

The build system will automatically inject these into `/system/fonts/` and set them as the system default.
