require 'nori'
require_relative "../lib/rally_qc_utils"

module RallyQCUtilsHelper

  def self.get_config
    RallyQCUtils.load_config("./spec/test_config.xml")
  end


end

#Example test_config.xml
#<?xml version="1.0"?>
#<Config>
#<RallyConnection>
#<Url>trial.rallydev.com</Url>
#    <WorkspaceName>Yeti Manual Test Workspace</WorkspaceName>
#<Projects>
#<Project>QC Hack Testing</Project>
#    </Projects>
#<User></User>
#<Password></Password>
#<ArtifactType>Story</ArtifactType>
#<ExternalIDField>QCID</ExternalIDField>
#
#<!-- <CopySelectors>
#<CopySelector>Iteration.Name = "Iteration1"</CopySelector>
#    </CopySelectors> -->
#
#<!-- <UpdateSelectors>
#<UpdateSelector>State = Open</UpdateSelector>
#             <UpdateSelector>Priority = High</UpdateSelector>
#</UpdateSelectors>
#         <FieldDefaults>
#             <Field><Name>RootCause</Name><Default>Undefined</Default></Field>
#</FieldDefaults>
#    -->
#  </RallyConnection>
#
#<QCConnection>
#<Url>localhost:8080</Url>
#    <Domain>DEFAULT</Domain>
#<Project>Project1</Project>
#<User></User>
#<Password></Password>
#    <ArtifactType>REQ</ArtifactType>
#<!-- <CopySelectors>
#<CopySelector>State = Open</CopySelector>
#             <CopySelector>Priority = High</CopySelector>
#</CopySelectors>
#    -->
#    <RequirementFolderID>25</RequirementFolderID>
#<IDField>RQ_REQ_ID</IDField>
#    <ExternalIDField>RQ_USER_01</ExternalIDField>
#<ExternalEndUserIDField>RQ_USER_02</ExternalEndUserIDField>
#  </QCConnection>
#
#<Connector>
#<FieldMapping>
#<Field>
#<Rally>Name</Rally>
#        <Other>RQ_REQ_NAME</Other>
#</Field>
#      <Field>
#        <Rally>Description</Rally>
#<Other>RQ_REQ_COMMENT</Other>
#      </Field>
#</FieldMapping>
#  </Connector>
#
#<ConnectorRunner>
#<Preview>False</Preview>
#    <LogLevel>Debug</LogLevel>
#<Services>COPY_RALLY_TO_QC, UPDATE_QC_TO_RALLY</Services>
#  </ConnectorRunner>
#</Config>


