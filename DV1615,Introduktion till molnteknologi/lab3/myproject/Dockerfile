# Skapar ett lager/sätter en basimage för Python 3.8 Detta lager är read-only.
FROM python:3.8

# Sätt vilken folder som är working directory i containern
WORKDIR /code
COPY . .
RUN pip install -r requirements.txt

EXPOSE 5000

# Command att köra när containern startar
CMD [ "python", "./app.py" ]