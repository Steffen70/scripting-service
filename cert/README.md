## Development Certificates

#### Adjust IP in `localhost.conf`

Open `localhost.conf` and update the `IP.1` entry under `[alt_names]` to match your computer's LAN IP:

```ini
[alt_names]
DNS.1 = localhost
IP.1  = 192.168.1.100 ; Replace with your actual LAN IP
```

### Installation

**Note:** Many browsers manage their own certificate stores, so you may need to install the Root CA certificate in your browser to trust the development certificates.

#### Install the Root CA Certificate (Ubuntu)

**1. Copy Certificate to Trusted Store Location**

```sh
sudo cp root_ca.crt /usr/local/share/ca-certificates/root_ca.crt
```

**2. Update Trusted Certificates**

```sh
sudo update-ca-certificates
```

#### Install Root CA on iPhone via Apple Configurator

1. Open **Apple Configurator** and click **File → New Profile**.
2. In the **Certificates** section, click **Configure** and select `root_ca.crt`.
3. Fill in the **General** section (e.g. name it `Dev Root CA`) and save the profile.
4. With your iPhone connected via USB:
    - Either click **Add → Profiles...** and select your `.mobileconfig`,
    - Or transfer the `.mobileconfig` to the device and open it directly.
5. Open the **Settings app** on your iPhone. A new section labeled **Profile Downloaded** will appear at the top.
6. Tap it and follow the steps to install the profile (you’ll be prompted to enter your device PIN).
7. After installation, go to **Settings → General → About → Certificate Trust Settings**.
8. Enable trust for **Dev Root CA** using the toggle.

Once done, Safari and other apps will trust your dev server at e.g. `https://192.168.1.100:8443`.

> TODO: Provide instructions for installation on Android

#### Install the Root CA Certificate (Windows)

1. **Press `Win + R`**, type `mmc`, and press **Enter**.
2. In MMC, go to **File → Add/Remove Snap-in...**
3. Select **Certificates** and click **Add**.
4. Choose **Computer account**, then **Next → Finish → OK**.
5. In the left pane, expand **Certificates (Local Computer)** → **Trusted Root Certification Authorities** → **Certificates**.
6. **Right-click** on **Certificates**, then choose **All Tasks → Import...**
7. Click **Next**, **Browse** to your `root_ca.crt` file (select "All Files _._" if needed).
8. Make sure the certificate store is set to **Trusted Root Certification Authorities**.
9. Click **Next → Finish**.
10. You should see a success message. Close MMC and choose **No** when asked to save the console settings.

#### Brave (or Chrome):

1.  Open Brave and go to chrome://settings/security.
2.  Scroll down and click Manage certificates.
3.  Go to the Authorities tab.
4.  Click Import and select your `root_ca.crt` file.
5.  Ensure that the options to Trust this certificate for identifying websites are checked.

#### LibreWolf (or Firefox):

1.  Open LibreWolf and go to about:preferences#privacy.
2.  Scroll down to the Certificates section and click View Certificates.
3.  Go to the Authorities tab and click Import.
4.  Select your `root_ca.crt` and choose to Trust this CA to identify websites.
