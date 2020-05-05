# try:
#   import unzip_requirements
# except ImportError:
#   pass


import json
import boto3
import os
import numpy as np
import base64
import io
import cv2


#--- load featured color values 
THIS_FOLDER = os.getcwd()
model_file = os.path.join(THIS_FOLDER, 'cols_runway.txt')

f = open(model_file, "r")
col_vals = f.read().splitlines()
f.close()

col_vals = [int(val) for val in col_vals]

#--- pixel values of the map feature
min_R, max_R = col_vals[0], col_vals[1] 
min_G, max_G = col_vals[2], col_vals[3]  
min_B, max_B = col_vals[4], col_vals[5] 


def decode_base64_to_cv2(img_b64):
    img = base64.urlsafe_b64decode(img_b64)
    img_io = io.BytesIO(img)
    img_np = np.frombuffer(img_io.read(), dtype=np.uint8)
    img_cv2 = cv2.imdecode(img_np, cv2.IMREAD_COLOR)
    pic = cv2.cvtColor(img_cv2, cv2.COLOR_BGR2RGB)
    return pic  # 256x256x3 


#--- return 256x256 number of (r,g,b) tuples
def pic_val_count(pic):
    reshaped_pic = np.reshape(pic, (pic.shape[0] * pic.shape[1], 3))
    reshaped_pic = reshaped_pic.tolist()
    reshaped_pic = [tuple(pixel) for pixel in reshaped_pic]

    col_count = []
    for i in set(reshaped_pic):
        (col_val, num_pic) = i, reshaped_pic.count(i)
        col_count.append((col_val, num_pic))
    return col_count


#--- return if the image is map feature
def classify_feature_image(img_cv2, pix_cutoff=50):
    result = 0
    for pic_val, num in pic_val_count(img_cv2):
        if ((min_R <= pic_val[0] <= max_R)
            &(min_G <= pic_val[1] <= max_G)
            &(min_B <= pic_val[2] <= max_B)
            &(num > pix_cutoff)):
                result = 1
    return result


def inferHandler(event, context):
    body_txt = event['body']
    body_json = json.loads(body_txt)
    z = body_json['z'] 
    x = body_json['x']
    y = body_json['y']
    tile_base64 = body_json['tile_base64']
    img_cv2 = decode_base64_to_cv2(tile_base64)

    predictions = classify_feature_image(img_cv2)

    if predictions == 0:
        dic = False
    else:
        dic = True

    response = {
        "statusCode": 200,
        "headers": {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
        "body": json.dumps({'FeatureClass': dic})
    }
    
    return response

