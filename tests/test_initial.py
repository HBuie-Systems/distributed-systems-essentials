def test_pipeline_sanity():
    """A simple test to ensure pytest is running correctly in CI."""
    assert True


def test_python_version():
    """Ensure we are running on Python 3.10 as expected."""
    import sys

    assert sys.version_info.major == 3
    assert sys.version_info.minor == 10
