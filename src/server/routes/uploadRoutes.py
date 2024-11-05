import os
from fastapi import APIRouter, File, UploadFile
from controller.generateController import GenerateController
router = APIRouter()

generate = GenerateController()


@router.post("/generate/")
async def routeGenerate(file: UploadFile = File(...)):

    save_path = os.path.join("../../uploads", file.filename)
    
    with open(save_path, "wb") as buffer:
        buffer.write(await file.read())
    

    with open(save_path, "r") as f:
        input_string = f.read()

    result = generate.get_output(input_string)
    

    return {"result": result}
