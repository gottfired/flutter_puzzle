flutter build web --base-href /pushtrix/ --web-renderer canvaskit
echo "Now copy ..."
cp -a build/web/. ../pushtrix/docs/
