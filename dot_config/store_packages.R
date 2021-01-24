tmp <- utils::installed.packages()

installed_packages <- as.vector(tmp[is.na(tmp[,"Priority"]), 1])
save(installed_packages, file = "~/.config/installed_packages.rda")