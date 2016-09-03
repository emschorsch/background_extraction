from django.shortcuts import render
from django.http import HttpResponse

from .models import Greeting

import requests
import os

import numpy as np
import cv2

# Create your views here.
def index(request):
    cv_version = cv2.__version__
    p = request.POST
    username = p.get('username')
    password = p.get('password')


    if 'username' in p:
        return render(request, 'index.html', {'loginFailed': True, 
            'cv_version': cv_version})
    else:
        return render(request, 'index.html', {'loginFailed': False,
            'cv_version': cv_version})

def get_results(request):
    for i in xrange(5): #0000**2):
        i/1.5
    results = 10000**2

    from subprocess import Popen, PIPE

    process = Popen(['wget', 'https://www.dropbox.com/s/jhrt02l6ixgg08t/28-20160413T173810.894300Z.mp4?dl=0#', 
        '-O', 'sample.mp4'], stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()

    return render(request, 'results.html', {'count': results})

def example_index(request):
    times = int(os.environ.get('TIMES',3))
    return HttpResponse('Hello! ' * times)
    r = requests.get('http://httpbin.org/status/418')
    print(r.text)
    return HttpResponse('<pre>' + r.text + '</pre>')

def db(request):

    greeting = Greeting()
    greeting.save()

    greetings = Greeting.objects.all()

    return render(request, 'db.html', {'greetings': greetings})

def truffle(request):
    p = request.POST
    username = p.get('UserUsername')
    password = p.get('UserPassword')
    return render(request, 'truffle.html', {'username': username,
                                            'password': password})
