# Run this app with `python app.py` and
# visit http://127.0.0.1:8050/ in your web browser.
# Running with Python 3.7.3

# Dropdown components from: https://dash.plotly.com/dash-core-components/dropdown

import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly.express as px
import pandas as pd


external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

df = pd.read_csv('file://localhost/Users/mwyczalk/Projects/FSAudit/FSAudit.v2/dash-dev/dat/MGI.summary-consolidated.dat', sep='\t')

# shorten extension to first 20 characters
# https://stackoverflow.com/questions/36505847/substring-of-an-entire-column-in-pandas-dataframe
df['ext'] = df['ext'].str[:20]

@app.callback(
    dash.dependencies.Output("cumulative_size_bubble", "figure"),
    [dash.dependencies.Input("demo-dropdown", "value")])
def update_cumulative_size(volume_name):
    df2 = df[df["volume_name"]==volume_name]
    fig1 = px.scatter(df2,
                 x="ext", y="owner_name",
                 size="cumulative_size", color="owner_name", hover_name="owner_name",
                 log_x=False, size_max=60)
    return fig1                 

@app.callback(
    dash.dependencies.Output("count_bubble", "figure"),
    [dash.dependencies.Input("demo-dropdown", "value")])
def update_count(volume_name):
    df2 = df[df["volume_name"]==volume_name]
    fig2 = px.scatter(df2,
                 x="ext", y="owner_name",
                 size="count", color="owner_name", hover_name="owner_name",
                 log_x=False, size_max=60)
    return fig2

app.layout = html.Div([
    dcc.Dropdown(
        id='demo-dropdown',
        options=[
            {'label': 'gc2500', 'value': 'gc2500'},
            {'label': 'gc2508', 'value': 'gc2508'},
            {'label': 'gc2509', 'value': 'gc2509'}
        ],
        value='gc2500'
    ),
    html.P("Cumulative size"),
    dcc.Graph(
        id='cumulative_size_bubble'
    ),
    html.P("File count"),
    dcc.Graph(
        id='count_bubble'
    )
])

def main():
    print("Hello")
    print(df)


if __name__ == '__main__':
# this is for running dash
    app.run_server(debug=True)
#    main()

# To run on katmai for instance, according to below link, use this:
# app.run_server(debug=‘False’,port=8080,host=‘0.0.0.0’)
# https://community.plotly.com/t/how-to-deploy-dash-app-on-local-network/7169
# This seems to be an alternative to deploying on Dash Enterprise
# https://dash.plotly.com/deployment



