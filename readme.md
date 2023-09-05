# jexactyl Installation Script

This script automates the installation of jexactyl on various Linux distributions. jexactyl is a web application or software (please provide a brief description of what jexactyl is) that runs on a web server and requires specific software packages and configurations to function properly. This script simplifies the installation process by handling the installation of required packages and configurations.

## Technologies Used

The installation script utilizes the following technologies:

- **Bash Scripting:** The script is written in Bash, a widely-used shell scripting language in Linux.

- **Package Managers:** The script uses package managers like `apt-get` (for Debian/Ubuntu), `apk` (for Alpine), and `yum` (for CentOS) to install system packages.

- **PHP:** PHP is installed to support the jexactyl web application.

- **MariaDB:** MariaDB is used as the database system for jexactyl.

- **Nginx:** Nginx is installed as the web server to serve jexactyl.

- **Composer:** Composer is a dependency manager for PHP, and it's installed to manage PHP dependencies.

- **Git:** Git is used for version control and for fetching jexactyl files from a GitHub repository.

- **Redis:** Redis is installed for caching purposes.

## Installation Instructions

Follow these steps to use the installation script and install jexactyl:

1. **Clone this Repository:** Clone this GitHub repository to your server:

    ```bash
    git clone https://github.com/rubencosta13/jexactyl-auto-installer.git
    cd your-repo
    ```

2. **Edit .env Configuration:** Before running the script, make sure to create a `.env` file with the required parameters. You can use the provided `.env.example` as a template.

3. **Run the Installation Script:** Execute the installation script with the following command:

    ```bash
    ./install-jexactyl.sh
    ```

4. **Follow On-Screen Prompts:** The script will guide you through the installation process. Follow any on-screen prompts and provide necessary information when asked.

5. **Access jexactyl:** Once the installation is complete, you should be able to access jexactyl by navigating to your server's IP address or domain in your web browser.

## Optional: Customize the Script

You can customize the script to fit your specific requirements by modifying the `.env` configuration or editing the script itself. Please exercise caution and make sure you understand the changes you are making.

## Contributing

Contributions to this script are welcome. If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute it according to the terms of the license.

---

**Note:** This script is intended for use on Linux servers and may not work on other operating systems. Use it at your own risk and ensure you have backups of your data before running the script on a production server.
