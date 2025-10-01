#!/usr/bin/env python3
# pip3 install click selenium
# look at using phantomjs instead??

import click
import time
import re
import os 
import html

from selenium import webdriver

from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def cleanhtml(raw_html):
    # identify and remove all the html tags
    cleanr = re.compile('<.*?>')
    cleantext = re.sub(cleanr, '', raw_html)
    # convert html entities to actual characters
    plaintext = html.unescape(cleantext)
    return plaintext

def get_tpam_password(domain, user, password):

    # configure chrome
    options = Options()
    #options.add_argument('--headless')
    #options.add_argument('--disable-gpu')
    options.add_argument('--window-size=700,600')

    # initialize the driver
    driver = webdriver.Chrome(chrome_options=options)

    # load the login page and wait until there is a login form
    driver.get('https://{}'.format(domain))
    # if running headed
    WebDriverWait(driver, 600).until(EC.presence_of_element_located((By.ID, 'tokenTimeRemaining')))
    # if running headless
    WebDriverWait(driver, 600).until(EC.presence_of_element_located((By.ID, 'loginUserName')))

    #time.sleep(500)

    # fill out the username
    userElement = driver.find_element_by_id('loginUserName')
    userElement.send_keys(user)

    # fill out the password
    passwordElement = driver.find_element_by_id('loginPassword')
    passwordElement.send_keys(password)

    # submit the form
    submitElement = driver.find_element_by_id('btnLogin')
    submitElement.click()

    # wait until the page loads and shows current requests element
    WebDriverWait(driver, 600).until(EC.presence_of_element_located((By.ID, 'CurrentRequests')))

    # click on the current requsets tab
    elementAuthorize = driver.find_element_by_css_selector('a#CurrentRequests')
    elementAuthorize.click()

    # wait until the requests table loads
    WebDriverWait(driver, 600).until(EC.presence_of_element_located((By.ID, 'requestsTable')))

    # grab the current active request
    currentRequest = driver.find_element_by_css_selector('#requestsTable > tbody > tr > td > a')
    currentRequest.click()

    # wait until the request loads
    WebDriverWait(driver, 600).until(EC.presence_of_element_located((By.ID, 'ReqReasonCodeText')))

    # grab the current active request
    passwordTab = driver.find_element_by_css_selector('a#Password')
    passwordTab.click()

    # wait until the password page loads
    WebDriverWait(driver, 600).until(EC.presence_of_element_located((By.ID, 'innerDisplayPassword')))

    # grab the tpam password
    tpamPasswordRaw = driver.find_element_by_css_selector('.coloredPassword')
    tpamPasswordRawValue = tpamPasswordRaw.get_attribute('innerHTML')

    # remove the span tags
    tpamPassword = cleanhtml(tpamPasswordRawValue)

    # close chrome out
    driver.quit()

    return tpamPassword

@click.command()
@click.option('-d', '--domain', required=True, help='TPAM url')
@click.option('-u', '--user', required=True, help='TPAM username')
@click.option('-p', '--password', required=True, help='TPAM password')

def main(domain, user, password):
    password = get_tpam_password(domain, user, password)
    # send password to the clipboard (osx)
    #os.system("echo '%s' | pbcopy" % password)
    # send password to the clipboard (linux)
    os.system("echo '%s' | xclip" % password)
    os.system("echo '%s' | xclip -selection clipboard" % password)

if __name__ == '__main__':
    main()
