from dotenv import load_dotenv
from pydantic_settings import BaseSettings

class EnvironmentVariables(BaseSettings):
    OPENAI_API_KEY: str
    OPENAI_BASE_URL: str

load_dotenv() # env模块被时导入会自动执行，（实例化controller阶段）
env_vars = EnvironmentVariables()
