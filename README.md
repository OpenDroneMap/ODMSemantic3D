# ODMSemantic3D
Open dataset of classified 3D points for semantic segmentation

This repository contains the classified point clouds for training the OpenPointClass model. You can download the latest built model in the releases page.

## Classify your own point cloud

You can easily classify your own point cloud using [CloudCompare](https://www.danielgm.net/cc/). To do so, you need to follow the next steps:
- Open your point cloud in CloudCompare
- Check for field `Properties > Scalar field > Classification`. Otherwise you can add it by going to `Edit > Add scalar field > Classification`

![add-scalar-field](https://user-images.githubusercontent.com/7868983/235640470-5986f162-4adf-45db-934e-cc8fe65c5a9b.gif)

- Start classifying by going to `Edit > Segment` (or just press T)

- These classes are advised:

  | Label | Number |
  | ----------- | ----------- |
  | ground | 1 |
  | low_vegetation | 2 |
  | building | 5 |
  | human_made_object | 20 |

- Create a poligon you want to classify. Right click to close it.
- Press C to assign a class

![classify-proc](https://user-images.githubusercontent.com/7868983/235640600-f683affb-ddfc-4a71-888e-479465d29be8.gif)


- Once you are done, you can export the point cloud by going to `File > Save as...` and selecting the `.laz` format (not version 1.3 or 1.4)

Only If you used different numbers from those above, you have to create a json with the same name as the point cloud with the following format:

```json
{
    "source": "[POINT CLOUD SOURCE URL]",
    "classification": {
        "2": "ground",
        "3": "low_vegetation",
        "64": "human_made_object",
        "6": "building"
    }
}
```

## Contribute
You can contribute to this repository by adding new point clouds. To do so, you need to follow the next steps:
- [Register on github.com](https://github.com/signup) (if you haven't already)
- Open "datasets" folder
- Click on Add file -> Upload files
- Upload the classified point cloud (supported formats are `.las`, `.laz` and `.ply`)
- Open a pull request
- CI will run the training automatically and will post the statistics in the pull request
- If the PR is accepted, the point cloud will be added to the dataset and a new release of the model will be created

## Citation

> *OpenDroneMap Authors*: ODMSemantic3D - Open dataset of classified 3D points for semantic segmentation. <https://github.com/OpenDroneMap/ODMSemantic3D>
