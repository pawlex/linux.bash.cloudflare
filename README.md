# linux.bash.cloudflare
A quick and dirty shell script to view and manipulate cloudflare zone records
## config.cf
### Variables
#### Required
* EMAIL - **email address associated with CloudFlare account**
* ZONEID - **primary zone id for the domain**
* GLOBAL_API_KEY - **cloudflare api key**
#### Optional
* DYNDNSRECORDID - **record id for dynDns update**
* DYNDNSRECORDNAME - **record name for dynDns update**
* DYNDNSRECORDTYPE - **record type for dynDns update**

## cloudflareZoneRecord.sh
### GETZONE
```
./cloudflareZoneRecord.sh GETZONE 
```
**returns**: JSON object for all objects in the zone

### GETRECORD
### SETRECORD
### DYNDNSUPDATE
