from fastapi import FastAPI
from pydantic import BaseModel
from typing import Dict, Union
import torch
import torchvision.transforms as transforms
from PIL import Image
import os
import numpy as np
import torch.nn as nn
from torchvision import models
import requests
from io import BytesIO
import sys
import pickle

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "OK : 200"}

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

class pd(BaseModel):
    data: Dict[str, Union[str, int, float]]

# Multimodal CNN model
class SkinCancerModel(nn.Module):
    def __init__(self, num_important_features, num_other_features):
        super(SkinCancerModel, self).__init__()

        # Image feature extractor using EfficientNet
        self.efficientnet = models.efficientnet_v2_s(weights='IMAGENET1K_V1')
        eff_out_features = self.efficientnet.classifier[1].in_features
        self.efficientnet.classifier = nn.Identity()  # Remove classifier

        # Important feature processing with higher weight
        self.important_fc = nn.Sequential(
            nn.Linear(num_important_features, 64),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(64, 32),
            nn.ReLU()
        )

        # Other feature processing
        self.other_fc = nn.Sequential(
            nn.Linear(num_other_features, 32),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Fusion layer
        self.fusion = nn.Sequential(
            nn.Linear(eff_out_features + 32 + 16, 256),
            nn.ReLU(),
            nn.Dropout(0.4),
            nn.Linear(256, 64),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(64, 1)
        )

        # Attention mechanism for image features (to give more importance)
        self.attention = nn.Sequential(
            nn.Linear(eff_out_features, eff_out_features),
            nn.Sigmoid()
        )

    def forward(self, image, important_features, other_features):
        # Extract image features
        img_features = self.efficientnet(image)

        # Apply attention to image features
        attention_weights = self.attention(img_features)
        img_features = img_features * attention_weights

        # Process important features
        imp_features = self.important_fc(important_features)

        # Process other features
        other_feats = self.other_fc(other_features)

        # Concatenate all features
        combined = torch.cat((img_features, imp_features, other_feats), dim=1)

        # Final prediction
        output = self.fusion(combined)
        return output


def register_pickle_class():
    # Get the current module
    current_module = sys.modules[__name__]

    # Register SkinCancerModel in the current module
    setattr(current_module, 'SkinCancerModel', SkinCancerModel)

register_pickle_class()

def predict_skin_cancer(item):
    image_path=item.pop("image_path")
    # Set device
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    # Load the model
    try:
        register_pickle_class()
        model = torch.load(r"CNN/CNN.pt", map_location=device, weights_only=False)
        model.eval()
    except Exception as e:
        raise Exception(f"Error loading model: {e}")

    # Define important features (must match the ones used in training)
    important_features = ['itch', 'grew', 'hurt', 'changed', 'bleed', 'fitzpatrick', 'age']

    # Define all features except RESULT and img_id (based on the patient_data dictionary)
    all_features = list(item.keys())
    other_features = [feat for feat in all_features if feat not in important_features]

    # Define image transformations (must match the validation transforms from training)
    img_size = 224  # Must match the size used in training
    val_transforms = transforms.Compose([
        transforms.Resize((img_size, img_size)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    # Process image
    try:
        response = requests.get(image_path)
        image = Image.open(BytesIO(response.content))
        image_tensor = val_transforms(image).unsqueeze(0).to(device)
    except Exception as e:
        raise Exception(f"Error processing image: {e}")

    # Process important features
    important_features_tensor = torch.tensor([
        item.get(feat, 0) for feat in important_features
    ], dtype=torch.float32).unsqueeze(0).to(device)

    # Process other features
    other_features_tensor = torch.tensor([
        item.get(feat, 0) for feat in other_features
    ], dtype=torch.float32).unsqueeze(0).to(device)

    # Make prediction
    with torch.no_grad():
        try:
            output = model(image_tensor, important_features_tensor, other_features_tensor)
            probability = torch.sigmoid(output).item()
            prediction = 1 if probability > 0.5 else 0
        except Exception as e:
            raise Exception(f"Error during prediction: {e}")

    return probability, prediction

@app.post("/predict")
async def predict_data(item: pd):

    print("data= ", item.data)
    print("Image= ", item.data["image_path"])

    prob,pred=predict_skin_cancer(item.data)
    return {"message": "OK : 200", "prob":prob, "pred":pred}