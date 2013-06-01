# RallyQCUtils

RallyQCUtils is a utility meant to help you setup the RallyQC Connector when you have many QC Domains and Projects

It can create a template spreadsheet for you to generate configuration files from.
The generated spreadsheet will contain 3 tabs:

1.  A Rally Tab with a list of Rally Workspaces, Workspace IDs, Projects, and Project IDs.
2.  A QC Tab with a list of QC Domains and their corresponding Projects
3.  A Data tab where you can paste in your QC Domain Project List and map the corresponding Rally Workspace / Project
    Columns further to the right can map the Rally Field to the intended QC Field listed in the header.

The generate command will read the template spreadsheet and create configuration files in a specified location.
The generated configs will be named QCDomain_QCProject_Type.xml.  Ex.  DEFAULT_Project1_REQ.xml

An example spreadsheet would look roughly like:

    QC Domain, Project, Rally Workspace, Rally Workspace ID, Rally Project,Rally Project ID,RQ_REQ_COMMENT,RQ_REQ_STATUS,RQ_REQ_NAME,RQ_USER_01,RQ_USER_02
    AUTOMATED_TESTS, DynamicTests, Quality Center Workspace, Project 1, Description, ScheduleState, Name, ObjectID, FormattedID
    AUTOMATED_TESTS, LoadTests, Quality Center Workspace, Project 2, Description, ScheduleState, Name, ObjectID, FormattedID


System Requirements:
Currently uses Python 2.6 to generate an xlsx file with xlrd and xlwt which can be downloaded from pypi
Limitation that this supports 1:1 mapping of QC Domain / Project to 1 Rally Workspace/Project

## Installation

Add this line to your application's Gemfile:

    gem 'RallyQCUtils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install RallyQCUtils


## Usage

config.xml should be a base config for the connector with a RallyConnection and QCConnection section
The Url, User and Passwords will be copied from that base config to the generated configs.

To create a template spreadsheet:

    rallyqc --create spreadsheetname config.xml

To generate config files from a spreadsheet and writing to a "location" directory:

    rallyqc --generate spreadsheet config.xml location

A temporary csv file is generated.

The results are in the form <HPQC_Domain>_<HPQC_Project>_<ArtifactType>.xml

## Sample config.xml for creating the template

    <?xml version="1.0"?>
    <Config>
      <RallyConnection>
        <Url>rally1.rallydev.com</Url>
        <User>rallyuser@company.com</User>
        <Password>rallypass</Password>
        <ArtifactType>Story</ArtifactType>
        <ExternalIDField>QCID</ExternalIDField>
      </RallyConnection>

      <QCConnection>
        <Url>qcserver:8080</Url>
        <User>qcuser</User>
        <Password>qc-password</Password>
        <ArtifactType>REQ</ArtifactType>
        <IDField>RQ_REQ_ID</IDField>
        <ExternalIDField>RQ_USER_01</ExternalIDField>
        <ExternalEndUserIDField>RQ_USER_02</ExternalEndUserIDField>
      </QCConnection>
    </Config>


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
