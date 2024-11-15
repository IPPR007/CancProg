
if (!requireNamespace("devtools", quietly = TRUE)) {  
  install.packages("devtools")  
}  

packages <- c(  
  "CBCgrps",  
  "survival",  
  "survminer",  
  "jskm",  
  "forestplot",  
  "mRMRe",  
  "pROC",  
  "rms",  
  "ggDCA",  
  "caret",  
  "yardstick"  
)  

install_if_missing <- function(package) {  
  if (!requireNamespace(package, quietly = TRUE)) {  
    tryCatch({  
      if (package == "ggDCA") {  
        devtools::install_github("yikeshu0611/ggDCA")  
      } else if (package == "CBCgrps") {  
        devtools::install_github("GangLiLab/CBCgrps")  
      } else {  
        install.packages(package, dependencies = TRUE)  
      }  
      print(paste("Successfully installed", package))  
    }, error = function(e) {  
      print(paste("Error installing", package, ":", e$message))  
    })  
  } else {  
    print(paste(package, "is already installed"))  
  }  
}  

# install package
for (pkg in packages) {  
  install_if_missing(pkg)  
}  

check_packages <- function() {  
  missing_packages <- character()  
  for (pkg in packages) {  
    if (!requireNamespace(pkg, quietly = TRUE)) {  
      missing_packages <- c(missing_packages, pkg)  
    }  
  }  
  if (length(missing_packages) > 0) {  
    print("Missing package: ")  
    print(missing_packages)  
  } else {  
    print("Congratulations!")  
  }  
}  

check_packages()  

load_packages <- function() {  
  for (pkg in packages) {  
    tryCatch({  
      library(pkg, character.only = TRUE)  
      print(paste("Successfully loaded", pkg))  
    }, error = function(e) {  
      print(paste("Error loading", pkg, ":", e$message))  
    })  
  }  
}  