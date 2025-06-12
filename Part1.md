# Course Project Part 1

> CS 312 System Administration  
> Kimberly Yeo (934-320-897)  
> [yeoki@oregonstate.edu](mailto:yeoki@oregonstate.edu)

## Minecraft Server Deployment Tutorial for AWS EC2

> **Note:** If an option field is not explicitly mentioned during the tutorial, leave it as the default value.  
> **Note:** Replace anything written within `< >` with your own instance's version.

## 1. Launch EC2 instance

1. Navigate to your **AWS Dashboard**
2. Navigate to **EC2** (under Services) > **Instances** (under Instances)
3. Click the **[Launch instances]** button
4. Configure the instance:

    ---
    - **Name:** `Minecraft-Server`
    ---
    - **AMI:** `Amazon Linux 2023 AMI`
    - **Architecture:** `64-bit (x86)`
    ---
    - **Instance type:** `t3.medium`
    ---
    - **Key pair (login):**  

        1. Click the **[Create new key pair]** blue text  
            
            - **Key pair name:** `minecraft-key`  
            - **Key pair type:** `RSA`  
            - **Private key file format:** `.pem`  

        2. Click the **[Create key pair]** button

    > **Note:** The `.pem` file should be automatically downloaded to your device once you click the button. Move the `.pem` file to the desired directory for the SSH connection step later in the tutorial.  
    ---
    - **Network settings:**

        1. Click the **[Edit]** button
        2. Make sure **Auto-assign public IP** is set to `Enable`
        3. Configure the **Firewall (security groups)**, make sure `Create security group` is selected
            
            - **Security group name:** `minecraft`
            - **Description:** `security group for minecraft server`

            1. Edit the default **Security group rule 1**
                
                - **Type:** `SSH`
                - **Protocol:** `TCP`
                - **Port range:** `22`
                - **Source type:** `My IP`
            
            2. Click the **[Add security group rule]** button

                - **Type:** `Custom TCP`
                - **Protocol:** `TCP`
                - **Port range:** `25565`
                - **Source type:** `Custom`
                - **Source:** `0.0.0.0/0`
    --- 
    - **Configure storage:** Update the `8` GiB to `10` GiB
    ---
5. Click the **[Launch instance]** button at the very bottom
6. Navigate back to the **Instances** dashboard
7. Click on the **Minecraft-Server**'s Instance ID variable (displayed in blue text)

## 2. Connect to EC2 instance via SSH

1. Open a terminal capable of establishing a SSH connection 
2. Copy **Minecraft-Server**'s **Public IPv4 DNS** (click on the blue box icon next to the value)
3. Navigate to the directory containing the `.pem` file from **Part 1** (example shown below)
4. Run the following commands in your terminal

   ```bash
   cd <directory-containing-pem-file>
   ```

   ```bash
   ssh -i minecraft-key.pem ec2-user@<Minecraft-Server Public IPv4 DNS>
   ```

    > **Note:** Enter `yes` into the terminal if a fingerprint prompt shows up after establishing the SSH connection.  
    > **Note:** If you see ASCII art of a bird in your terminal, then you're connected.

## 3. Install Java dependency  

1. Run the following commands in your terminal

   ```bash
   sudo dnf update -y
   ```

   ```bash
   sudo rpm --import https://yum.corretto.aws/corretto.key
   ```

   ```bash
   sudo curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
   ```

   ```bash
   sudo dnf install java-21-amazon-corretto -y
   ```
2. Run the following command in your terminal to check if the correct version of Java has been installed
   
   ```bash
   java -version
   ```

   > **Note:** You should see something similar to `openjdk version "21.0.7" 2025-04-15 LTS`

## 4. Download `server.jar` and configure EULA

1. Run the following commands in your terminal to download the `server.jar` for **Minecraft Java Edition 1.21.5**

   ```bash
   mkdir ~/minecraft && cd ~/minecraft
   ```

   ```bash
   wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar -O server.jar
   ```

2. Run the following command in your terminal to configure the EULA

   ```bash
   echo "eula=true" > eula.txt
   ```

## 5. Set up auto-start for Minecraft service

1. Run the following commands in your terminal

   ```bash
   sudo vim /etc/systemd/system/minecraft.service
   ```

   - Paste in the following after going into **Insert** mode (enter by pressing `I`)

      ```bash
      [Unit]
      Description=Minecraft Server
      After=network.target
      
      [Service]
      WorkingDirectory=/home/ec2-user/minecraft
      ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
      User=ec2-user
      Restart=on-failure
      
      [Install]
      WantedBy=multi-user.target
      ```
    
   - Save and quit out of the file (exit **Insert** mode by pressing `Esc`, then enter `:wq`) and return to your terminal's command-line

   ```bash
   sudo systemctl daemon-reexec
   ```

   ```bash
   sudo systemctl daemon-reload
   ```

   ```bash
   sudo systemctl enable minecraft
   ```

   ```bash
   sudo systemctl start minecraft
   ```

2. Check that the Minecraft service is running by entering the following line into the terminal (the **Active** field should say `active (running)` in green text)

   ```bash
   sudo systemctl status minecraft
   ```

## 6. Connect to Minecraft server

1. Launch the **Minecraft Launcher**  
2. Make sure it's on version **1.21.5** (latest release as of 5/20/2025)  
3. Click on the **[PLAY]** button  
4. Once the game has loaded to the main menu, click on the **[Multiplayer]** button  

    > **Note:** Click on the **[Allow access]** button if a Windows Security Alert pop-up appears

5. Click on the **[Direct Connect]** button
6. Copy **Minecraft-Server**'s **Public IPv4 address** from its instance summary (click on the blue box icon next to the value)
7. Paste the copied **Public IPv4 address** into the game's **Server Address** prompt
8. Click on the **[Join Server]** button

## Extra: Test auto-restart for Minecraft service

1. Run the following command in your terminal after establishing a SSH connection to the EC2 instance

   ```bash
   sudo reboot
   ```

2. Wait until the EC2 instance has started back up, then re-establish the SSH connection (example shown below)

   ```bash
   ssh -i minecraft-key.pem ec2-user@<Minecraft-Server Public IPv4 DNS>
   ```

3. Run the following command in your terminal (it should say that the service is active)

   ```bash
   sudo systemctl status minecraft
   ```
