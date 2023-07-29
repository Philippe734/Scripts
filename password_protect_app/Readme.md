#### Script to protect your application with a password

##### Easy to crack, but usefull to prevent kids or family usage on same computer.

Prompt for password then run app. Require yad: `sudo apt install yad`

Before use it, hide the application's file in your system, then use these commands to get the full path of your application, encrypted and coded in base64, with your password:
```
password=$(yad --text-align=center --text="Password" --entry --entry-text="" --hide-text --fixed --title="" --button=OK)
data="/Path/To/Your/Application"
echo "$data" | openssl enc -aes256 -a -pbkdf2 -pass pass:"$password"
```

Then, in the script replace xxx of `data="xxx"` with the full path of your application encrypted and coded in base64


![2023-07-28_18-23](https://github.com/floating/frame/assets/24923693/14cd01d9-efa8-4483-b346-05afbd1c904b)
