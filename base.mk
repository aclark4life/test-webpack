# Project Makefile - https://github.com/project-makefile/project-makefile
#
# A generic makefile for projects.
#
# License
#
# Copyright 2016—2023 Jeffrey A. Clark (Alex)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# --------------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------------

GIT_BRANCHES = `git branch -a \
	| grep remote  \
	| grep -v HEAD \
	| grep -v main \
	| grep -v master`  # http://unix.stackexchange.com/a/37316

RANDIR := $(shell openssl rand -base64 12 | sed 's/\///g')  # https://stackoverflow.com/a/589260/185820

TMPDIR := $(shell mktemp -d)# https://stackoverflow.com/a/589260/185820

UNAME := $(shell uname)  # https://stackoverflow.com/a/589260/185820

define INTERNAL_IPS
INTERNAL_IPS = ["127.0.0.1",]
endef

define CLOCK_COMPONENT
import { useState, useEffect } from 'react';

const Clock = () => {
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const intervalId = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    // Cleanup function to clear the interval when the component is unmounted
    return () => clearInterval(intervalId);
  }, []); // Empty dependency array ensures that the effect runs only once (on mount)

  const formattedTime = currentTime.toLocaleTimeString();

  return (
    <div>
      <h2>Current Time:</h2>
      <p>{formattedTime}</p>
    </div>
  );
};
export default Clock;
endef

define FRONTEND_APP
// eslint-disable-next-line no-unused-vars
import Clock from '../components/Clock';

const App = () => {
  return (
    <div>
      <h1>React Time Display App</h1>
      <Clock />
    </div>
  );
};

export default App;
endef

define BABELRC
{
  "presets": [
    [
      "@babel/preset-react",
    ],
    [
      "@babel/preset-env",
      {
        "useBuiltIns": "usage",
        "corejs": "3.0.0"
      }
    ]
  ],
  "plugins": [
    "@babel/plugin-syntax-dynamic-import",
    "@babel/plugin-transform-class-properties"
  ]
}
endef

define BASE_TEMPLATE
{% load static wagtailcore_tags wagtailuserbar %}

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>
            {% block title %}
            {% if page.seo_title %}{{ page.seo_title }}{% else %}{{ page.title }}{% endif %}
            {% endblock %}
            {% block title_suffix %}
            {% wagtail_site as current_site %}
            {% if current_site and current_site.site_name %}- {{ current_site.site_name }}{% endif %}
            {% endblock %}
        </title>
        {% if page.search_description %}
        <meta name="description" content="{{ page.search_description }}" />
        {% endif %}
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        {# Force all links in the live preview panel to be opened in a new tab #}
        {% if request.in_preview_panel %}
        <base target="_blank">
        {% endif %}

        {% block extra_css %}
        {# Override this in templates to add extra stylesheets #}
        {% endblock %}

		<link type="text/css" href="{% static 'css/welcome_page.css' %}" rel="stylesheet">

		<link href="{% static 'wagtailadmin/images/favicon.ico' %}" rel="icon">
    </head>

    <body class="{% block body_class %}{% endblock %}">
        {% wagtailuserbar %}

		<div id="root"></div>
        {% block content %}{% endblock %}

        {% block extra_js %}
        {# Override this in templates to add extra javascript #}
        {% endblock %}
    </body>
</html>
endef

define HOME_PAGE_MODEL
from django.db import models
from wagtail.models import Page
from wagtail.fields import RichTextField
from wagtail.admin.panels import FieldPanel
from wagtailseo.models import SeoMixin

class HomePage(SeoMixin, Page):
    description = models.CharField(max_length=255, help_text='A short description of the page', blank=True, null=True)
    body = RichTextField(blank=True, null=True, help_text='The main content of the page')
    content_panels = Page.content_panels + [
        FieldPanel('description'),
        FieldPanel('body'),
    ]
    promote_panels = SeoMixin.seo_panels
endef

define ALLAUTH_LAYOUT_BASE
{% extends 'base.html' %}
{% load i18n %}
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            {% block head_title %}
            {% endblock head_title %}
        </title>
        {% block extra_head %}
        {% endblock extra_head %}
    </head>
    <body>
        {% block body %}
            {% if messages %}
                <div>
                    <strong>{% trans "Messages:" %}</strong>
                    <ul>
                        {% for message in messages %}<li>{{ message }}</li>{% endfor %}
                    </ul>
                </div>
            {% endif %}
            <div>
                <strong>{% trans "Menu:" %}</strong>
                <ul>
                    {% if user.is_authenticated %}
                        <li>
                            <a href="{% url 'account_email' %}">{% trans "Change Email" %}</a>
                        </li>
                        <li>
                            <a href="{% url 'account_logout' %}">{% trans "Sign Out" %}</a>
                        </li>
                    {% else %}
                        <li>
                            <a href="{% url 'account_login' %}">{% trans "Sign In" %}</a>
                        </li>
                        <li>
                            <a href="{% url 'account_signup' %}">{% trans "Sign Up" %}</a>
                        </li>
                    {% endif %}
                </ul>
            </div>
            {% block content %}
            {% endblock content %}
        {% endblock body %}
        {% block extra_body %}
        {% endblock extra_body %}
    </body>
</html>
endef

define HOME_PAGE_TEMPLATE
{% extends "base.html" %}
{% load webpack_loader static i18n wagtailcore_tags %}
{% block body_class %}{% endblock %}
{% block extra_css %}
    {% stylesheet_pack 'app' %}
    {% include "wagtailseo/meta.html" %}
{% endblock extra_css %}
{% block content %}
    <header class="header">
        <div class="logo">
            <a href="/">
                <svg class="figure-logo"
                     xmlns="http://www.w3.org/2000/svg"
                     viewBox="0 0 342.5 126.2">
                    <title>{% trans "Visit the Wagtail website" %}</title>
                    <path fill="#FFF" d="M84 1.9v5.7s-10.2-3.8-16.8 3.1c-4.8 5-5.2 10.6-3 18.1 21.6 0 25 12.1 25 12.1L87 27l6.8-8.3c0-9.8-8.1-16.3-9.8-16.8z" />
                    <circle cx="85.9" cy="15.9" r="2.6" />
                    <path d="M89.2 40.9s-3.3-16.6-24.9-12.1c-2.2-7.5-1.8-13 3-18.1C73.8 3.8 84 7.6 84 7.6V1.9C80.4.3 77 0 73.2 0 59.3 0 51.6 10.4 48.3 17.4L9.2 89.3l11-2.1-20.2 39 14.1-2.5L24.9 93c30.6 0 69.8-11 64.3-52.1z" />
                    <path d="M102.4 27l-8.6-8.3L87 27z" />
                    <path fill="#FFF" d="M30 84.1s1-.2 2.8-.6c1.8-.4 4.3-1 7.3-1.8 1.5-.4 3.1-.9 4.8-1.5 1.7-.6 3.5-1.2 5.2-2 1.8-.7 3.6-1.6 5.4-2.6 1.8-1 3.5-2.1 5.1-3.4.4-.3.8-.6 1.2-1l1.2-1c.7-.7 1.5-1.4 2.2-2.2.7-.7 1.3-1.5 1.9-2.3l.9-1.2.4-.6.4-.6c.2-.4.5-.8.7-1.2.2-.4.4-.8.7-1.2l.3-.6.3-.6c.2-.4.4-.8.5-1.2l.9-2.4c.2-.8.5-1.6.7-2.3.2-.7.3-1.5.5-2.1.1-.7.2-1.3.3-2 .1-.6.2-1.2.2-1.7.1-.5.1-1 .2-1.5.1-1.8.1-2.8.1-2.8l1.6.1s-.1 1.1-.2 2.9c-.1.5-.1 1-.2 1.5-.1.6-.1 1.2-.3 1.8-.1.6-.3 1.3-.4 2-.2.7-.4 1.4-.6 2.2-.2.8-.5 1.5-.8 2.4-.3.8-.6 1.6-1 2.5l-.6 1.2-.3.6-.3.6c-.2.4-.5.8-.7 1.3-.3.4-.5.8-.8 1.2-.1.2-.3.4-.4.6l-.4.6-.9 1.2c-.7.8-1.3 1.6-2.1 2.3-.7.8-1.5 1.4-2.3 2.2l-1.2 1c-.4.3-.8.6-1.3.9-1.7 1.2-3.5 2.3-5.3 3.3-1.8.9-3.7 1.8-5.5 2.5-1.8.7-3.6 1.3-5.3 1.8-1.7.5-3.3 1-4.9 1.3-3 .7-5.6 1.3-7.4 1.6-1.6.6-2.6.8-2.6.8z" />
                    <g fill="#231F20">
                    <path d="M127 83.9h-8.8l-12.6-36.4h7.9l9 27.5 9-27.5h7.9l9 27.5 9-27.5h7.9L153 83.9h-8.8L135.6 59 127 83.9zM200.1 83.9h-7V79c-3 3.6-7 5.4-12.1 5.4-3.8 0-6.9-1.1-9.4-3.2s-3.7-5-3.7-8.6c0-3.6 1.3-6.3 4-8 2.6-1.8 6.2-2.7 10.7-2.7h9.9v-1.4c0-4.8-2.7-7.3-8.1-7.3-3.4 0-6.9 1.2-10.5 3.7l-3.4-4.8c4.4-3.5 9.4-5.3 15.1-5.3 4.3 0 7.8 1.1 10.5 3.2 2.7 2.2 4.1 5.6 4.1 10.2v23.7zm-7.7-13.6v-3.1h-8.6c-5.5 0-8.3 1.7-8.3 5.2 0 1.8.7 3.1 2.1 4.1 1.4.9 3.3 1.4 5.7 1.4 2.4 0 4.6-.7 6.4-2.1 1.8-1.3 2.7-3.1 2.7-5.5zM241.7 47.5v31.7c0 6.4-1.7 11.3-5.2 14.5-3.5 3.2-8 4.8-13.4 4.8-5.5 0-10.4-1.7-14.8-5.1l3.6-5.8c3.6 2.7 7.1 4 10.8 4 3.6 0 6.5-.9 8.6-2.8 2.1-1.9 3.2-4.9 3.2-9v-4.7c-1.1 2.1-2.8 3.9-4.9 5.1-2.1 1.3-4.5 1.9-7.1 1.9-4.8 0-8.8-1.7-11.9-5.1-3.1-3.4-4.7-7.6-4.7-12.6s1.6-9.2 4.7-12.6c3.1-3.4 7.1-5.1 11.9-5.1 4.8 0 8.7 2 11.7 6v-5.4h7.5zm-28.4 16.8c0 3 .9 5.6 2.8 7.7 1.8 2.2 4.3 3.2 7.5 3.2 3.1 0 5.7-1 7.6-3.1 1.9-2.1 2.9-4.7 2.9-7.8 0-3.1-1-5.8-2.9-7.9-2-2.2-4.5-3.2-7.6-3.2-3.1 0-5.6 1.1-7.4 3.4-2 2.1-2.9 4.7-2.9 7.7zM260.9 53.6v18.5c0 1.7.5 3.1 1.4 4.1.9 1 2.2 1.5 3.8 1.5 1.6 0 3.2-.8 4.7-2.4l3.1 5.4c-2.7 2.4-5.7 3.6-8.9 3.6-3.3 0-6-1.1-8.3-3.4-2.3-2.3-3.5-5.3-3.5-9.1V53.6h-4.6v-6.2h4.6V36.1h7.7v11.4h9.6v6.2h-9.6zM309.5 83.9h-7V79c-3 3.6-7 5.4-12.1 5.4-3.8 0-6.9-1.1-9.4-3.2s-3.7-5-3.7-8.6c0-3.6 1.3-6.3 4-8 2.6-1.8 6.2-2.7 10.7-2.7h9.9v-1.4c0-4.8-2.7-7.3-8.1-7.3-3.4 0-6.9 1.2-10.5 3.7l-3.4-4.8c4.4-3.5 9.4-5.3 15.1-5.3 4.3 0 7.8 1.1 10.5 3.2 2.7 2.2 4.1 5.6 4.1 10.2v23.7zm-7.7-13.6v-3.1h-8.6c-5.5 0-8.3 1.7-8.3 5.2 0 1.8.7 3.1 2.1 4.1 1.4.9 3.3 1.4 5.7 1.4 2.4 0 4.6-.7 6.4-2.1 1.8-1.3 2.7-3.1 2.7-5.5zM319.3 40.2c-1-1-1.4-2.1-1.4-3.4 0-1.3.5-2.5 1.4-3.4 1-1 2.1-1.4 3.4-1.4 1.3 0 2.5.5 3.4 1.4 1 1 1.4 2.1 1.4 3.4 0 1.3-.5 2.5-1.4 3.4s-2.1 1.4-3.4 1.4c-1.3.1-2.4-.4-3.4-1.4zm7.2 43.7h-7.7V47.5h7.7v36.4zM342.5 83.9h-7.7V33.1h7.7v50.8z" />
                    </g>
                </svg>
            </a>
        </div>
        <div class="header-link">
            {% comment %}
        This works for all cases but prerelease versions:
            {% endcomment %}
            {% trans "View the release notes" %}:
            <a target="_blank" href="{% wagtail_documentation_path %}/releases/{% wagtail_release_notes_path %}">Wagtail</a> |
			<a target="_blank" href="https://docs.djangoproject.com/en/4.2/releases/4.2.7/">Django</a> |
			<a target="_blank" href="https://github.com/facebook/react/releases/tag/v18.2.0">React</a>
        </div>
    </header>
    <main class="main">
        <div class="">
            <svg class="figure-space"
                 xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 300 300"
                 aria-hidden="true">
                <path class="egg" fill="currentColor" d="M150 250c-42.741 0-75-32.693-75-90s42.913-110 75-110c32.088 0 75 52.693 75 110s-32.258 90-75 90z" />
                <ellipse fill="#ddd" cx="150" cy="270" rx="40" ry="7" />
            </svg>
        </div>
        <div class="main-text">
            <h1>{% trans "Welcome to your new Wagtail site!" %}</h1>
            <p>
                {% trans 'Please feel free to <a target="_blank" href="https://wagtail.org/slack/">join our community on Slack</a>, or get started with one of the links below.' %}
            </p>
        </div>
    </main>
    <footer class="footer" role="contentinfo">
        <a target="_blank" class="option option-one" href="{% wagtail_documentation_path %}/">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M9 21c0 .5.4 1 1 1h4c.6 0 1-.5 1-1v-1H9v1zm3-19C8.1 2 5 5.1 5 9c0 2.4 1.2 4.5 3 5.7V17c0 .5.4 1 1 1h6c.6 0 1-.5 1-1v-2.3c1.8-1.3 3-3.4 3-5.7 0-3.9-3.1-7-7-7zm2.9 11.1l-.9.6V16h-4v-2.3l-.9-.6C7.8 12.2 7 10.6 7 9c0-2.8 2.2-5 5-5s5 2.2 5 5c0 1.6-.8 3.2-2.1 4.1z" />
            </svg>
            <div>
                <h2>{% trans "Wagtail Documentation" %}</h2>
                <p>{% trans "Topics, references, & how-tos" %}</p>
            </div>
        </a>
        <a target="_blank" class="option option-one" href="https://docs.djangoproject.com/en/4.2/">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M9 21c0 .5.4 1 1 1h4c.6 0 1-.5 1-1v-1H9v1zm3-19C8.1 2 5 5.1 5 9c0 2.4 1.2 4.5 3 5.7V17c0 .5.4 1 1 1h6c.6 0 1-.5 1-1v-2.3c1.8-1.3 3-3.4 3-5.7 0-3.9-3.1-7-7-7zm2.9 11.1l-.9.6V16h-4v-2.3l-.9-.6C7.8 12.2 7 10.6 7 9c0-2.8 2.2-5 5-5s5 2.2 5 5c0 1.6-.8 3.2-2.1 4.1z" />
            </svg>
            <div>
                <h2>{% trans "Django Documentation" %}</h2>
                <p>{% trans "Topics, references, & how-tos" %}</p>
            </div>
        </a>
        <a target="_blank" class="option option-one" href="https://react.dev">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M9 21c0 .5.4 1 1 1h4c.6 0 1-.5 1-1v-1H9v1zm3-19C8.1 2 5 5.1 5 9c0 2.4 1.2 4.5 3 5.7V17c0 .5.4 1 1 1h6c.6 0 1-.5 1-1v-2.3c1.8-1.3 3-3.4 3-5.7 0-3.9-3.1-7-7-7zm2.9 11.1l-.9.6V16h-4v-2.3l-.9-.6C7.8 12.2 7 10.6 7 9c0-2.8 2.2-5 5-5s5 2.2 5 5c0 1.6-.8 3.2-2.1 4.1z" />
            </svg>
            <div>
                <h2>React Documentation</h2>
                <p>{% trans "Topics, references, & how-tos" %}</p>
            </div>
        </a>
        <a target="_blank" class="option option-two"
           href="{% wagtail_documentation_path %}/getting_started/tutorial.html">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M0 0h24v24H0V0z" fill="none" />
                <path d="M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z" />
            </svg>
            <div>
                <h2>Wagtail Tutorial</h2>
                <p>{% trans "Build your first Wagtail site" %}</p>
            </div>
        </a>
        <a target="_blank" class="option option-two"
           href="https://docs.djangoproject.com/en/4.2/intro/tutorial01/">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M0 0h24v24H0V0z" fill="none" />
                <path d="M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z" />
            </svg>
            <div>
                <h2>Django Tutorial</h2>
                <p>{% trans "Build your first Wagtail site" %}</p>
            </div>
        </a>
        <a target="_blank"
           class="option option-three"
           href="{% url 'wagtailadmin_home' %}">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M0 0h24v24H0z" fill="none" />
                <path d="M16.5 13c-1.2 0-3.07.34-4.5 1-1.43-.67-3.3-1-4.5-1C5.33 13 1 14.08 1 16.25V19h22v-2.75c0-2.17-4.33-3.25-6.5-3.25zm-4 4.5h-10v-1.25c0-.54 2.56-1.75 5-1.75s5 1.21 5 1.75v1.25zm9 0H14v-1.25c0-.46-.2-.86-.52-1.22.88-.3 1.96-.53 3.02-.53 2.44 0 5 1.21 5 1.75v1.25zM7.5 12c1.93 0 3.5-1.57 3.5-3.5S9.43 5 7.5 5 4 6.57 4 8.5 5.57 12 7.5 12zm0-5.5c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2zm9 5.5c1.93 0 3.5-1.57 3.5-3.5S18.43 5 16.5 5 13 6.57 13 8.5s1.57 3.5 3.5 3.5zm0-5.5c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2z" />
            </svg>
            <div>
                <h2>Wagtail {% trans "Admin Interface" %}</h2>
                <p>{% trans "Create your superuser first!" %}</p>
            </div>
        </a>
        <a target="_blank"
           class="option option-one"
           href="{% url 'admin:index' %}">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M0 0h24v24H0z" fill="none" />
                <path d="M16.5 13c-1.2 0-3.07.34-4.5 1-1.43-.67-3.3-1-4.5-1C5.33 13 1 14.08 1 16.25V19h22v-2.75c0-2.17-4.33-3.25-6.5-3.25zm-4 4.5h-10v-1.25c0-.54 2.56-1.75 5-1.75s5 1.21 5 1.75v1.25zm9 0H14v-1.25c0-.46-.2-.86-.52-1.22.88-.3 1.96-.53 3.02-.53 2.44 0 5 1.21 5 1.75v1.25zM7.5 12c1.93 0 3.5-1.57 3.5-3.5S9.43 5 7.5 5 4 6.57 4 8.5 5.57 12 7.5 12zm0-5.5c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2zm9 5.5c1.93 0 3.5-1.57 3.5-3.5S18.43 5 16.5 5 13 6.57 13 8.5s1.57 3.5 3.5 3.5zm0-5.5c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2z" />
            </svg>
            <div>
                <h2>Django administration</h2>
                <p>{% trans "Create your superuser first!" %}</p>
            </div>
        </a>
        <a target="_blank"
           class="option option-one"
           href="/api">
            <svg xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 24 24"
                 aria-hidden="true">
                <path d="M0 0h24v24H0z" fill="none" />
                <path d="M16.5 13c-1.2 0-3.07.34-4.5 1-1.43-.67-3.3-1-4.5-1C5.33 13 1 14.08 1 16.25V19h22v-2.75c0-2.17-4.33-3.25-6.5-3.25zm-4 4.5h-10v-1.25c0-.54 2.56-1.75 5-1.75s5 1.21 5 1.75v1.25zm9 0H14v-1.25c0-.46-.2-.86-.52-1.22.88-.3 1.96-.53 3.02-.53 2.44 0 5 1.21 5 1.75v1.25zM7.5 12c1.93 0 3.5-1.57 3.5-3.5S9.43 5 7.5 5 4 6.57 4 8.5 5.57 12 7.5 12zm0-5.5c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2zm9 5.5c1.93 0 3.5-1.57 3.5-3.5S18.43 5 16.5 5 13 6.57 13 8.5s1.57 3.5 3.5 3.5zm0-5.5c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2 .9-2 2-2z" />
            </svg>
            <div>
                <h2>Django REST framework</h2>
                <p>API Root</p>
            </div>
        </a>
    </footer>
{% endblock content %}
{% block extra_js %}
    {% javascript_pack 'app' attrs='charset="UTF-8"' %}
    {% include "wagtailseo/struct_data.html" %}
{% endblock %}
endef
define JENKINS_FILE
pipeline {
    agent any
    stages {
        stage('') {
            steps {
                echo ''
            }
        }
	}
}
endef
define AUTHENTICATION_BACKENDS
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
]
endef
define URL_PATTERNS
from django.conf import settings
from django.urls import include, path
from django.contrib import admin

from wagtail.admin import urls as wagtailadmin_urls
from wagtail import urls as wagtail_urls
from wagtail.documents import urls as wagtaildocs_urls

from search import views as search_views

from django.contrib.auth.models import User
from rest_framework import routers, serializers, viewsets

urlpatterns = [
	path('accounts/', include('allauth.urls')),
    path('admin/', admin.site.urls),
    path('wagtail/', include(wagtailadmin_urls)),
]

if settings.DEBUG:
    from django.conf.urls.static import static
    from django.contrib.staticfiles.urls import staticfiles_urlpatterns

    # Serve static and media files from development server
    urlpatterns += staticfiles_urlpatterns()
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

    import debug_toolbar
    urlpatterns += [
        path("__debug__/", include(debug_toolbar.urls)),
    ]

# https://www.django-rest-framework.org/#example
class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ['url', 'username', 'email', 'is_staff']

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

router = routers.DefaultRouter()
router.register(r'users', UserViewSet)


urlpatterns += [
    path('api/', include(router.urls)),
    path('api/', include('rest_framework.urls', namespace='rest_framework'))
]

urlpatterns += [
    # For anything not caught by a more specific rule above, hand over to
    # Wagtail's page serving mechanism. This should be the last pattern in
    # the list:
    path("", include(wagtail_urls)),

    # Alternatively, if you want Wagtail pages to be served from a subpath
    # of your site, rather than the site root:
    #    path("pages/", include(wagtail_urls)),
]
endef
define REST_FRAMEWORK
REST_FRAMEWORK = {
    # Use Django's standard `django.contrib.auth` permissions,
    # or allow read-only access for unauthenticated users.
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'
    ]
}
endef
define GIT_IGNORE
bin/
__pycache__
lib/
lib64
pyvenv.cfg
node_modules/
endef

export ALLAUTH_LAYOUT_BASE
export AUTHENTICATION_BACKENDS
export BABELRC
export BASE_TEMPLATE
export CLOCK_COMPONENT
export FRONTEND_APP
export GIT_IGNORE
export HOME_PAGE_MODEL
export HOME_PAGE_TEMPLATE
export INTERNAL_IPS
export JENKINS_FILE
export REST_FRAMEWORK
export URL_PATTERNS

# ------------------------------------------------------------------------------  
# Rules
# ------------------------------------------------------------------------------  

# Elastic Beanstalk

eb-check-env-default:  # https://stackoverflow.com/a/4731504/185820
ifndef ENV_NAME
	$(error ENV_NAME is undefined)
endif
ifndef INSTANCE_TYPE
	$(error INSTANCE_TYPE is undefined)
endif
ifndef LB_TYPE
	$(error LB_TYPE is undefined)
endif
ifndef SSH_KEY
	$(error SSH_KEY is undefined)
endif
ifndef VPC_ID
	$(error VPC_ID is undefined)
endif
ifndef VPC_SG
	$(error VPC_SG is undefined)
endif
ifndef VPC_SUBNET_EC2
	$(error VPC_SUBNET_EC2 is undefined)
endif
ifndef VPC_SUBNET_ELB
	$(error VPC_SUBNET_ELB is undefined)
endif

eb-create-default: eb-check-env
	eb create $(ENV_NAME) \
		-i $(INSTANCE_TYPE) \
		-k $(SSH_KEY) \
		-p $(PLATFORM) \
		--elb-type $(LB_TYPE) \
		--vpc \
		--vpc.id $(VPC_ID) \
		--vpc.elbpublic \
		--vpc.ec2subnets $(VPC_SUBNET_EC2) \
		--vpc.elbsubnets $(VPC_SUBNET_ELB) \
		--vpc.publicip \
		--vpc.securitygroups $(VPC_SG)

eb-deploy-default:
	eb deploy

eb-init-default:
	eb init

# npm

npm-init-default:
	npm init -y
	-git add package.json

npm-install-default:
	npm install
	-git add package-lock.json

npm-clean-default:
	rm -rvf node_modules/

# Django

django-graph-default:
	python manage.py graph_models -a -o $(PROJECT_NAME).png

django-show-urls-default:
	python manage.py show_urls

django-loaddata-default:
	python manage.py loaddata

django-migrate-default:
	python manage.py migrate

django-migrations-default:
	python manage.py makemigrations

django-serve-default:
	cd frontend; npm run watch &
	python manage.py runserver 0.0.0.0:8000

django-settings-default:
	echo "# $(PROJECT_NAME)" >> $(SETTINGS)
	echo "ALLOWED_HOSTS = ['*']" >> $(SETTINGS)
	echo "import dj_database_url, os" >> $(SETTINGS)
	echo "DATABASE_URL = os.environ.get('DATABASE_URL', \
		'postgres://$(DB_USER):$(DB_PASS)@$(DB_HOST):$(DB_PORT)/$(PROJECT_NAME)')" >> $(SETTINGS)
	echo "DATABASES['default'] = dj_database_url.parse(DATABASE_URL)" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('webpack_boilerplate')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('rest_framework')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('allauth')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('allauth.account')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('allauth.socialaccount')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('wagtailseo')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('wagtail.contrib.settings')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('django_extensions')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('debug_toolbar')" >> $(DEV_SETTINGS)
	echo "MIDDLEWARE.append('allauth.account.middleware.AccountMiddleware')" >> $(SETTINGS)
	echo "MIDDLEWARE.append('debug_toolbar.middleware.DebugToolbarMiddleware')" >> $(DEV_SETTINGS)
	echo "STATICFILES_DIRS.append(os.path.join(BASE_DIR, 'frontend/build'))" >> $(SETTINGS)
	echo "WEBPACK_LOADER = { 'MANIFEST_FILE': os.path.join(BASE_DIR, 'frontend/build/manifest.json'), }" >> $(SETTINGS)
	echo "$$REST_FRAMEWORK" >> $(SETTINGS)
	echo "$$INTERNAL_IPS" >> $(DEV_SETTINGS)
	echo "LOGIN_REDIRECT_URL = '/'" >> $(SETTINGS)
	echo "DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'" >> $(SETTINGS)
	echo "$$AUTHENTICATION_BACKENDS" >> $(SETTINGS)
	echo "TEMPLATES[0]['OPTIONS']['context_processors'].append('wagtail.contrib.settings.context_processors.settings')" >> $(SETTINGS)

django-shell-default:
	python manage.py shell

django-static-default:
	python manage.py collectstatic --noinput

django-su-default:
	python manage.py shell -c "from django.contrib.auth.models import User; \
		User.objects.create_superuser('admin', '', 'admin')"

django-test-default:
	python manage.py test

django-user-default:
	python manage.py shell -c "from django.contrib.auth.models import User; \
		User.objects.create_user('user', '', 'user')"

django-url-patterns-default:
	echo "$$URL_PATTERNS" > backend/$(URLS)

django-npm-install-default:
	cd frontend; npm install

django-npm-install-save-dev-default:
	cd frontend; npm install \
        eslint-plugin-react \
        eslint-config-standard \
        eslint-config-standard-jsx \
        mapbox-gl \
        react-date-range \
        react-image-crop \
        react-dom \
		@babel/core \
		@babel/preset-env \
		@babel/preset-react \
        --save-dev

django-npm-test-default:
	cd frontend; npm run test

django-npm-build-default:
	cd frontend; npm run build

django-open-default:
	open http://0.0.0.0:8000

# Git

git-ignore-default:
	echo "$$GIT_IGNORE" > .gitignore
	-git add .gitignore
	-git commit -a -m "Add .gitignore"
	-git push

git-branches-default:
	-for i in $(GIT_BRANCHES) ; do \
        git checkout -t $$i ; done

git-commit-default:
	-git commit -a -m $(GIT_MESSAGE)

git-push-default:
	-git push

git-commit-edit-default:
	-git commit -a

git-prune-default:
	git remote update origin --prune

git-set-upstream-default:
	git push --set-upstream origin main

git-commit-empty-default:
	git commit --allow-empty -m "Empty-Commit"

# Lint

lint-black-default:
	-black *.py
	-black backend/*.py
	-black backend/*/*.py
	-git commit -a -m "A one time black event"

lint-djlint-default:
	-djlint --reformat *.html
	-djlint --reformat backend/*.html
	-djlint --reformat backend/*/*.html
	-git commit -a -m "A one time djlint event"

lint-flake-default:
	-flake8 *.py
	-flake8 backend/*.py
	-flake8 backend/*/*.py

lint-isort-default:
	-isort *.py
	-isort backend/*.py
	-isort backend/*/*.py
	-git commit -a -m "A one time isort event"

lint-ruff-default:
	-ruff *.py
	-ruff backend/*.py
	-ruff backend/*/*.py
	-git commit -a -m "A one time ruff event"

# Database

mysql-init-default:
	-mysqladmin -u root drop $(PROJECT_NAME)
	-mysqladmin -u root create $(PROJECT_NAME)

pg-init-default:
	-dropdb $(PROJECT_NAME)
	-createdb $(PROJECT_NAME)


# pip

pip-freeze-default:
	pip3 freeze | sort > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .
	-git add requirements.txt
	-git commit -a -m "Freezing requirements."

pip-install-default:
	$(MAKE) pip-upgrade
	pip3 install wheel
	pip3 install -r requirements.txt

pip-install-dev-default:
	pip3 install -r requirements-dev.txt

pip-install-test-default:
	pip3 install -r requirements-test.txt

pip-install-upgrade-default:
	cat requirements.txt | awk -F \= '{print $$1}' > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .
	pip3 install -U -r requirements.txt
	pip3 freeze | sort > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .

pip-upgrade-default:
	pip3 install -U pip

pip-init-default:
	touch requirements.txt
	-git add requirements.txt

# README

readme-init-default:
	@echo "$(PROJECT_NAME)" > README.rst
	@echo "================================================================================" >> README.rst
	-@git add README.rst
	-git commit -a -m "Add readme"

readme-edit-default:
	vi README.rst

readme-open-default:
	open README.pdf

readme-build-default:
	rst2pdf README.rst

# Sphinx

sphinx-init-default:
	$(MAKE) sphinx-install
	sphinx-quickstart -q -p $(PROJECT_NAME) -a $(USER) -v 0.0.1 $(RANDIR)
	mv $(RANDIR)/* .
	rmdir $(RANDIR)

sphinx-install-default:
	echo "Sphinx\n" > requirements.txt
	@$(MAKE) pip-install
	@$(MAKE) pip-freeze
	-git add requirements.txt

sphinx-build-default:
	sphinx-build -b html -d _build/doctrees . _build/html

sphinx-build-pdf-default:
	sphinx-build -b rinoh . _build/rinoh

sphinx-serve-default:
	cd _build/html;python -m http.server

# Wagtail

wagtail-clean-default:
	-rm -vf .dockerignore
	-rm -vf Dockerfile
	-rm -vf manage.py
	-rm -vf requirements.txt
	-rm -rvf home/
	-rm -rvf search/
	-rm -rvf backend/
	-rm -rvf frontend/
	-rm -vf README.rst

wagtail-init-default: db-init wagtail-install
	wagtail start backend .
	$(MAKE) pip-freeze
	export SETTINGS=backend/settings/base.py DEV_SETTINGS=backend/settings/dev.py; $(MAKE) django-settings
	export URLS=urls.py; $(MAKE) django-url-patterns
	-git add backend
	-git add requirements.txt
	-git add manage.py
	-git add Dockerfile
	-git add .dockerignore
	@echo "$$HOME_PAGE_MODEL" > home/models.py
	@$(MAKE) django-migrations
	-git add home
	-git add search
	@$(MAKE) django-migrate
	@$(MAKE) su
	@echo "$$BASE_TEMPLATE" > backend/templates/base.html
	mkdir -p backend/templates/allauth/layouts
	@echo "$$ALLAUTH_LAYOUT_BASE" > backend/templates/allauth/layouts/base.html
	-git add backend/templates/allauth/layouts/base.html
	@echo "$$HOME_PAGE_TEMPLATE" > home/templates/home/home_page.html
	python manage.py webpack_init --no-input
	@echo "$$CLOCK_COMPONENT" > frontend/src/components/Clock.js
	@echo "$$FRONTEND_APP" > frontend/src/application/app.js
	@echo "$$BABELRC" > frontend/.babelrc
	-git add frontend
	-git commit -a -m "Add frontend"
	@$(MAKE) django-npm-install
	@$(MAKE) django-npm-install-save-dev
	@$(MAKE) cp
	@$(MAKE) lint-isort
	@$(MAKE) lint-black
	@$(MAKE) cp
	@$(MAKE) lint-flake
	@$(MAKE) readme
	@$(MAKE) gitignore
	@$(MAKE) serve

wagtail-install-default:
	pip3 install \
        djangorestframework \
        django-allauth \
        django-after-response \
        django-ckeditor \
        django-countries \
        django-crispy-forms \
        django-debug-toolbar \
        django-extensions \
        django-imagekit \
        django-import-export \
        django-ipware \
        django-recurrence \
        django-registration \
        django-richtextfield \
        django-timezone-field \
        dj-database-url \
        mailchimp-marketing \
        mailchimp-transactional \
        psycopg2-binary \
        python-webpack-boilerplate \
        wagtail \
        wagtail-seo 

# Misc

help-default:
	@for makefile in $(MAKEFILE_LIST); do \
        $(MAKE) -pRrq -f $$makefile : 2>/dev/null \
            | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
            | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' \
            | xargs | tr ' ' '\n' \
            | awk '{printf "%s\n", $$0}' ; done | less # http://stackoverflow.com/a/26339924 Given a base.mk, Makefile and project.mk, and base.mk and project.mk included from Makefile, print target names from all makefiles.

usage-default:
	@echo "Project Makefile 🤷"
	@echo "Usage: make [options] [target] ..."
	@echo "Examples:"
	@echo "   make help    Print all targets"
	@echo "   make usage   Print this message"

jenkins-init-default:
	@echo "$$JENKINS_FILE" > Jenkinsfile

make-default:
	-git add base.mk
	-git add Makefile
	-git commit -a -m "Add/update project-makefile files"
	-git push

python-serve-default:
	@echo "\n\tServing HTTP on http://0.0.0.0:8000\n"
	python -m http.server

rand-default:
	@openssl rand -base64 12 | sed 's/\///g'

review-default:
ifeq ($(UNAME), Darwin)
	@open -a $(REVIEW_EDITOR) `find backend -name \*.py | grep -v migrations` `find backend -name \*.html` `find $(PROJECT_NAME) -name \*.js`
else
	@echo "Unsupported"
endif

build-default: sphinx-build
b-default: build 
ce-default: git-commit-edit-push
clean-default: npm-clean
cp-default: git-commit-push
db-init-default: pg-init
django-init-default: wagtail-init
edit-default: readme-edit
e-default: edit
h-default: help
init-default: wagtail-init
install-default: pip-install
i-default: install
git-commit-edit-push-default: git-commit-edit git-push
git-commit-push-default: git-commit git-push
gitignore-default: git-ignore
open-default: django-open
o-default: open
p-default: git-push
readme-default: readme-init
serve-default: django-serve
su-default: django-su
s-default: serve
u-default: usage

# Overrides

%: %-default  # https://stackoverflow.com/a/49804748
	@ true
