#!/usr/bin/python
""" 
todo:
    * right button doesn't work

"""
import os
import tweepy, sys, pdb, time, json
import RPi.GPIO as GPIO
from authfile import * #get our OAUTH keys/secrets from a file named authfile.py in the same dir
import datetime

class StreamListener(tweepy.StreamListener):
    def on_status(self, tweet):
        print 'Ran on_status'

    def on_error(self, status_code):
        print 'Error: ' + repr(status_code)
        return True # Don't kill the stream

    def on_data(self, data):
        date=datetime.datetime.now()
        jdata = json.loads(data) 
        screen_name = jdata["user"]["screen_name"]
        reply_id = jdata["id"]
        text =  jdata["text"]
        print "got tweet from %s : %s" % (screen_name,text)

        os.system("aplay ./doorbell.wav&")
        os.system("sudo ./tube_driver.py --text '%s'" % text) #should do this in a nicer way
        os.system("sudo ./tube_driver.py --repeats 3 --text '%s'" % "Press left button to reply") #this is not nice
        someone_in = False
        for x in range(600):
            #if (not(GPIO.input(23)) or not(GPIO.input(24))):
            if (not(GPIO.input(23))):
                os.system("sudo pkill -x tube_driver.py") #kill the above instance of tube_driver. Ugh.
                os.system("sudo ./tube_driver.py --repeats 1 --text '%s'" % "telling them yes")
                print "Replying to Tweet: yes!"
                try:
                    api.update_status("Hello, @%s. The hackspace is open as of %s!" % (screen_name, date.strftime("%H:%M:%S")), reply_id)
                except tweepy.error.TweepError, e:
                    print 'Error: ' + repr(e)
                someone_in = True
                break
            time.sleep(0.1)
        #no one in
        if someone_in == False:
            os.system("sudo ./tube_driver.py --repeats 1 --text '%s'" % "telling them no")
            print "Replying to Tweet: no!"
            try:
                api.update_status("Hello, @%s. Sorry, I don't think anyone's in right now (%s)" % (screen_name, date.strftime("%H:%M:%S")), reply_id)
            except tweepy.error.TweepError, e:
                print 'Error: ' + repr(e)


if __name__ == "__main__":
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    #check this one
    GPIO.setup(24, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)

    apicalls = 0
    print "init"
    l = StreamListener()
    streamer = tweepy.Stream(auth=auth, listener=l)
    #only listen to our account
    setTerms = ['@bristolhackbell']
    print "start listening..."
    streamer.filter(track = setTerms)
