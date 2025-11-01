docker run \
  --user $(id -u):$(id -g) \
  -e http_proxy=$http_proxy \
  -e https_proxy=$https_proxy \
  -e no_proxy=$no_proxy \
  -p 7860:7860 \
  -v /nfs/site/home/hfeng1:/nfs/site/home/hfeng1 \
  -v /nfs:/nfs \
  -v /usr/intel:/usr/intel \
  coder:latest
