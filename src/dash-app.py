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
#    df['ext'] = df['ext'].str[:20]
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

# type_select defines the type of scatter plot we have:
# 'Owner vs Extension' - default. group select is volume names
# 'Owner vs Volume' - no group select
# 'Extension vs Volume' - group select is user names

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
    dcc.RadioItems(
        id='type_select',
        options=[
            {'label': 'Owner vs Extension', 'value': 'oe'},
            {'label': 'Owner vs Volume', 'value': 'ov'},
            {'label': 'Extension vs Volume', 'value': 'ev'},
        ],
        value='oe',
        labelStyle={'display': 'inline-block'}
    ),
    dcc.Checklist(
        id='group_select',
        options=get_volume_names_list(df),
        value=df["volume_name"].unique(),
        labelStyle={'display': 'inline-block'}
    ),
    html.Div(id="display_label"),
    dcc.Graph(
        id='scatter_plot'
    ),
    html.Div(id="display_low"), 
    dcc.Input(id="range_select_low", type="number"),
    html.Div(id="display_high"), 
    dcc.Input(id="range_select_high", type="number"),
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


#            {'label': 'Owner vs Extension', 'value': 'oe'},
#            {'label': 'Owner vs Volume', 'value': 'ov'},
#            {'label': 'Extension vs Volume', 'value': 'ev'},
@app.callback(
    dash.dependencies.Output("display_low", "children"),
    dash.dependencies.Input("group_select", "value"),
    dash.dependencies.Input("type_select", "value"),
    dash.dependencies.Input("value_select", "value"))
def update_min_value_label(group_selection, type_selection, value_selection):
    if group_selection is not None:
        if type_selection == "oe":
            df2 = df[df["volume_name"].isin(group_selection)]
        elif type_selection == "ov":
            df2 = df
        elif type_selection == "ev":                
            df2 = df[df["owner_name"].isin(group_selection)]
        else:
            assert False, "Unknown type_selection " + type_selection

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
    dash.dependencies.Input("type_select", "value"),
    dash.dependencies.Input("value_select", "value"))
def update_max_value_label(group_selection, type_selection, value_selection):
    if group_selection is not None:
        if type_selection == "oe":
            df2 = df[df["volume_name"].isin(group_selection)]
        elif type_selection == "ov":
            df2 = df
        elif type_selection == "ev":                
            df2 = df[df["owner_name"].isin(group_selection)]
        else:
            assert False, "Unknown type_selection " + type_selection

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

# Given df, merge counts and total sizes across all volume_name
def group_by_volume(df, group_selection):
    df2 = df[df["volume_name"].isin(group_selection)]
    df_sum = df2.groupby(['ext', 'owner_name'], as_index=False)['total_size'].sum()
    df_count = df2.groupby(['ext', 'owner_name'], as_index=False)['count'].sum()
    df_merged = pd.merge(df_sum, df_count, on=['ext', 'owner_name'])
    return df_merged

def group_by_extension(df):
    df_sum = df.groupby(['volume_name', 'owner_name'], as_index=False)['total_size'].sum()
    df_count = df.groupby(['volume_name', 'owner_name'], as_index=False)['count'].sum()
    df_merged = pd.merge(df_sum, df_count, on=['volume_name', 'owner_name'])
    return df_merged

def group_by_owner(df, group_selection):
    df2 = df[df["owner_name"].isin(group_selection)]
    df_sum = df2.groupby(['volume_name', 'ext'], as_index=False)['total_size'].sum()
    df_count = df2.groupby(['volume_name', 'ext'], as_index=False)['count'].sum()
    df_merged = pd.merge(df_sum, df_count, on=['volume_name', 'ext'])
    return df_merged


#     1		8
#     2	volume_name	MGI.gc2500
#     3	timestamp	20210825
#     4	ext	.bedpe
#     5	owner_name	qgao
#     6	total_size	353988
#     7	count	148
@app.callback(
    dash.dependencies.Output("scatter_plot", "figure"),
    [dash.dependencies.Input("group_select", "value"),
     dash.dependencies.Input("type_select", "value"),
     dash.dependencies.Input("value_select", "value"),
     dash.dependencies.Input("range_select_low", "value"),
     dash.dependencies.Input("range_select_high", "value"),
     ])
def update_scatter_plot(group_selection, type_selection, value_selection, range_low, range_high):
    # group selection used to be called volume_names, can be either list of volumes or users 
    if group_selection is None:
        return px.scatter(height=1000)

    if range_low is None:
        range_low = 0
    if type_selection == "oe":
        x_data = "ext"
        y_data = "owner_name"
        color_data = "owner_name"
        df2 = group_by_volume(df, group_selection)

    elif type_selection == "ov":
        x_data = "volume_name"
        y_data = "owner_name"
        color_data = "owner_name"
        df2 = group_by_extension(df)
        print(df2)

    elif type_selection == "ev":                
        x_data = "ext"
        y_data = "volume_name"
        color_data = "volume_name"
        df2 = group_by_owner(df, group_selection)
    else:
        assert False, "Unknown type_selection " + type_selection
    if value_selection == "size":
        value_data = "total_size"
    elif value_selection == "count":
        value_data = "count"
    else:
        assert False, "Unknown value_selection: " + value_selection

    if range_high is None:
        mask = (df2[value_data] > range_low)
    else:
        mask = (df2[value_data] > range_low) & (df2[value_data] < range_high)

    # Shorten extensions to first 20 characters for display
    if 'ext' in df2.columns:
        df2['ext'] = df2['ext'].str[:20]
    fig = px.scatter(df2[mask],
                 x=x_data, y=y_data, size=value_data, color=color_data, hover_name=color_data,
                 size_max=60, height=1000)

    return fig                 

# Alternative entry to run on command line
def main():

    volume_selection=['MGI.gc2500', 'MGI.gc2508', 'MGI.gc2509', 'MGI.gc2510', 'MGI.gc2511', 'MGI.gc2534']
    owner_selection=['mwyczalk', 'qgao', 'rmashl']

    df_gbv = group_by_volume(df, volume_selection)
    print("Group by volume")
    print(df_gbv)
    df_gbe = group_by_extension(df)
    print("Group by extension")
    print(df_gbe)
    df_gbo = group_by_owner(df, owner_selection)
    print("Group by owner" + str(owner_selection))
    print(df_gbo)


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



