import sevenbridges as sbg
import numpy as np
import pandas as pd

# Get a connection to SBG.
c = sbg.Config(profile='bdc')
api = sbg.Api(config=c)

# Read in the tasks file.
tasks = pd.read_csv("benchmark_tasks.tsv", sep="\t", header=0)

stats = tasks[["task_id"]]
stats["cost"] = np.nan
stats["status"] = np.nan
stats["duration"] = np.nan

for index in stats.index:
    task = api.tasks.get(stats.loc[index, "task_id"])
    stats.loc[index, "cost"] = task.price.amount
    stats.loc[index, "status"] = task.status
    stats.loc[index, "duration"] = int(np.round(task.execution_status.duration / 60 / 1000)) # I think this is in milliseconds.

# Combine with task info.
stats = tasks.merge(stats, on=["task_id"])

# Write to a file.
stats.to_csv("benchmark_stats.tsv", sep="\t")
