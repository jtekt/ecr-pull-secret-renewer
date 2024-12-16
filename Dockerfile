FROM moreillon/ci-dind:4bca50d7
COPY script.sh script.sh
CMD ["/bin/bash", "./script.sh"]

