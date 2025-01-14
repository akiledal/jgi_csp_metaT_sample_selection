#!/bin/bash

# Define variables
RMD_FILE="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection/202501_jgi_csp_transcriptomes.Rmd"
HTML_OUTPUT="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection/202501_jgi_csp_transcriptomes.html"
GIT_REPO="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection"
COMMIT_MSG="Automated update of rendered R Markdown document"
BRANCH="main"

# Step 1: Render the R Markdown file to HTML
singularity run docker://eandersk/r_microbiome Rscript -e "rmarkdown::render('$RMD_FILE', output_file='$HTML_OUTPUT')"

# Step 2: Navigate to the git repository
cd $GIT_REPO || exit

# Step 3: Check if there are changes to commit
if git diff --quiet && git diff --cached --quiet; then
  echo "No changes to commit."
else
  # Step 4: Add changes to the staging area
  git add .

  # Step 5: Commit changes with a message
  git commit -m "$COMMIT_MSG"

  # Step 6: Push changes to the remote repository
  git push origin $BRANCH
fi