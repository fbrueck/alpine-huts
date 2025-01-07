FROM public.ecr.aws/lambda/python:3.13

COPY requirements.txt ./
RUN pip install -r requirements.txt -t /var/task/

COPY src/* /var/task/

CMD ["main.lambda_handler"]
