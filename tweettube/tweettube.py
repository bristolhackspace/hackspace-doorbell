#!/usr/bin/python
import os
import tweepy, sys, pdb, time
import RPi.GPIO as GPIO
from authfile import * #get our OAUTH keys/secrets from a file named authfile.py in the same dir
import datetime

GPIO.setmode(GPIO.BCM)
GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(24, GPIO.IN, pull_up_down=GPIO.PUD_UP)

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)

apicalls = 0

print "init"
while True:
    try:
        print "polling mentions for account " + api.me().name
        import pdb; pdb.set_trace()
        lastid = api.mentions_timeline(count=1)[0].id
        apicalls += 1
        break
    except tweepy.error.TweepError, e:
        #can be because the rate limit is exceeded
        msg =  "twitter error: %s" % e[0][0]["message"]
        print msg
        os.system("sudo ./tube_driver.py --repeats 3 --text '%s'&" % msg)
        time.sleep(60)
    except IndexError:
        lastid = 0
        break

print "main loop"
while True:
    try:
        mentions = api.mentions_timeline(since_id=lastid)
        apicalls += 1
        for i in mentions:
            #buzz
            print "incoming mention: " + i.text + " from user: " + i.user.screen_name
            os.system("aplay ./doorbell.wav&")
            os.system("sudo ./tube_driver.py --text '%s'" % i.text) #should do this in a nicer way
            os.system("sudo ./tube_driver.py --repeats 10 --text '%s'&" % "Press a button to reply") #this is not nice
            someone_in = False
            date=datetime.datetime.now()
            for x in range(100):
                if (not(GPIO.input(23)) or not(GPIO.input(24))):
                    os.system("sudo pkill -x tube_driver.py") #kill the above instance of tube_driver. Ugh.
                    os.system("sudo ./tube_driver.py --repeats 1 --text '%s'" % "telling them yes")
                    print "Replying to Tweet: yes!"
                    api.update_status("Hello, @%s. The hackspace is open as of %s!" % (i.user.screen_name, date.strftime("%H:%M:%S")), i.id)
		    apicalls += 1
                    someone_in = True
                    break
                time.sleep(0.1)
            #no one in
            if someone_in == False:
                os.system("sudo ./tube_driver.py --repeats 1 --text '%s'" % "telling them no")
                print "Replying to Tweet: no!"
                api.update_status("Hello, @%s. Sorry, I don't think anyone's in right now (%s)" % (i.user.screen_name, date.strftime("%H:%M:%S")), i.id)
		apicalls += 1
            lastid = i.id

        time.sleep(20) #rate limiting to stop twitter from getting annoyed, should be fine with 11 but it's always complaining
    
    except tweepy.error.TweepError, e: #handle no internet connection well
        try:
            msg =  "twitter error: %s" % e[0][0]["message"]
        except:
            print msg
            msg = "unknown error"
        print msg
        os.system("sudo ./tube_driver.py --repeats 3 --text '%s'&" % msg)
	print "Api calls made since launch: " + str(apicalls)
        time.sleep(60)

