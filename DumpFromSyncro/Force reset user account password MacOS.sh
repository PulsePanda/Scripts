USERNAME="$username"
NEW_PASSWORD="$password"

# Check if the user exists
if ! id "$USERNAME" &>/dev/null; then
  echo "User '$USERNAME' does not exist."
  exit 1
fi

# Reset the user's password
dscl . -passwd /Users/"$USERNAME" "$NEW_PASSWORD"