import os
from fastapi import APIRouter, File, UploadFile, Query
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

@router.post("/generate/goal/")
async def routeGenerateWithGoal(user_goal: str = Query(...), file: UploadFile = File(...)):
    print("user_goal is:",user_goal)
    save_path = os.path.join("../../uploads", file.filename)
    
    with open(save_path, "wb") as buffer:
        buffer.write(await file.read())
    

    with open(save_path, "r") as f:
        input_string = f.read()

    result = generate.get_output_user_description(input_string, user_goal)
    

    return {"result": result}
