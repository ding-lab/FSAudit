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
    parser.add_argument("-i", "--input", dest="input", help="Input FS Audit summary file name")
    parser.add_argument("-m", "--mode", dest="mode", default="localhost", help="Ad hoc mode.  localhost, katmai, main")

    args = parser.parse_args()
    return args

def get_df(input_fn):
    df = pd.read_csv(args.input, sep='\t')

    # shorten extension to first 20 characters
    # https://stackoverflow.com/questions/36505847/substring-of-an-entire-column-in-pandas-dataframe
    df['ext'] = df['ext'].str[:20]
    return df

def get_volume_names_list(df):
    volume_names = df["volume_name"].unique()
    dropdown_list = []
    for v in volume_names:
        d={'label':v, 'value':v}
        dropdown_list.append(d)
    return dropdown_list

args = parse_command_line()

if not os.path.isfile(args.input):
    raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), args.input)

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

df = get_df(args.input)

group_list = get_volume_names_list(df)

app.layout = html.Div([
    dcc.RadioItems(
        id='value_select',
        options=[
            {'label': 'Cumulative Size', 'value': 'size'},
            {'label': 'Count', 'value': 'count'},
        ],
        value='size',
        labelStyle={'display': 'inline-block'}
    ),
    dcc.Dropdown(
        id='group_select',
        options=group_list,
        multi=True,   # need to iterate over a list probably 
    ),
    html.Div(id="display_label"),
    dcc.Graph(
        id='scatter_plot'
    ),
    html.Div(id="display_low"), 
    dcc.Input(id="range_select_low", type="number"),
    html.Div(id="display_high"), 
    dcc.Input(id="range_select_high", type="number"),

#            "Low = {}".format(low), 
#            dcc.Input(id="range_select_low"),
#            "High = {}".format(low), 
#            dcc.Input(id="range_select_high")])

])

# Get label for range selection with value "Cumulative File Size" or "File count" as appropriate
@app.callback(
    dash.dependencies.Output("display_label", "children"),
    dash.dependencies.Input("value_select", "value"))
def update_label(value_selection):
    if value_selection == "size":
        label="Cumulative file size"
    elif value_selection == "count":
        label="File count"
    else:
        assert False, "Unknown value_selection: " + value_selection
    return label


@app.callback(
    dash.dependencies.Output("display_low", "children"),
    dash.dependencies.Input("group_select", "value"),
    dash.dependencies.Input("value_select", "value"))
def update_min_value_label(volume_names, value_selection):
    if volume_names is not None:
        df2 = df[df["volume_name"].isin(volume_names)]

        if value_selection == "size":
            low = min(df2["total_size"])
            val = "Min cumulative total size: {}".format(low)
        elif value_selection == "count":
            low = min(df2["count"])
            val = "Min file count: {}".format(low)
        else:
            assert False, "Unknown value_selection: " + value_selection
        return val
    else:
        return "Low value undefined"

@app.callback(
    dash.dependencies.Output("display_high", "children"),
    dash.dependencies.Input("group_select", "value"),
    dash.dependencies.Input("value_select", "value"))
def update_max_value_label(volume_names, value_selection):
    if volume_names is not None:
        df2 = df[df["volume_name"].isin(volume_names)]

        if value_selection == "size":
            high = max(df2["total_size"])
            val = "Max cumulative total size: {}".format(high)
        elif value_selection == "count":
            high = max(df2["count"])
            val = "Max file count: {}".format(high)
        else:
            assert False, "Unknown value_selection: " + value_selection
        return val
    else:
        return "High value undefined"

@app.callback(
    dash.dependencies.Output("scatter_plot", "figure"),
    [dash.dependencies.Input("group_select", "value"),
     dash.dependencies.Input("value_select", "value"),
     dash.dependencies.Input("range_select_low", "value"),
     dash.dependencies.Input("range_select_high", "value"),
     ])
def update_scatter_plot(volume_names, value_selection, range_low, range_high):
    print("scatter plot: value selection = ", value_selection)
    if volume_names is None:
        return px.scatter(height=600)

    if range_low is None:
        range_low = 0
    df2 = df[df["volume_name"].isin(volume_names)]
    if value_selection == "size":
        if range_high is None:
            mask = (df2["total_size"] > range_low)
        else:
            mask = (df2["total_size"] > range_low) & (df2["total_size"] < range_high)
        fig = px.scatter(df2[mask],
                     x="ext", y="owner_name",
                     size="total_size", color="owner_name", hover_name="owner_name",
                     log_x=False, size_max=60, height=600)
    elif value_selection == "count":
        if range_high is None:
            mask = (df2["count"] > range_low)
        else:
            mask = (df2["count"] > range_low) & (df2["count"] < range_high)
        fig = px.scatter(df2[mask],
                     x="ext", y="owner_name",
                     size="count", color="owner_name", hover_name="owner_name",
                     log_x=False, size_max=60, height=600)
    else:
        assert False, "Unknown value_selection: " + value_selection
    return fig                 

# Alternative entry to run on command line
def main():
    print(df)

if __name__ == '__main__':
    if args.mode == "localhost":
        print("Running as localhost")
        app.run_server(debug=True)
    elif args.mode == "katmai":
        # To run on katmai for instance, according to below link, use this:
        # https://community.plotly.com/t/how-to-deploy-dash-app-on-local-network/7169
        # This seems to be an alternative to deploying on Dash Enterprise
        # https://dash.plotly.com/deployment
        print("Running on 0.0.0.0:8080")
        app.run_server(debug=False,port=8080,host='0.0.0.0')
        # Access via http://10.22.24.2:8080/
    elif args.mode == "main":
        print("Calling main()")
        main()
    else:
        raise Exception('Unknown mode, must be one of localhost, katmai, main', args.mode)

# this is for running dash



