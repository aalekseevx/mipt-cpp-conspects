mkdir img
cp main_img/* img/
cp ./1st\ semester.\ Autumn\ 2019/img/* img/
cp ./2st\ semester.\ Spring\ 2020/img/* img/
cat readme.md > "conspect.md"
cat "1st semester. Autumn 2019"/* >>"conspect.md"
cat "2st semester. Spring 2020"/* >>"conspect.md"
grip conspect.md --export index.html
