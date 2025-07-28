# prediction.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np
import pandas as pd
import os

# Load the model from the parent directory (model_training folder)
try:
    model_path = os.path.join("..", "model_training", "best_model.joblib")
    model = joblib.load(model_path)
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

app = FastAPI(title="Malaria Incidence Prediction API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Input validation with actual feature names and realistic constraints
class InputFeatures(BaseModel):
    year: int = Field(..., ge=2000, le=2025, description="Year (2000-2025)")
    bed_nets_usage: float = Field(..., ge=0.0, le=100.0, description="Use of insecticide-treated bed nets (% of under-5 population)")
    antimalarial_drugs: float = Field(..., ge=0.0, le=100.0, description="Children with fever receiving antimalarial drugs (% of children under age 5 with fever)")
    ipt_pregnancy: float = Field(..., ge=0.0, le=100.0, description="Intermittent preventive treatment (IPT) of malaria in pregnancy (% of pregnant women)")
    drinking_water: float = Field(..., ge=0.0, le=100.0, description="People using safely managed drinking water services (% of population)")

    class Config:
        schema_extra = {
            "example": {
                "year": 2020,
                "bed_nets_usage": 65.5,
                "antimalarial_drugs": 45.2,
                "ipt_pregnancy": 35.8,
                "drinking_water": 72.3
            }
        }

@app.post("/predict")
def predict(input: InputFeatures):
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        # Create input array with correct feature order
        input_dict = {
            'Year': input.year,
            'Use of insecticide-treated bed nets (% of under-5 population)': input.bed_nets_usage,
            'Children with fever receiving antimalarial drugs (% of children under age 5 with fever)': input.antimalarial_drugs,
            'Intermittent preventive treatment (IPT) of malaria in pregnancy (% of pregnant women)': input.ipt_pregnancy,
            'People using safely managed drinking water services (% of population)': input.drinking_water
        }
        
        # Convert to DataFrame for prediction
        input_df = pd.DataFrame([input_dict])
        
        # Make prediction
        pred = model.predict(input_df)[0]
        
        # Ensure non-negative prediction
        pred = max(0.0, pred)
        
        return {
            "prediction": round(float(pred), 2),
            "unit": "cases per 1,000 population at risk",
            "input_data": input_dict
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

@app.get("/")
def root():
    return {
        "message": "Malaria Incidence Prediction API is running!",
        "docs": "/docs",
        "health": "/health"
    }

@app.get("/health")
def health():
    model_status = "loaded" if model is not None else "not loaded"
    return {
        "status": "healthy",
        "model_status": model_status
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)