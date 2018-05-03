FROM ewels/multiqc:v1.5

RUN pip install wget

COPY . .

ENV VOLUME=/data
VOLUME $VOLUME

ENV PORT=80
EXPOSE $PORT

CMD ./generate_report_and_serve.sh $VOLUME $PORT
