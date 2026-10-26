"""
Make a password hash for seed.sql.

Usage:
    python make_hash.py password123

Paste the printed hash into the password_hash column of a Staff INSERT.
The app checks logins against these hashes, so plain passwords are never
stored in the database.
"""

import getpass
import sys

from werkzeug.security import generate_password_hash

password = sys.argv[1] if len(sys.argv) > 1 else getpass.getpass("Password: ")
print(generate_password_hash(password))
