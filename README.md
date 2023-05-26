# ODMSemantic3D - An open photogrammetry dataset of classified 3D point clouds for automated semantic segmentation

Datasets are automatically trained and evaluated with [OpenPointClass](https://github.com/uav4geo/OpenPointClass) and the latest AI models can be downloaded from the [releases](https://github.com/OpenDroneMap/ODMSemantic3D/releases) page.

The resulting models are used to improve the automated classifier in [ODM](https://github.com/OpenDroneMap/ODM).

## Contribute a point cloud

We recommend to process an image dataset with [ODM](https://github.com/OpenDroneMap/ODM) or [WebODM](https://github.com/OpenDroneMap/WebODM) and turn on the `pc-classify` option, which will automatically assign classification values to a point cloud. Some will be incorrect, but it's easier than starting from scratch. 

Once you have generated a point cloud (`odm_georeferenced_model.laz`), you can import it in [CloudCompare](https://www.danielgm.net/cc/). **Use the latest stable release, not the alpha versions**.

Then:
- Select `Properties > Scalar field > Classification`.

If you are starting from an unclassified point cloud you can initialize the classification values by going to `Edit > Add scalar field > Classification`

![add-scalar-field](https://user-images.githubusercontent.com/7868983/235640470-5986f162-4adf-45db-934e-cc8fe65c5a9b.gif)

- Start classifying/cleaning the point cloud by going to `Edit > Segment` (press **T**)

- Draw a polygon around the points you want to classify. Right click closes the polygon.

- Press **C** to assign [ASPRS LAS codes](https://github.com/uav4geo/OpenPointClass#supported-classes):

At a minimum, the point cloud should have the following classification codes:

| Class | Number | Description |
--------|---------|-------------|
| ground | 2 | Earth's surface such as soil, gravel, or pavement |  |
| low_vegetation | 3 | Any generic type of vegetation like grass, bushes, shrubs, and trees |
| building | 6 | Man-made structures such as houses, offices, and industrial buildings |
| human_made_object | 64 | Any artificial objects not classified as buildings, such as vehicles, street furniture |

![classify-proc](https://user-images.githubusercontent.com/7868983/235640600-f683affb-ddfc-4a71-888e-479465d29be8.gif)

- When you are done, you can export the point cloud by going to `File > Save as...` and selecting the `.laz` format. Select **LAZ version 1.2** when exporting the file to .laz (not 1.3 or 1.4, which have issues with CloudCompare).

### Open a pull request

You can contribute to this repository by adding new point clouds. They will be automatically evaluated and trained for you! To do so, you need to follow these steps:

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

- Upload the classified point cloud (.laz` only) by dragging them to the upload area or by clicking on `choose your files`.
- Describe the point cloud you are adding in the **commit message** field and select `Create a new branch`, then click on `Commit changes`

![commit-changes](https://user-images.githubusercontent.com/7868983/236492735-6b6e2fe2-abee-46cb-9627-d05134c29f11.png)

- Click on `compare across forks` and select `OpenDroneMap/ODMSemantic3D` repository as base and `main` as base branch. Add a title and a description for the pull request and click on `Create pull request`

![create-pull-request](https://user-images.githubusercontent.com/7868983/236492950-779cc623-44ed-44ae-b8d9-bf468e0d07b9.png)

- Github will run the training automatically and will post evaluation statistics in the pull request as a comment.

- If the PR is accepted, the point cloud will be added to the repository and the new model will be published in a new release.

## Citation

> *OpenDroneMap Contributors*: ODMSemantic3D - An open photogrammetry dataset of classified 3D point clouds for automated semantic segmentation. <https://github.com/OpenDroneMap/ODMSemantic3D>
