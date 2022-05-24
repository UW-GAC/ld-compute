import sevenbridges as sbg
import pandas as pd
import numpy as np
from itertools import product

gds_filenames = {
    "10k": "_1_freeze.5b.chr22.phased.pass.minDP0.remDuplicates.subset.gds",
    "36k": "_3_freeze.5b.chr22.phased.pass.minDP0.remDuplicates.subset.gds",
    "50k": "freeze.5b.chr22.phased.pass.minDP0.remDuplicates.gds",
}

variant_filenames = {
    "1000": "variants_1000.rds",
    "2000": "variants_2000.rds",
    "5000": "variants_5000.rds",
    "10000": "variants_10000.rds",
    "20000": "variants_20000.rds",
}


c = sbg.Config(profile='bdc')
api = sbg.Api(config=c)

project = 'amstilp/ld-compute-devel'
app = 'amstilp/ld-compute-devel/ld-set'

# Look up variant files
variant_files = {}
for key, filename in variant_filenames.items():
    variant_files[key] = api.files.query(project=project, names=[filename])[0]

# Look up sample file ids
gds_files = {}
for key, filename in gds_filenames.items():
    gds_files[key] = api.files.query(project=project, names=[filename])[0]

# Set up all the tasks.

# Create a grid to populate.
temp_dict = {
    "task_id": [np.nan],
    "n_samples": [key for key in gds_files.keys()],
    "n_variants": [key for key in variant_files.keys()],
    "interruptible": [True],
    "instance_type": ["c4.2xlarge"],
    "methods": [["r2"]],
    "cpu": [8],
}
standard_tasks = pd.DataFrame(
    #[row for row in product([""], gds_filenames.keys(), variant_filenames.keys(),)],
    [row for row in product(*temp_dict.values())],
    columns = temp_dict.keys()
)

extra_tasks = pd.DataFrame.from_records(
    [
        ("50k", "20000", True, "c4.8xlarge", 8, ["r2"]),
        ("50k", "20000", True, "c4.8xlarge", 36, ["r2"]),
        ("50k", "20000", False, "c4.8xlarge", 36, ["r2"]),
        ("50k", "20000", True, "c4.8xlarge", 36, ["r2", "dprime"]),
        ("36k", "20000", True, "c4.8xlarge", 36, ["r2"]),
    ],
    columns = ["n_samples", "n_variants", "interruptible", "instance_type", "cpu", "methods"]
)

all_tasks = pd.concat([standard_tasks, extra_tasks], ignore_index=True)

# Add the task name.
all_tasks["task_name"] = "api-benchmark - " + all_tasks["n_samples"] + " - " + all_tasks["n_variants"] + " - " + all_tasks["instance_type"] + " - " + all_tasks["cpu"].astype(str)

print("Setting up tasks...")
all_tasks.reset_index()  # Not sure if this is necessary.
for row in all_tasks.itertuples():
    task = api.tasks.create(
        name=row.task_name,
        project=project,
        app=app,
        inputs={
            "gds_file": gds_files[row.n_samples],
            "variant_include_file": variant_files[row.n_variants],
            "ld_methods": row.methods,
            "output_prefix": "benchmark",
            "cpu": row.cpu
        },
        interruptible=row.interruptible,
        execution_settings = {"instance_type": row.instance_type}
    )
    all_tasks.loc[row.Index, "task_id"] = task.id
    # Run the task.
    task.run()

all_tasks.to_csv("benchmark_tasks.tsv", sep="\t")
