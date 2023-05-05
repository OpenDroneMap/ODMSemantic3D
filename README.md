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
You can contribute to this repository by adding new point clouds. To do so, you need to follow the these steps:
- [Register on github.com](https://github.com/signup) (if you haven't already)
- Open the [ODMSemantic3D repository](https://github.com/OpenDroneMap/ODMSemantic3D)
- Click on the **Fork** button in the top right corner

![create-fork](https://user-images.githubusercontent.com/132681251/236490639-a1a4e61a-558d-455c-84aa-b1b847a2ba48.png)

- Create the fork in your account

![create-fork-next](https://user-images.githubusercontent.com/132681251/236491057-dbfbe926-510e-49d1-8785-e7d7639f6642.png)

- In your fork, open the `datasets` folder

![click-on-datasets-folder](https://user-images.githubusercontent.com/132681251/236491397-cff1ad31-1727-4243-b728-2d20c9bc348e.png)


- In the top right corner, click on `Add file -> Upload files`

![upload-files](https://user-images.githubusercontent.com/7868983/236491752-461552fa-0560-4c0f-b8df-515c5b930a40.png)

- Upload the classified point cloud (supported formats are `.las`, `.laz` and `.ply`) by tragging them to the upload area or by clicking on `choose your files`.
- Add a **commit message** and select `Create a new branch`, then click on `Commit changes`

![commit-changes](https://user-images.githubusercontent.com/7868983/236492735-6b6e2fe2-abee-46cb-9627-d05134c29f11.png)

- Click on `compare across forks` and select `OpenDroneMap/ODMSemantic3D` repository as base and `main` as base branch. Add a title and a description for the pull request and click on `Create pull request`

![create-pull-request](https://user-images.githubusercontent.com/7868983/236492950-779cc623-44ed-44ae-b8d9-bf468e0d07b9.png)

- Github will run the training automatically and will post the statistics in the pull request as a comment.
- If the PR is accepted, the point cloud will be added to the repository and a new release of the model will be created.

## Citation

> *OpenDroneMap Authors*: ODMSemantic3D - Open dataset of classified 3D points for semantic segmentation. <https://github.com/OpenDroneMap/ODMSemantic3D>
