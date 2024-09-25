import pandas as pd
import plotly.express as px
import plotly.io as pio

# Define the path to the log file
file_path = 'format.log'


fields = ["Region","Date-hour","record_count","file_count","s---_flag_count","s--r_flag_count","s-p-_flag_count","s-pr_flag_count","s---_flag_percent","s--r_flag_percent","s-p-_flag_percent","s-pr_flag_percent"]
# Reading the data from the log file
df = pd.read_csv(file_path)

# Convert 'Date-hour' to a datetime object for better plotting
df['Date-hour'] = pd.to_datetime(df['Date-hour'], format='%Y%m%d')

for field in fields:
    if field == 'Date-hour' or field == 'Region':
        continue
    else:
        # Filter only the necessary columns (Region, Date-hour, record_count)
        df_filtered = df[['Region', 'Date-hour', field]]
        df_filtered = df.reset_index()

        # Generate the first chart for 8 regions over time
        regions = ['tee', 'tew', 'ta', 'ma', 'is', 'al', 'ah', 'sh']
        df_chart = df_filtered[df_filtered['Region'].isin(regions)]

        # Create the interactive line chart using Plotly
        fig = px.line(df_chart, x='Date-hour', y=field, color='Region', markers=True,
                      labels={
                          "Date-hour": "Date-Hour",
                          field: field,
                          "Region": "Region"
                      },
                      title=field, width=1800, height=1000)

        # Update layout for better display
        fig.update_layout(
            xaxis_title='Date-Hour',
            yaxis_title='Record Count',
            legend_title_text='Region',
            hovermode='x unified',
            template='plotly_dark'
        )

        # save images
        fig.write_image(f'{field}.png')
