#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' 

get_html_content() {
    local url=$1
    local html_content

    if html_content=$(curl -s --fail "$url"); then
        echo "$html_content"
    else
        echo "Error: Unable to fetch content from URL: $url" >&2
        exit 1
    fi
}

search_keyword() {
    local content=$1
    local keyword=$2
    local url=$3
    local found=false

    while IFS= read -r line; do
        if echo "$line" | grep --color=always -q "$keyword"; then
            found=true
            highlighted_line=$(echo "$line" | grep --color=always "$keyword")
            echo -e "Keyword '$keyword' found in the content."
            echo -e "Line: $highlighted_line"
            echo "URL: $url"
            echo
        fi
    done <<< "$content"

    if [ "$found" = false ]; then
        echo "Keyword '$keyword' not found in the content."
    fi
}

perform_osint() {
    local url=$1
    local keyword=$2

    echo "Fetching content from URL: $url"
    html_content=$(get_html_content "$url")

    echo "Searching for keyword: $keyword"
    search_keyword "$html_content" "$keyword" "$url"
}

if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl to use this script." >&2
    exit 1
fi

if ! command -v grep &> /dev/null; then
    echo "Error: grep is not installed. Please install grep to use this script." >&2
    exit 1
fi

echo -e "\e[32m=====Ｋｅｙｗｏｒｄ Ｓｃｒａｐｅｒ=====\e[0m"

read -p "Target URL:: " url
read -p "Keyword: " keyword

perform_osint "$url" "$keyword"
