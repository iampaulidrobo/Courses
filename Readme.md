Links:
https://developer.nvidia.com/blog/even-easier-introduction-cuda/




```bash
1)Make function global to be run on gpu and called from cpu
2)memory space allocation using unified memory cudamallcmanaged/als free   space after use + prefetch
3)run the function on gpu using triple bracket + (SM)blocksize+thread
4)synchronise so that cpu waits till the get results from the gpu
5)nsys for report management
```


Respected commands:
```bash
nvidia-smi

nvcc gpu.cu -o gpu

./nsys_easy/nsys_easy ./gpu  

#sudo nsys profile -t cuda --stats=true ./add_block

```
