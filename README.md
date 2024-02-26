# Development and Validation of Velocimeter LIDAR Simulator
Calibrating point clouds and velocimetry from a FMCW Lidar sensor against simulations from a rendering software.

_Status_ (Jan 2024): Lidar simulation validated with hardware. Statistically agreements/disagreements between rendered and real-data are reported (results below, paper to follow). 

_Process_: We collect FMCW datasets from real-world scenes using Aeva 4D Lidar (example). We collect the ground truth trajectory information (poses, velocities) using vicon system. 3D assets are generated from dense reconstruction of the real-world scene with elaborating filtering methods. We simulate the physics of the FMCW Lidar using a custom ray-tracing software built at [LASR laboratory](https://lasr.tamu.edu/). Ultimately, we compare the statistically similarities between the rendered and the sensor outputs. 

_Note_: We used two datasets (shown below) to validate our results. Datasets and rendering softwares are not public yet. Reach out to [me](bhaskara@tamu.edu) for details. 


## Results

<div align="center">
  <div style="display: inline-block; margin: 10px;">
    <img src="./results/coordinateFrames_dark.png" alt="poses" style="width:300px;"/> <br/>
  <em>Camera poses around reconstructed point cloud object in world frame</em>
  </div>

  <div style="display: inline-block; margin: 10px;">
    <img src="./results/vehicleTrajectory_AstWall.png" alt="Vehicle trajectory" style="width:300px;"/> <br/>
  <em>Reconstructed point cloud and ground truth trajectory from vicon</em> 
  </div>
</div>

<div align="center">
  <div style="display: inline-block; margin: 10px;">
    <img src="./results/narpaVelocimetryRocket.png" alt="synthetic velocimetry" style="width:300px;"/> <br/>
  <em>Reconstructed point cloud and point velocities</em>
  </div>

  <div style="display: inline-block; margin: 10px;">
    <img src="./results/MAD_acrossFrames.png" alt="Median abs deviation" style="width:300px;"/> <br/>
  <em>Median Absolute Deviations (MAD) of point velocities from NaRPA (red) and Aeva lidar (blue), within 1-sigma of velocities from sensor</em>
  </div>
</div>


## BibTeX Citation

If you use our software/approach/analysis in a scientific publication, we would appreciate using the following citations:

```
@article{eapen2022narpa,
  title={NaRPA: Navigation and Rendering Pipeline for Astronautics},
  author={Eapen, Roshan Thomas and Bhaskara, Ramchander Rao and Majji, Manoranjan},
  journal={arXiv preprint arXiv:2211.01566},
  year={2022}
}

@software{Lidar_velocimeter_validation,
  author = {Ramchander Bhaskara, Manoranjan Majji},
  doi = {},
  month = {1},
  title = {{My Research Software}},
  url = {https://github.com/ram-bhaskara/Lidar-velocimeter},
  version = {1.0.0},
  year = {2024}
}
```

## License

This project is licensed under the [Attribution-NonCommercial-NoDerivs 3.0 Unported (CC BY-NC-ND 3.0)](LICENSE) License.
