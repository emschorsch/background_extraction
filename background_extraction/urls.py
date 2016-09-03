from django.conf.urls import patterns, url

from django.contrib import admin
admin.autodiscover()

import background_extraction.views

urlpatterns = patterns(
    '',
    url(r'^$', background_extraction.views.index, name='index'),
    url(r'results^$', background_extraction.views.get_results, name='results'),
)
