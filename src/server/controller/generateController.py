from openai import OpenAI
from model.model import  FunctionOutput
from config.prompt import system_prompt, get_user_prompt
from config.env import env_vars

class GenerateController:
    def __init__(self):
        self.env_vars = env_vars
        self.client = OpenAI(api_key=self.env_vars.OPENAI_API_KEY, base_url=self.env_vars.OPENAI_BASE_URL)

    def get_output(self, function_string: str) -> FunctionOutput:
        # [WIP] 这里链接会不会中断？评估一下@zjh
        response = self.client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {
                    "role": "system",
                    "content": system_prompt,
                },
                {
                    "role": "user",
                    "content": get_user_prompt(function_string),
                },
            ],
            response_format={"type": "json_object"},
        )
        print(response.choices[0].message.content)
        output = FunctionOutput.model_validate_json(response.choices[0].message.content)
        return output
