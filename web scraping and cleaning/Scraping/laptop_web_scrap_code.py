from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import time

s = Service('C:/Users/Admin/Desktop/chromedriver.exe')
chrome_options = Options()
chrome_options.add_experimental_option("detach", True)
driver = webdriver.Chrome(service = s, options=chrome_options)

driver.get('https://www.smartprix.com/laptops/exclude_out_of_stock-exclude_upcoming-stock')
time.sleep(2)

old_height = driver.execute_script('return document.body.scrollHeight')
counter = 1
while True:
    driver.find_element(by=By.XPATH, value='//*[@id="app"]/main/div[1]/div[2]/div[3]').click()
    time.sleep(1)
    new_height = driver.execute_script('return document.body.scrollHeight')
    print(old_height)
    print(new_height)
    print(counter)
    counter+=1
    if new_height == old_height:
        break
    old_height = new_height

html = driver.page_source
with open('laptop.html', 'w', encoding='utf-8') as f:
    f.write(html)