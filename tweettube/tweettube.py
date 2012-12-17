#!/usr/bin/python
import os
import tweepy, sys, pdb, time
from authfile import *

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)

print "polling mentions for account " + api.me().name
lastid = api.mentions(count=1)[0].id
while True:
	mentions = api.mentions(since_id=lastid)
	for i in mentions:
		print "incoming mention: " + i.text
		os.system("sudo ./tube_driver.py --text '%s'" % i.text)
		lastid = i.id
	time.sleep(30)
