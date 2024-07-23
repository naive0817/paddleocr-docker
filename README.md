# paddleocr-docker
基于 [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) `hubserving` 方式的docker构建

## 构建docker

```bash
chmod +x build_ocr_image.sh
./build_ocr_image.sh
```

注: 如果只需要文本ocr, 删除掉多余的`ser`, `re`模型, 并修改`Dockerfile`中的执行语句为`hub install /PaddleOCR/deploy/hubserving/kie_ser_re/ && hub serving start -m kie_ser_re`即可. 参考[PaddleOCR文档](https://github.com/PaddlePaddle/PaddleOCR/blob/main/deploy/hubserving/readme.md)


## 运行docker

```bash
docker run -d --name paddleocr -p 8866:8866 --restart=always my-paddleocr:latest
```