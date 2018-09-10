#!/usr/bin/env python3
# pip3 install click selenium
# look at using phantomjs instead??

import click

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def get_auth_cookie(domain, login, password):

    # configure chrome
    options = Options()
    #options.add_argument('--headless')
    #options.add_argument('--disable-gpu')
    options.add_argument('--window-size=700,600')

    driver = webdriver.Chrome(chrome_options=options)

    # load the login page and wait until the title contains GitLab
    driver.get("https://{}/login".format(domain))
    WebDriverWait(driver, 10).until(EC.title_contains("GitLab"))

    # click on the gitlab button to continue
    gitlabElement = driver.find_element_by_partial_link_text("GitLab")
    gitlabElement.click()

    # wait for the sign in page to load
    WebDriverWait(driver, 10).until(EC.title_contains("Sign in"))

    # fill out the username
    emailElement = driver.find_element_by_id('username')
    emailElement.send_keys(login)

    # fill out the password
    passwordElement = driver.find_element_by_id('password')
    passwordElement.send_keys(password)

    # submit the form
    passwordElement.submit()

    # wait until the page loads
    WebDriverWait(driver, 600).until(EC.title_contains("User Settings"))

    # authorize mattermost to use your account
    #elementAuthorize = driver.find_element_by_name('commit')
    elementAuthorize = driver.find_element_by_css_selector('input.btn-success')
    elementAuthorize.click()

    WebDriverWait(driver, 600).until(EC.title_contains("Mattermost"))

    auth_cookie = None
    for cookie in driver.get_cookies():
        if cookie['name'] == 'MMAUTHTOKEN':
            auth_cookie = cookie

    driver.quit()

    return auth_cookie


@click.command()
@click.option('-d', '--domain', required=True, help='Mattermost url')
@click.option('-u', '--user', required=True, help='Mattermost username')
@click.option('-i', '--ircd', required=True, help='Mattermost ircd server')
@click.option('-t', '--team', required=True, help='Mattermost team to login as')
@click.option('-p', '--password', required=True, help='Mattermost password')

def main(domain, user, password, ircd, team):
    cookie = get_auth_cookie(domain, user, password)
    token  = cookie['value']
    print('login {} {} {} MMAUTHTOKEN={}'.format(ircd, team, user, token))

if __name__ == "__main__":
    main()
