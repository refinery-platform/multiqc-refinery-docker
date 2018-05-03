FROM ewels/multiqc:3.6.3

RUN pip install wget

COPY . .

VOLUME data
CMD ["./generate_report_and_serve.sh", "/data", $PORT]
EXPOSE 80