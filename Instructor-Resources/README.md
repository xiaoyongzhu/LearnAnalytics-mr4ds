Resources for Redelivery
=========================

The materials in this directory will prove useful to create the class assets. By assets I mean the resources in the [Student Resources](https://github.com/Azure/mr4ds/tree/master/Student-Resources) directory. 

Before you can create the lab materials, you'll need an environment with MRS 9.0.1 and MicrosftML. Instructions for getting this are [here](https://github.com/Azure/mr4ds/wiki/Microsoft-R-Server-Installation-Instructions). 

Once you have a working MRS environment, you'll need to do the following

1. Fork the materials to your github account. Then clone (change the url to your account):
	- `git clone https://github.com/Azure/mr4ds.git`
1. [0-pkgs-install.R](https://github.com/Azure/mr4ds/blob/master/Instructor-Resources/0-pkgs-install.R)
	- go into the _Instructor Resources_ folder: `cd mr4ds/Instructor-Resources/`
	- run the packages installation script by typing `Rscript ./0-pkgs-install.R`
	- this will install all the R packages you need to run the environment
	- by default it'll use the last snapshot of the packages that are known to work with our materials
	- if you like to live on the edge, use the latest mirror of CRAN `Rscript ./0-pkgs-install.R "latest"`
2. [1-render-modules.R](https://github.com/Azure/mr4ds/blob/master/Instructor-Resources/1-render-modules.R)
	- render all course Rmds into PDFs/htmls
	- You'll need to be in `mr4ds` folder, so `cd ../` if you are currently `mr4ds/Instructor-Resources`
	- render the materials: `Rscript Instructor-Resources/1-render-modules.R`
3. [2-convert-rmd-ipynb.sh](https://github.com/Azure/mr4ds/blob/master/Instructor-Resources/2-convert-rmd-ipynb.sh)
	- If you want jupyter notebooks as well
	- `Rscript Instructor-Resources/2-convert-rmd-ipynb.sh`
4. [create-users.py](https://github.com/Azure/mr4ds/blob/master/Instructor-Resources/create_users.py)
	- If you're creating a VM for the students, this script will create a set of user accounts with password
	- `python Instructor-Resources/create_users.py`