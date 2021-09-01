# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

# Run this app with `python app.py` and
# visit http://127.0.0.1:8050/ in your web browser.
# Running with Python 3.7.3

# https://stackoverflow.com/questions/5574702/how-to-print-to-stderr-in-python
from __future__ import print_function
import sys, os, errno, argparse

import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly.express as px
import pandas as pd

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def parse_command_line():
    parser = argparse.ArgumentParser(description="Run Dash server on FSAudit summary data")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-i", "--input", dest="input", help="Input vcf file name")

    args = parser.parse_args()
    return args


def main():
    print("Hello")
    print(df)

args = parse_command_line()

if not os.path.isfile(args.input):
    raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), args.input)

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
df = pd.read_csv(args.input, sep='\t')

# shorten extension to first 20 characters
# https://stackoverflow.com/questions/36505847/substring-of-an-entire-column-in-pandas-dataframe
df['ext'] = df['ext'].str[:20]

print(df)

volume_names = df["volume_name"].unique()
dropdown_list = []
for v in volume_names:
    d={'label':v, 'value':v}
    dropdown_list.append(d)

# get ranges for cumulative size and count
max_count = df["count"].max()
max_size = df["total_size"].max()

app.layout = html.Div([
    dcc.Dropdown(
        id='demo-dropdown',
        options=dropdown_list,
        value="gc2500"
    ),
    html.P("Cumulative size"),
    dcc.Graph(
        id='cumulative_size_bubble'
    ),
    dcc.RangeSlider(
        id='size-slider',
        min=0, max=max_size,
        value=[0, max_size]
    ),
    html.P("File count"),
    dcc.Graph(
        id='count_bubble'
    ),
    dcc.RangeSlider(
        id='count-slider',
        min=0, max=max_count,
        value=[0, max_count]
    ),
])

@app.callback(
    dash.dependencies.Output("cumulative_size_bubble", "figure"),
    [dash.dependencies.Input("demo-dropdown", "value"),
     dash.dependencies.Input("size-slider", "value") ])
def update_cumulative_size(volume_name, slider_range):
    df2 = df[df["volume_name"]==volume_name]
    low, high = slider_range
    mask = (df2["total_size"] > low) & (df2["total_size"] < high)
    fig1 = px.scatter(df2[mask],
                 x="ext", y="owner_name",
                 size="total_size", color="owner_name", hover_name="owner_name",
                 log_x=False, size_max=60)
    return fig1                 

@app.callback(
    dash.dependencies.Output("count_bubble", "figure"),
    [dash.dependencies.Input("demo-dropdown", "value"),
     dash.dependencies.Input("count-slider", "value") ])
def update_count(volume_name, slider_range):
    df2 = df[df["volume_name"]==volume_name]
    low, high = slider_range
    mask = (df2["count"] > low) & (df2["count"] < high)
    fig2 = px.scatter(df2[mask],
                 x="ext", y="owner_name",
                 size="count", color="owner_name", hover_name="owner_name",
                 log_x=False, size_max=60)
    return fig2

if __name__ == '__main__':
# this is for running dash on katmai
    app.run_server(debug=True,port=8080,host='0.0.0.0')
  #  app.run_server(debug=True)
#    main()

# To run on katmai for instance, according to below link, use this:
# app.run_server(debug=False,port=8080,host='0.0.0.0')
# https://community.plotly.com/t/how-to-deploy-dash-app-on-local-network/7169
# This seems to be an alternative to deploying on Dash Enterprise
# https://dash.plotly.com/deployment



