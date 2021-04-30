#! /usr/bin/env python3

import time
import unittest
import sevenbridges as sbg
import logging
import datetime
from sevenbridges.http.error_handlers import (
    rate_limit_sleeper,
    maintenance_sleeper
)
TASK_TERMINAL_STATES = (
    sbg.TaskStatus.COMPLETED,
    sbg.TaskStatus.ABORTED,
    sbg.TaskStatus.FAILED
)

# Input test data stored on platform.
# Note these are all stored in the 'testdata' subdirectory.
# It's a little more complicated to access files in a directory.
input_gds_file = '1KG_phase3_subset.gds'
input_variant1_file = 'variant_include_pair_1.rds'
input_variant2_file = 'variant_include_pair_2.rds'
input_sample_include_file = 'sample_include.rds'
input_out_prefix = 'unittest'


def reload(*tasks):
    """
    Reload task
    Args:
        *tasks:
    Returns:
    """
    for task in tasks:
        task.reload()
    if len(tasks) == 1:
        return tasks[0]
    return tasks

def wait(*tasks):
    """
    Wait until task is done
    Args:
        *tasks:
    Returns:
    """
    while not all(task.status in TASK_TERMINAL_STATES for task in tasks):
        time.sleep(30)
        reload(*tasks)
    return reload(*tasks)

class Platform(unittest.TestCase):
    """
    Execute platform test
    """
    # enables concurrent execution when run with nosetests
    _multiprocess_shared_ = True
    # for nosetests filtering
    project = None
    execution = "platform"
    profile_name = 'bdc'
    log_filename = 'ld-pair'

    @classmethod
    def setUpClass(cls):
        """
        Get input files from the test project and start test task
        Returns:
        """
        # Note: most of this came from an SBG example.
        # Because this is in the setUpClass method, the task is run when the
        # class is first initialized. Then all tests are run using that task.
        # If we want to test different task inputs, we'll need multiple classes.
        # We can probably do this with inheritance -- define a class that
        # sets up the task and runs it, and then subclass that to set specific
        # inputs. First get it running, and then create that structure.
        # We may also be able to create a broad class for all of the ld apps.

        # Log file prefix formatting
        prefix_date = str(datetime.datetime.now()).replace(
            ' ', '_'
        ).replace(
            '-', '_'
        )
        logging.basicConfig(
            filename=f'{prefix_date}_{cls.log_filename}.log',
            filemode='a',
            format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
            datefmt='%H:%M:%S',
            level=logging.INFO
        )

        cls.APP = 'amstilp/ld-compute-devel/ld-pair'
        cls.inputs = {}
        cls.TASK_NAME = 'unittest_ld-pair'
        cls.metadata_status = 'fail'
        cls.naming_status = 'fail'

        # Set project. Why do we need the if statement?
        if not cls.project:
            c = sbg.Config(profile=cls.profile_name)
            print(c)
            cls.session = sbg.Api(
                config=c,
                error_handlers=[
                    rate_limit_sleeper,
                    maintenance_sleeper
                ]
            )
            cls.project_name = 'amstilp/ld-compute-devel'
        cls.project = cls.session.projects.get(id=cls.project_name)

        # SET INPUTS'
        # Identify testdata directory.
        testdir = cls.session.files.query(project=cls.project, names=['testdata'])[0]

        cls.inputs['gds_file'] = cls.session.files.query(
            names=[input_gds_file],
            parent=testdir
        )[0] # try subsetting so that it's a file instead of an list of files.
        cls.inputs['variant_include_file_1'] = cls.session.files.query(
            names=[input_variant1_file],
            parent=testdir
        )[0]
        cls.inputs['variant_include_file_2'] = cls.session.files.query(
            names=[input_variant2_file],
            parent=testdir
        )[0]
        cls.inputs['sample_include_file'] = cls.session.files.query(
            names=[input_sample_include_file],
            parent=testdir
        )[0]
        cls.inputs['ld_methods'] = ["r2", "dprime", "r"]
        cls.inputs['output_prefix'] = input_out_prefix

        cls.log = logging.getLogger("#unit_test")
        cls.log.info(f" Starting {cls.APP} test")
        cls.log.info(str(cls.inputs))

        # RUN TASKS
        try:
            cls.task = cls.session.tasks.create(
                name=cls.TASK_NAME,
                project=cls.project,
                app=cls.APP,
                inputs=cls.inputs,
                run=True
            )
            cls.log.info(f" Running {cls.APP} task")
            cls.log.info(f"#task_id {cls.task.id}")
        except:
            cls.log.info(f" I was unable to run {cls.APP} task")

    def tearDown(self):
        pass

    def test_run_status(self):
        """
        Test workflow execution on the platform
        Returns:
        """
        print(self.project)
        wait(self.task)
        self.log.info(f" Checking {self.APP} status")
        self.log.info(f" Task status {self.task.status}")
        self.assertEqual(self.task.status, 'COMPLETED')

    def test_outputs(self):
        """
        Test workflow output file naming
        """
        wait(self.task)
        if self.task.status == 'COMPLETED':
            self.log.info(f" Checking {self.APP} output naming")
            out_expected_name = 'unittest_ld.rds'
            out_name = self.task.outputs['ld'].name
            if out_name.startswith('_'):
                self.assertEqual(out_expected_name, '_'.join(out_name.split('_')[2:]))
            else:
                self.assertEqual(out_expected_name, out_name)
            self.output_status = 'passed'
            self.log.info(f"#output_test {self.output_status}")

if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner())
