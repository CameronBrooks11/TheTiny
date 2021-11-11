
## Contributing

### General
Please add yourself as an author in `README.md`, your contribution is valued.

Please squash your commits before putting up a pull request.

### Layers
Before adding or a splitting a layer consider making a ticket to discuss your idea

If you add or split a layer make sure you do the following:
- Add it to `README.md`
- Add a variable for it to `house.scad` in the configuration section
- Wrap the inclusion of your layer in an `if` statement using the variable you just created
- Add your layer to `.github/workflows/screenshot.yml` in the reverse order of the `README.md` entry
- Add the screenshot of your new layer to the artifact upload step of `.github/workflows/screenshot.yml` 

### Methods
Before adding or changing a method consider making a ticket to discuss your idea

If you add or change a method make sure you do the following:
- Add your method to `README.md`
- Add several examples to `README.md`
