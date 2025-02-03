# Run Matlab Scripts on a PBS Computing Cluster

This program enables you to perform large/computationally intensive jobs on a PBS (Portable Batch System) or SLURM (Simple Linux Utility for Resource Management) Computing Cluster directly out of Matlab. Some cluster providers do not support the Matlab integration of the MATLAB Parallel Server (formally Distributed Computing Server), e.g. due to license costs.

Philipp Kortmann, philipp.kortmann@imes.uni-hannover.de, 2018-04  
Moritz Schappler, moritz.schappler@imes.uni-hannover.de, 2020-09  
(C) Institut für Mechatronische Systeme, Leibniz Universität Hannover, Germany

## DESCRIPTION:

1. Create a folder (e.g.: 'upload') containing all (Matlab-) files necessary for the calculation. At the top level of this folder must be the m-Script that starts the complete program flow.
2. Make sure that all results of your Matlab calculations are also saved in a separate download folder as a subfolder of 'upload'.
  * can also be stored to an external storage which is accessed separately
3. Create a copy of the file `userSettings.m` from the `templateFiles` directory and put it in the root directory of this toolbox.
4. Enter all settings and SSH cluster user authentification, in particular your desired calculation resources in `userSettings.m` on.
  * in the current implementation the password has to be stored in clear text. Therefore restricting access to this file is a safety concern.
5. Start your job by executing `jobStart.m`. Make a note of the job ID you have been given (if Email is not set up).
6. The start and finish of your calculations will be communicated to you by e-mail, if supported by your cluster provider.
7. After completing the calculations, you can download your results by executing `jobDownload.m` and entering your JobID.

### Integration of the cluster support into Matlab toolchains

Starting cluster jobs via `jobStart` can be included in other Matlab programs. The interface description can be obtained from the file header.

### Hints:

- You can also start several jobs in a row without waiting for a previous job to finish.
- If a quick execution of your job is desired, the requested resources (especially the walltime) should be selected as low as possible.
- The start of cluster jobs with `jobStart.m` can also be done out of another Matlab script e.g. in a loop (check the functionality of your computations first to avoid spamming the cluster server).
- On first start-up, you need to connect to the cluster via ssh manually to add the server's key fingerprint to your ssh-manager cache. In the command line, use `plink -P 22 -ssh [YourUsername]@login.cluster.uni-hannover.de -pw [YourPassword]`

