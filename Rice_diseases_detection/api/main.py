import uvicorn
from fastapi import FastAPI,File,UploadFile
import numpy as np
from io import BytesIO
from PIL import Image
import tensorflow as tf
from fastapi.middleware.cors import CORSMiddleware

app=FastAPI()
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://127.0.0.1:4350",
    "http://192.168.0.101"
    
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
MODEL = tf.keras.models.load_model("C:/Users/User/Documents/ML_apps/Rice_dieseas_detection/models/1")
cls_names = ["BrownSpot","Garbage","Healthy","Hispa","LeafBlast"]

@app.get("/ping")
async def ping():
    return "Hello, The kernel is still alive"
    
def read_file_as_image(data)-> np.ndarray:
    size =(256,256)
    image = np.array(Image.open(BytesIO(data)).resize(size))
    return image

@app.post("/predict")
async def predict(
        file:UploadFile=File(...)
):
    image=read_file_as_image(await file.read())
    img_batch=np.expand_dims(image,0)
    pred= MODEL.predict(img_batch)
    pred_cls=cls_names[np.argmax(pred[0])]
    confidence=np.max(pred[0])
    print(pred_cls,confidence)
    return pred_cls,float(confidence),
    
if __name__=="__main__":
    uvicorn.run(app,host="0.0.0.0",port=8000)
