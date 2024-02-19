#!/usr/bin/env zsh

for pdf_file in *.pdf; do
    total_pages=$(pdfinfo "$pdf_file" | grep "Pages" | awk '{print $2}')
    
    for ((page=1; page<=$total_pages; page++)); do
        pdf2svg "$pdf_file" "${pdf_file%.pdf}_page${page}.svg" $page
    done
done