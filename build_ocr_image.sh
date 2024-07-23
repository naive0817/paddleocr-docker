#!/bin/bash

set -e

# clone paddleocr
if [ ! -d PaddleOCR ]; then

    export http_proxy="http://myproxy"
    export https_proxy="http://myproxy"
    git clone -b release/2.7 --single-branch https://github.com/PaddlePaddle/PaddleOCR.git
    unset http_proxy
    unset https_proxy
fi

# 创建模型目录
MODEL_DIR=PaddleOCR/inference
mkdir -p $MODEL_DIR

# 定义模型
# 检测模型
DET=ch_PP-OCRv4_det_infer
# https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/$REC.tar

# 识别模型
REC=ch_PP-OCRv4_rec_infer
# https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/$REC.tar

# 方向分类器
CLS=ch_ppocr_mobile_v2.0_cls_infer
# https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/$CLS.tar

# 关键信息抽取SER模型
SER=ser_vi_layoutxlm_xfund_infer
# https://paddleocr.bj.bcebos.com/ppstructure/models/vi_layoutxlm/$SER.tar

# 关键信息抽取RE模型
RE=re_vi_layoutxlm_xfund_infer
# https://paddleocr.bj.bcebos.com/ppstructure/models/vi_layoutxlm/$RE.tar

# 检查模型是否存在
CHECK_MODEL() {
    if [ ! -d $MODEL_DIR/$1 ]; then
        case $1 in
        $DET)
            echo "Downloading $DET model..."
            wget https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/$DET.tar -P $MODEL_DIR
            tar -xf $MODEL_DIR/$DET.tar -C $MODEL_DIR
            rm -rf $MODEL_DIR/$DET.tar
            ;;
        $REC)
            echo "Downloading $REC model..."
            wget https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/$REC.tar -P $MODEL_DIR
            tar -xf $MODEL_DIR/$REC.tar -C $MODEL_DIR
            rm -rf $MODEL_DIR/$REC.tar
            ;;
        $CLS)
            echo "Downloading $CLS model..."
            wget https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/$CLS.tar -P $MODEL_DIR
            tar -xf $MODEL_DIR/$CLS.tar -C $MODEL_DIR
            rm -rf $MODEL_DIR/$CLS.tar
            ;;
        $SER)
            echo "Downloading $SER model..."
            wget https://paddleocr.bj.bcebos.com/ppstructure/models/vi_layoutxlm/$SER.tar -P $MODEL_DIR
            tar -xf $MODEL_DIR/$SER.tar -C $MODEL_DIR
            rm -rf $MODEL_DIR/$SER.tar
            ;;
        $RE)
            echo "Downloading $RE model..."
            wget https://paddleocr.bj.bcebos.com/ppstructure/models/vi_layoutxlm/$RE.tar -P $MODEL_DIR
            tar -xf $MODEL_DIR/$RE.tar -C $MODEL_DIR
            rm -rf $MODEL_DIR/$RE.tar
            ;;
        *)
            echo "Unknown model: $1"
            exit 1
            ;;
        esac
    fi
}

CHECK_MODEL $DET
CHECK_MODEL $REC
CHECK_MODEL $CLS
CHECK_MODEL $SER
CHECK_MODEL $RE

# 修改PaddleOCR的配置文件, 替换模型

# 修改ocr_det/params.py
sed -i 's#det_model_dir.*$#det_model_dir = "./inference/'$DET'/"#' PaddleOCR/deploy/hubserving/ocr_det/params.py

# 修改ocr_rec/params.py
sed -i 's#rec_model_dir.*$#rec_model_dir = "./inference/'$REC'/"#' PaddleOCR/deploy/hubserving/ocr_rec/params.py

# 修改ocr_cls/params.py
sed -i 's#cls_model_dir.*$#cls_model_dir = "./inference/'$CLS'/"#' PaddleOCR/deploy/hubserving/ocr_cls/params.py

# 修改ocr_system/params.py
sed -i 's#det_model_dir.*$#det_model_dir = "./inference/'$DET'/"#' PaddleOCR/deploy/hubserving/ocr_system/params.py
sed -i 's#rec_model_dir.*$#rec_model_dir = "./inference/'$REC'/"#' PaddleOCR/deploy/hubserving/ocr_system/params.py
sed -i 's#cls_model_dir.*$#cls_model_dir = "./inference/'$CLS'/"#' PaddleOCR/deploy/hubserving/ocr_system/params.py

# 修改kie_ser_re/params.py
sed -i 's#ser_model_dir.*$#ser_model_dir = "./inference/'$SER'/"#' PaddleOCR/deploy/hubserving/kie_ser_re/params.py
sed -i 's#re_model_dir.*$#re_model_dir = "./inference/'$RE'/"#' PaddleOCR/deploy/hubserving/kie_ser_re/params.py

# 修复项目里的一个错误的路径
sed -i 's#ser_dict_path.*$#ser_dict_path = "./ppocr/utils/dict/kie_dict/xfund_class_list.txt"#' PaddleOCR/deploy/hubserving/kie_ser_re/params.py

docker build -t my-paddleocr:latest .
