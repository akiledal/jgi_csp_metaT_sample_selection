#!/bin/bash

# Define variables
RMD_FILE="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection/202501_jgi_csp_transcriptomes.Rmd"
HTML_OUTPUT="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection/202501_jgi_csp_transcriptomes.html"
TSV_FILE="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection/requested_samples.tsv"
GIT_REPO="/geomicro/data2/kiledal/projects/202501_CSP_metaT_selection"
COMMIT_MSG="Automated update of rendered R Markdown document"
BRANCH="main"
CHECKSUM_FILE="$GIT_REPO/.last_checksum"

# Step 1: Render the R Markdown file to HTML
singularity run docker://eandersk/r_microbiome Rscript -e "rmarkdown::render('$RMD_FILE', output_file='$HTML_OUTPUT')"

# Step 2: Navigate to the git repository
cd $GIT_REPO || exit

# Step 3: Compute the current checksum of the TSV file
CURRENT_CHECKSUM=$(md5sum "$TSV_FILE" | awk '{print $1}')

# Step 4: Compare with the previous checksum
if [[ -f $CHECKSUM_FILE ]]; then
  PREVIOUS_CHECKSUM=$(cat "$CHECKSUM_FILE")
else
  PREVIOUS_CHECKSUM=""
fi

if [[ "$CURRENT_CHECKSUM" == "$PREVIOUS_CHECKSUM" ]]; then
  echo "No changes detected in $TSV_FILE."
  exit 0
fi

# Step 5: Save the current checksum for future comparisons
echo "$CURRENT_CHECKSUM" > "$CHECKSUM_FILE"

# Step 6: Add changes to the staging area
git add "$TSV_FILE" "$HTML_OUTPUT" "$RMD_FILE"

# Step 7: Commit changes with a message
git commit -m "$COMMIT_MSG"

# Step 8: Push changes to the remote repository
git push origin $BRANCH