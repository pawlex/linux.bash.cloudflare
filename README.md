# linux.bash.cloudflare
A quick and dirty shell script to view and manipulate cloudflare zone records.

Designed to be used on \*NIX systems with minimal support software installed (No perl, python, php etc).

Primary goal is to implement a light-weight DYNDNS client with the ability to debug host/zone records.


## cloudflareZoneRecord.sh
### GETZONE
```
./cloudflareZoneRecord.sh GETZONE 
```
**returns:** JSON object of entire zone (all records)

### GETRECORD
```
./cloudflareZoneRecord.sh GETRECORD A www.mydomain.com
```
**returns:** JSON object of record within the defined zone

### SETRECORD
```
./cloudflareZoneRecord.sh SETRECORD 545832696a294e8d912334af31248 A www.mydomain.com 127.0.0.1
```
**returns:** SUCCESS|FAILED

### ADDRECORD
```
./cloudflareZoneRecord.sh ADDRECORD A www.mydomain.com 127.0.0.1
```
**returns:** SUCCESS|FAILED

### DELRECORD
```
./cloudflareZoneRecord.sh DELRECORD 545832696a294e8d912334af31248
```
**returns:** SUCCESS|FAILED

### DYNDNSUPDATE
```
./cloudflareZoneRecord.sh DYNDNSUPDATE
```
**returns:** 
  - NO UPDATE NECESSARY | 
  - [UPDATE NECESSARY, PREVIOUS_IP -> CURRENT_IP]


## config.cf
### Variables
#### Required
* **EMAIL**
  - email address associated with CloudFlare account
* **ZONEID**
  - primary zone id for the domain
* **GLOBAL_API_KEY**
  - cloudflare api key
  
#### Optional
* **DYNDNSRECORDID**
  - record id for dynDns update
* **DYNDNSRECORDNAME**
  - record name for dynDns update
* **DYNDNSRECORDTYPE**
  - record type for dynDns update
