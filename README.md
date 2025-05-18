# The Tiny

The plans included here are for your classic 8'x20' tiny house.

![The Tiny](images/house.png?raw=true "The Tiny")

To view or change these plans you will need [OpenSCAD](https://openscad.org/)

Certain lumber choices are set for this plan:

Floor:

- 2"x6"x8'
- 4'x8'x3/4"

Wall:

- 2"x4"8'

## Configuration

Various aspects of this plan can be changed on the fly. To change options it will be helpful to understand
the `Methods` available to you.

#### Methods

| Method            | Return Type | Description                                                                                                             |
| :---------------- | :---------- | :---------------------------------------------------------------------------------------------------------------------- |
| inches(i,&nbsp;f) | `float`     | `i` is an interger, or full inch measurements. For fractional inches specify them as `f`. The math behind this is `i+f` |
| feet(f)           | `int`       | `f` is the number of feet you want to convert into inches. The math behind this is `f * 12`                             |

Examples:  
| Measurement | Method |
| :---------- | :------------------------- |
| 6" | `inches(6)` |
| 6 1/2" | `inches(6, 1/2)` |
| 4' 3" | `feet(4) + inches(3)` |
| 4' 7 1/8" | `feet(4) + inches(7, 1/8)` |

#### Options

| Variable                   | Type      | Default                         | File         | Description                                                               |
| :------------------------- | :-------- | :------------------------------ | :----------- | :------------------------------------------------------------------------ |
| `show_frame_floor`         | `boolean` | 1                               | `house.scad` | Show or hide floor framing, `1` to show, `0` to hide                      |
| `show_sheet_floor`         | `boolean` | 1                               | `house.scad` | Show or hide floor sheeting, `1` to show, `0` to hide                     |
| `show_frame_walls`         | `boolean` | 1                               | `house.scad` | Show or hide wall framing, `1` to show, `0` to hide                       |
| `wall_height`              | `inches`  | feet(8)                         | `house.scad` | Total wall framing height, this includes both top plates and bottom plate |
| `frame_floor_start_height` | `inches`  | 0                               | `house.scad` | The height to start floor framing at                                      |
| `sheet_floor_start_height` | `inches`  | inches(5, 1/2)                  | `house.scad` | The height to start floor sheeting at                                     |
| `frame_walls_start_height` | `inches`  | inches(5, 1/2) + inches(0, 3/4) | `house.scad` | The height to start framing the walls at                                  |

## Layers

The house is built up of several layers to make editing and sharing among the community easier. Layers are listed just like you would build a house, from the bottom up.

- `frame_walls.scad`
- `sheet_floor.scad`
- `frame_floor.scad`

Right now the only contract between each layer is the `start_height` variable that gets passed into each layer. When the house supports the ability to resize both width and length, additional variables will be added and documented.

## Contributing

Contributions are always welcome!

See `CONTRIBUTING.md` for ways to get started.

## Authors

- [@jjshoe](https://www.github.com/jjshoe)
- [@CameronBrooks11](https://github.com/CameronBrooks11)

## License

[AGPLv3.0](https://www.gnu.org/licenses/agpl-3.0.en.html)
