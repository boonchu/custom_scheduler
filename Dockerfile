FROM scratch
MAINTAINER Boonchu Ngampairoijpibul <bigchoo@gmai.com>
ADD custom_scheduler /custom_scheduler
ENTRYPOINT ["/scheduler"]
