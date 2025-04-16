from pydantic import BaseModel


# class EnvironmentVariables(BaseSettings):
#     OPENAI_API_KEY: str
#     OPENAI_BASE_URL: str


class FunctionInfo(BaseModel):
    funcName: str
    detail: str
    hasError: list[str]
    Reason:str
    
class FunctionInfoWtihGoal(BaseModel):
    funcName: str
    detail: str
    hasError: list[str]
    Reason:str
    probability:int

class FunctionOutput(BaseModel):
    functions: list[FunctionInfo]
    
class FunctionOutputWtihGoal(BaseModel):
    functions: list[FunctionInfoWtihGoal]