module main

import os

fn is_windows() bool {
    return os.user_os() == 'windows'
}
