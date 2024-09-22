from unicodedata import name
from flask import Flask
from flask import jsonify
import requests
from flask import Flask, render_template, request


def proc_filt(x):
    url = 'https://dv1615-apimanagement-lab.azure-api.net/vision/v2.0/analyze?visualFeatures=Tags'
    body = {'url':x}
    headers = {'Ocp-Apim-Subscription-Key': '6af7226881af4bf4a83ccd810023a5a0'}

    response = requests.post(url, headers=headers, json=body)
    y=response.json()
    #lis_97=[]
    name_lis=[]
    for key,value in y.items():
        if key=="tags":
            for lis in value:
                if lis["confidence"]>=0.97:
                    #lis_97.append(lis)
                    name_lis.append(lis["name"])
    #data={"data":lis_97}
    return name_lis

def trans(f):
    trans_nam=[]
    for i in f:
        url1 = 'https://dv1615-apimanagement-lab.azure-api.net/translate?api-version=3.0&from=en&to=sv'
        body1 = [
            {
                "text":f"{i}"
            }
        ]
        headers1 = {'Ocp-Apim-Subscription-Key': '6af7226881af4bf4a83ccd810023a5a0'}
        response1 = requests.post(url1, headers=headers1, json=body1)
        x=response1.json()
        for a in x:
            for key,value in a.items():
                for f in value:
                    for s,v in f.items():
                        if s == "text":
                            trans_nam.append(v)
    return trans_nam

def sok_lager(p):
    lista_lager=[]
    for g in p:
        URL = 'https://lager.emilfolino.se/v2/products/everything'

        # Use requests module to get JSON data
        response = requests.get(URL)

        # Turns response json object into a Dictionary
        products_dict = response.json()

        lis=[]
        for x in products_dict["data"]:
            lis.append(x["name"])

        dic={}
        for s,f in enumerate(lis):
            if f not in lis[:s]:
                dic.update({f:0})

        for i in products_dict["data"]:   
            if isinstance(i["stock"],int):
                if i["name"] in dic:
                    dic[i["name"]]=dic[i["name"]]+i["stock"]
                else:
                    dic.update({i["name"]:i["stock"]})

        #data={"data":[dic]}
        
        for key,value in dic.items():
            x=key.lower()
            y=str(key)+":"+str(value)
            if f"{g}" in x:
                lista_lager.append(y)
    return lista_lager


app=Flask(__name__)
@app.route("/")
def hello_world():
    return "welcome to our webbsite to search for a product using URL add in the search bar: \image_search "

@app.route('/image_search')
def image_search():
    image_url = request.args.get("image-url", "")
    if image_url:
        # do lots of stuff¨
        namn=proc_filt(image_url)
        tarns_namn=trans(namn)
        sok=sok_lager(tarns_namn)
        return jsonify("lager saldo:",sok,"namn med sanolikhet over 97%:",namn,"namn efter oversattning:",tarns_namn)
    return render_template("index.html", image_url=image_url)
if __name__=="__main__":
    app.run(host="0.0.0.0",port=5000)