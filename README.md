# WEBCON BPS Power BI Connectors
This repository contains two connectors for Power BI. The purpose of these connectors is to easily load data from WEBCON BPS in OData format for use in Power BI Desktop and Power BI Online. This gives us the ability to build advanced reports and dashboards.



# Pre-requisite
In WEBCON BPS you can obtain data in one of two contexts:
* *Application context*, which uses client credentials flow to authenticate. This type creates user account in WEBCON BPS system to which you can assign permissions, tasks, etc.
* *User context*, which can be used to act in the context of an existing user and their permissions. This one uses authorization code flow to authenticate.

Each of the available connectors is connected with a context mentioned above:
* ```WEBCON BPS Connector (Application context)``` for *Application context*,
* ```WEBCON BPS Connector (User context)``` for *User context*.



For the connectors to work correctly, it is necessary to create the appropriate type of application associated with it. To achieve this please read [this article](https://developer.webcon.com/docs/registration-and-authentiaction)
# Installation
1. To download the Power BI Connectors, go to  [Releases](https://github.com/WEBCON-BPS/PowerBIConnectors/releases) and download the connector (```.mez``` file) you need.
2. On your computer, go to ```Documents``` folder and create folder called  ```Power BI Desktop```.
3. Inside the folder ```Power BI Desktop``` create another one called ```Custom Connectors```.
4. Copy the ```.mez``` file to ```Custom Connectors``` folder.
5. Open Power BI Desktop and enable loading connectors:
    * Go to ```File``` -> ```Options and settings``` -> ```Options```.
    * Go to the ```Security``` tab.
    * Under ```Data Extensions``` select *Allow any extension to load without warning or validation*.
    * Restart Power BI Desktop.



# Usage
Once you have gone through the all previous steps, you can load your data in Power BI. For more details please refer to [this article](https://community.webcon.com/posts/post/odata-format-in-webcon-bps/346/3). 
1. Open Power BI Desktop and click ```Get data from another source``` or navigate to ```Get Data``` -> ```More...```. It opens a popup window that displays all available connectors in Power BI.
2. In the ```All``` or ```Other``` tab search for **WEBCON** connectors.
3. The list of available **WEBCON** connectors will be shown in current window (it will be a list with all connectors placed in ```Power BI Desktop``` folder created before).
4. Choose the connector corresponding to the context in which you want to obtain data.
5. In the next popup window you will be asked to provide some information like *Portal address*, *Api version*, *Database ID*, as well as the  *Client ID* and *Client secret*.
6. If you choose ```WEBCON BPS Connector (User context)``` in step 4, you will be asked to provide credentials for user in the conext of which you want to use this connector.

Now you can choose processes from which you wish to load data and use it to create advanced reports and dashboards.