FROM python:3.7-alpine

ENV APP /usr/src/app/
WORKDIR ${APP}

COPY ./requirements.txt .
RUN pip install --upgrade pip
RUN	pip install -r requirements.txt

ENV FLASK_APP bookmanager.py

COPY ./bookmanager.py .
COPY ./bookdatabase.db .
COPY ./templates ./templates

EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["bookmanager.py"]