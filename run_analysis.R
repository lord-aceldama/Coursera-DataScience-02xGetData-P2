analyze <- function(data_path = getwd())
{
  #-- Helper methods
  debug_print <- function(token, text="", lf=1){
    cat(paste(c(token, text, rep("\n", lf)), collapse=""))
  }
  
  set_path <- function(path) {
    revert <- NULL
    if (!is.null(path)) {
      if (!file.exists(path)) {
        debug_print("ERROR: ", "Couldn't change working directory...")      
        debug_print("  - ", "Path does not exist")
        debug_print("  - ", path)
      } else if (getwd() != path) {
        debug_print("INFO: ", "Changing working directory")
        debug_print("  - ", getwd())
        debug_print("  - ", path, lf=2)
        
        revert <- getwd()
        setwd(path)
      }
    }
    return(revert)
  }
  
  check_files <- function(...){
    flag <- T
    input <- c(...)
    debug_print("INFO: ", "Checking files")
    for (filename in input) {
      if (file.exists(filename)) {
        debug_print("   - [ OK ] ", filename)
      } else {
        debug_print("   - [FAIL] ", filename)
        flag <- F
      }
    }
    cat("\n")
    return(flag)
  }
  
  merge_tables <- function(f1, f2){
    debug_print("INFO: ", paste("Processing", f1, "and", f2, "tables"))
    debug_print("   - Reading ", f1)
    t1 <- read.table(f1)
    
    debug_print("   - Reading ", f2)
    t2 <- read.table(f2)
    
    debug_print("   - Merging tables...")
    merged <- rbind(t1, t2)
    
    debug_print("   - Done!",lf=2)
    return(merged)
  }
  
  
  #-- To make my life easier
  cat(paste("\n\n====[ STARTING JOB:", date(), "]====\n"))
  if (exists("DEBUG_MODE") && DEBUG_MODE)
  {
    debug_print("WARNING: ", "Debug Mode variable detected")
    debug_print("   - ", "If you are not me, please type rm(DEBUG_MODE) in the console", lf=2)
    data_path <- gsub("\\\\","/",paste(Sys.getenv("USERPROFILE"),"/Desktop/UCI HAR Dataset", sep=""))
  }

  #-- Make sure we're in the user-defined directory
  revert_path <- set_path(data_path)
  
  #-- check whether we have the necessary files
  if (!check_files("./train/x_train.txt",       "./test/x_test.txt", 
                   "./train/subject_train.txt", "./test/subject_test.txt",
                   "./train/y_train.txt",       "./test/y_test.txt")) {
    #-- We're missing one or more files
    debug_print("ERROR: ", "One or more of the training were missing.")
    
  } else if(!(file.exists("./features.txt") & file.exists("./activity_labels.txt"))) {
    #-- We're missing an all-important labling file
    debug_print("ERROR: ", "One or more of the descriptive files were missing.")
    
  } else {
    #-- Everything seems to be ok. We can now start! :D
    
    #-- Assignment Step 1: Merge the training and the test 
    #   sets to create one data set
    tX <- merge_tables("./train/X_train.txt",       "./test/X_test.txt")
    tS <- merge_tables("./train/subject_train.txt", "./test/subject_test.txt")
    tY <- merge_tables("./train/y_train.txt",       "./test/y_test.txt")
    
    #-- Assignment Step 2: Extract only the mean and standard deviation 
    #   for each measurement.
    debug_print("INFO: ", "Extracting just the mean and standard deviations")
    debug_print("   - ", "Reading the features table")
    features <- read.table("./features.txt", strip.white=T, stringsAsFactors=F)
    
    debug_print("   - ", "Extracting features")
    good_features <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
    tX <- tX[, good_features]
    names(tX) <- features[good_features, 2]
    names(tX) <- gsub("\\(|\\)", "", names(tX))
    names(tX) <- tolower(names(tX))
    debug_print("   - ", "Done!", lf=2)
    
    #-- Assignment Step 3: Use descriptive activity names to name the 
    #   activities in the data set.
    debug_print("INFO: ", "Finding fancy labels to use")
    debug_print("   - ", "Reading the activity table")
    tA <- read.table("./activity_labels.txt")
    debug_print("   - ", "Applying labels")
    tA[, 2] = gsub("_", "", tolower(as.character(tA[, 2])))
    tY[,1] = tA[tY[,1], 2]
    names(tY) <- "activity"
    debug_print("   - ", "Done!", lf=2)
    
    #-- Assignment Step 4: Label the data set with descriptive 
    #   extracted in step 3.
    debug_print("INFO: ", "Labelling the new dataset")
    debug_print("   - ", "Tacking on those fancy labels")
    names(tS) <- "subject"
    tC <- cbind(tS, tY, tX)
    fn <- "./data-cleaned.txt"
    debug_print("   - ", paste(c("Saving to \"", fn, "\"")))
    write.table(tC, fn, row.name=F)
    debug_print("   - ", "Done!", lf=2)
    
    #-- Assignment Step 5: Create a 2nd, independent tidy data set 
    #   with the average of each variable for each activity and 
    #   each subject.
    debug_print("INFO: ", "Creating an average dataset from clean data")
    debug_print("   - ", "Averaging")
    tS.unique = unique(tS)[,1]
    tS.total = length(tS.unique)
    tA.total = length(tA[,1])
    numCols = dim(tC)[2]
    tAvg = tC[1:(tS.total*tA.total), ]
    row = 1
    for (s in 1:tS.total) {
      for (a in 1:tA.total) {
        tAvg[row, 1] = tS.unique[s]
        tAvg[row, 2] = tA[a, 2]
        tmp <- tC[tC$subject==s & tC$activity==tA[a, 2], ]
        tAvg[row, 3:numCols] <- colMeans(tmp[, 3:numCols])
        row = row+1
      }
    }
    fn <- "./data-averages.txt"
    debug_print("   - ", paste(c("Saving to \"", fn, "\"")))
    write.table(tAvg, fn, row.name=F)
    debug_print("   - ", "Done!", lf=2)
  }
  
  #-- If the directory was changed, change it back to what it used to be
  set_path(revert_path)
  
  cat(paste("====[ JOB DONE:", date(), "]====\n\n\n"))
}