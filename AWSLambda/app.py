# app.py
# Cellscope
# Created by Christian Lopez Martinez on 5/2/21.

from chalice import Chalice
import tempfile
import boto3
import cv2 as cv
import numpy as np 
import re
import time
from PIL import Image

app = Chalice(app_name='theproject')
_SUPPORTED_IMAGE_EXTENSIONS = (
    '.jpg',
    '.png',
    '.jpeg'
)
s3 = boto3.client('s3')
source_bucket ='unprocessed-samples35741-dev'
tmp_filename='/tmp/my_image.jpg'
tmp_filename2='/tmp/my_image2.jpg'
keys_in_folder= []

@app.on_s3_event(bucket='unprocessed-samples35741-dev',events=['s3:ObjectCreated:*'])
def object_created(event):
    if is_image(event.key):
      select_image_processing_method(event, event.key)

def is_image(key):
    return key.endswith(_SUPPORTED_IMAGE_EXTENSIONS)

def select_image_processing_method(event, key):
    if key.startswith('public/unprocessed/brightfield/'):
        keys_in_folder = get_s3_concecutive_keys(source_bucket, key)
        if len(keys_in_folder) == 2:
            brigthfield(event,keys_in_folder)
    elif key.startswith('public/unprocessed/dpc/'):
        keys_in_folder = get_s3_concecutive_keys(source_bucket, key)
        if len(keys_in_folder) == 2:
            phasecontrast(event,keys_in_folder)
    elif key.startswith('public/unprocessed/convolution/'):
        convolution(event,key)
    elif key.startswith('public/unprocessed/fourier/'):
        fourier_transform_high_pass(event,key)
    elif key.startswith('public/unprocessed/thresholding/'):
        threshold(event,key)

def get_s3_concecutive_keys(bucket, key):
    allkeys = []
    twokeys = []
    if key.startswith('public/unprocessed/brightfield/'):
        resp = s3.list_objects_v2(Bucket=bucket,Prefix = 'public/unprocessed/brightfield/')
    elif key.startswith('public/unprocessed/dpc/'):
        resp = s3.list_objects_v2(Bucket=bucket,Prefix = 'public/unprocessed/dpc/')
    for obj in resp['Contents']:
        allkeys.append(obj['Key'])
    allkeys.pop(0)
    if len(allkeys) % 2 == 0 :
        string= ''.join(allkeys)
        digits = re.findall('\d+',string)
        str_to_int = list(map(int,digits))
        indexofmax1 = str_to_int.index(max(str_to_int))
        indexofmax2 = str_to_int.index(max(str_to_int)-1)
        twokeys.append(allkeys[indexofmax1])
        twokeys.append(allkeys[indexofmax2])
        return twokeys
    else:
        return None

def resize_to_same_size(img,img1):
    width = img.shape[1]
    height = img.shape[0]
    dim = (width, height)
    resized = cv.resize(img1, dim, interpolation = cv.INTER_AREA)
    return resized

#Gets maximum pixel value for an image
def getmax(img):
    maxnum = 0
    for row in img:
        for item in row:
            if item > maxnum:
                maxnum = item
    return maxnum

#Gets minimum pixel value for an image
def getmin(img):
    minnum = 1
    for row in img:
        for item in row:
            if item < minnum:
                minnum = item
    return minnum

#Removes NaN values from the image
def removenan(img):
    return  np.where(np.isnan(img), 0, img)

 #Makes all pixel have a value between 0-1  
def normalize(img,maxnumber,minnumber):
    output = ((img-minnumber)/maxnumber-minnumber)
    return output


def normalize_image(img):
    img = img.astype('float32')
    # normalize to the range 0-1
    img /= 255.0
    return img

def denormalize_image(img):
    img *= 255.0
    return img

@app.lambda_function()        
def brigthfield(event,keys_in_folder):
    s3.download_file(source_bucket, keys_in_folder[0], tmp_filename)
    s3.download_file(source_bucket, keys_in_folder[1], tmp_filename2)
    name_first_img = keys_in_folder[0]
    digits_first_img = re.findall('\d+',name_first_img)
    name_second_img = keys_in_folder[1]
    digits_second_img = re.findall('\d+',name_second_img)
    starting_pos_type = name_second_img.find('.')
    img_type = name_second_img[starting_pos_type:]
    image1 = cv.imread(tmp_filename,0)
    image2 = cv.imread(tmp_filename2,0)
    image2 = resize_to_same_size(image1, image2)
    final = normalize_image(image1)+normalize_image(image2)
    final = denormalize_image(final)
    cv.imwrite(tmp_filename, final)
    s3.upload_file(tmp_filename, source_bucket, 'public/processed/brightfield/sample' + digits_first_img[0]+ '+' + digits_second_img[0] + img_type)

@app.lambda_function()        
def phasecontrast(event,keys_in_folder):
    s3.download_file(source_bucket, keys_in_folder[0], tmp_filename)
    s3.download_file(source_bucket, keys_in_folder[1], tmp_filename2)
    name_first_img = keys_in_folder[0]
    digits_first_img = re.findall('\d+',name_first_img)
    name_second_img = keys_in_folder[1]
    digits_second_img = re.findall('\d+',name_second_img)
    starting_pos_type = name_second_img.find('.')
    img_type = name_second_img[starting_pos_type:]
    image1 = cv.imread(tmp_filename,0)
    image2 = cv.imread(tmp_filename2,0)
    image2 = resize_to_same_size(image1, image2)
    image1 = normalize_image(image1)
    image2 = normalize_image(image2)
    bf = image1+image2
    final = (image1-image2)/bf
    final = denormalize_image(final)
    cv.imwrite(tmp_filename, final)
    s3.upload_file(tmp_filename, source_bucket, 'public/processed/dpc/sample' + digits_first_img[0]+ '+' + digits_second_img[0] + img_type)


'''***************************************************************************************
*    Title: Digital Image Processing
*    Author: Rafael C. Gonzalez
*    Code modified obtained from https://docs.opencv.org/3.4/d7/d4d/tutorial_py_thresholding.html 
***************************************************************************************'''
@app.lambda_function()        
def threshold(event,key):
    s3.download_file(source_bucket, key, tmp_filename)
    image = cv.imread(tmp_filename,0) 
    name = key
    digits = re.findall('\d+',name)
    starting_pos_type = name.find('.')
    img_type = name[starting_pos_type:]
    T,th1 = cv.threshold(image,120,255,cv.THRESH_BINARY)
    th2 = cv.adaptiveThreshold(image,255,cv.ADAPTIVE_THRESH_MEAN_C,\
                cv.THRESH_BINARY,115,1)
    th3 = cv.adaptiveThreshold(image,255,cv.ADAPTIVE_THRESH_GAUSSIAN_C,\
                cv.THRESH_BINARY,115,1)
    half1 = np.concatenate((image, th1), axis = 0)
    half2 = np.concatenate((th2, th3), axis = 0)
    final = np.concatenate((half1, half2), axis = 1)
    cv.imwrite(tmp_filename, final)
    s3.upload_file(tmp_filename, source_bucket, 'public/processed/thresholding/sample'+ digits[0] + img_type)

'''***************************************************************************************
*    Title: Fourier Transform
*    Author: abidrahmank
*   Code modified obtained from https://github.com/abidrahmank/OpenCV2-Python-Tutorials/blob/master/source/py_tutorials/py_imgproc/py_transforms/py_fourier_transform/py_fourier_transform.rst
*
***************************************************************************************'''
@app.lambda_function()        
def fourier_transform_high_pass(event,key):
    s3.download_file(source_bucket, key, tmp_filename)
    image = cv.imread(tmp_filename,0) 
    name = key
    digits = re.findall('\d+',name)
    starting_pos_type = name.find('.')
    img_type = name[starting_pos_type:]
    #Used to find the ft of a grayscaled image
    f  = np.fft.fft2(image)
    #Brings the zero frequency component to the center
    fshift = np.fft.fftshift(f)
    #Gets the magnitude spectrum
    magnitude_spectrum = 20*np.log(np.abs(fshift))
    #we are going to make a 60x60 rectangle to remove the low frequency(Applying Highpass Filter)
    rows, cols = image.shape
    crow,ccol = int(rows/2) , int(cols/2)
    fshift[crow-30:crow+30, ccol-30:ccol+30] = 0
    #Moves the zero frequency component to the top-left corner
    f_ishift = np.fft.ifftshift(fshift)
    #Computes the 2-dimensional inverse discrete Fourier Transform 
    img_back = np.fft.ifft2(f_ishift)
    img_back = np.abs(img_back)
    final = np.concatenate((magnitude_spectrum, img_back), axis = 0)
    cv.imwrite(tmp_filename, final)
    s3.upload_file(tmp_filename, source_bucket, 'public/processed/fourier/sample'+ digits[0] + img_type)

'''***************************************************************************************
*    Title: Convolutions with OpenCV and Python
*    Author: Adrian Rosebrock 
*   Code modified obtained from https://www.pyimagesearch.com/2016/07/25/convolutions-with-opencv-and-python/
*
***************************************************************************************'''
@app.lambda_function()        
def convolution(event,key):
    s3.download_file(source_bucket, key, tmp_filename)
    name = key
    digits = re.findall('\d+',name)
    starting_pos_type = name.find('.')
    img_type = name[starting_pos_type:]
    image = cv.imread(tmp_filename,0) 
    smallBlur = np.ones((7, 7), dtype="float") * (1.0 / (7 * 7))
    largeBlur = np.ones((21, 21), dtype="float") * (1.0 / (21 * 21))
    # sharpens the edges
    laplacian = np.array((
        [0, 1, 0],
        [1, -4, 1],
        [0, 1, 0]), dtype="int")
    # sharpens the image, more clear
    sharpen = np.array((
        [0, -1, 0],
        [-1, 5, -1],
        [0, -1, 0]), dtype="int")
    # sharpens the edges horizontally 
    sobelX = np.array((
        [-1, 0, 1],
        [-2, 0, 2],
        [-1, 0, 1]), dtype="int")
    # sharpens the edges vertically
    sobelY = np.array((
        [-1, -2, -1],
        [0, 0, 0],
        [1, 2, 1]), dtype="int")
    # makes the background brighter and highlights the dark 
    darkObject = (np.zeros((5, 5))+0.1)
    # sharpens the image a little
    sharp = (np.zeros((3, 3))+0.1)
    opencvOutput = cv.filter2D(image, -1, sharpen)
    final = np.concatenate((image, opencvOutput), axis = 0)
    cv.imwrite(tmp_filename, final)
    s3.upload_file(tmp_filename, source_bucket, 'public/processed/convolution/sample'+ digits[0] + img_type)
