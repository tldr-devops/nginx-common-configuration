## Interactive Nginx Web Server Sandbox

[![#StandWithBelarus](https://img.shields.io/badge/Belarus-red?label=%23%20Stand%20With&labelColor=white&color=red)
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Presidential_Standard_of_Belarus_%28fictional%29.svg/240px-Presidential_Standard_of_Belarus_%28fictional%29.svg.png" width="20" height="20" alt="Voices From Belarus" />](https://bysol.org/en/) [![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://vshymanskyy.github.io/StandWithUkraine)

Welcome to the interactive sandbox featuring the [Nginx Web Server](href="http://nginx.org), where you can test your Nginx configurations.

To begin, clone this repository to your account by clicking "Fork" or "Create Branch" in the top right corner. This is necessary to access the preview window, open the terminal, and make changes to the code.

Note: If you do not clone the repository, you will not be able to perform any of the aforementioned actions.

[Codesandbox](https://codesandbox.io) provides [Cloud Sandboxes](https://codesandbox.io/docs/learn/environment/vm) with the following specifications:
- 2 vCPUs
- 2 GB of RAM
- 6 GB of storage

Your project will start inside the rootless [docker container](./Dockerfile), where you can modify any configuration and execute shell scripts. For your convenience, I have prepared some [scripts](./tasks.json) for you:

- **Run nginx server**:  
    This script executes `/docker-entrypoint.sh` and starts Nginx in the foreground. Codesandbox should open the preview frame with the URL using port 3000. Make sure to use the same HTTP port (3000) in your configurations within this sandbox.

- **Tail nginx access log**:  
    Execute this command to view the contents of `/var/log/nginx/access.log`. By default, all access logs are stored here unless you override the default configuration.

- **Tail nginx error log**:  
    Execute this command to view the contents of `/var/log/nginx/error.log`. By default, all error logs are stored here unless you override the default configuration.

- **Reload nginx on config changes**:  
    This command validates and reloads the Nginx configurations automatically whenever changes are made.

- **Clean nginx access and error logs**:  
    Execute this command to clean all log files located within the `/var/log/nginx` directory.

Feel free to explore and experiment with your Nginx configurations in this interactive sandbox. Happy testing!

### About the Author

Hello, everyone! My name is Filipp, and I have been working with high load distribution systems and services, security, monitoring, continuous deployment and release management (DevOps domain) since 2012.

One of my passions is developing DevOps solutions and contributing to the open-source community. By sharing my knowledge and experiences, I strive to save time for both myself and others while fostering a culture of collaboration and learning.

I had to leave my home country, Belarus, due to my participation in [protests against the oppressive regime of dictator Lukashenko](https://en.wikipedia.org/wiki/2020%E2%80%932021_Belarusian_protests), who maintains a close affiliation with Putin. Since then, I'm trying to build my life from zero in other countries.

If you are seeking a skilled DevOps lead or architect to enhance your project, I invite you to connect with me on [LinkedIn](https://www.linkedin.com/in/filipp-frizzy-289a0360/) or explore my valuable contributions on [GitHub](https://github.com/Friz-zy/). Let's collaborate and create some cool solutions together :)

### How You Can Support My Projects

There are a couple of ways you can support my projects:

* **Sending Pull Requests (PRs)**:  
    If you come across any improvements or suggestions for my configurations or texts, feel free to send me Pull Requests (PRs) with your proposed changes. I appreciate your contributions <3

* **Making Donations**:  
    If you find my projects valuable and would like to support them financially, you can make a donation. Your contributions will go towards further development, maintenance, and improvement of the projects. Your support is greatly appreciated and helps to ensure the continued success of the projects.

  - [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/filipp_frizzy)
  - [donationalerts.com/r/filipp_frizzy](https://www.donationalerts.com/r/filipp_frizzy)
  - ETH 0xCD9fC1719b9E174E911f343CA2B391060F931ff7
  - BTC bc1q8fhsj24f5ncv3995zk9v3jhwwmscecc6w0tdw3

Thank you for considering supporting my work. Your involvement and contributions make a significant difference in the growth and success of my projects.
