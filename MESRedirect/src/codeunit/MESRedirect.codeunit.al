codeunit 50101 "MES Redirect"
{
    var
        RedirectBtnTxt: Label 'RedirectBtn', Locked = true;
        CleverDynamicsCaption: Label 'Clever Dynamics';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MES Page Def. Mgt. CMESTMN", 'OnAfterBuildPage2', '', false, false)]
    local procedure RedirectButtonOnAfterBuildPage(ActivityCode: Code[20]; PortalFwkApplicationDevice2: Record "Portal Fwk. App. Device CPFTMN"; DataTypeCode: Code[20]; var PortalFrameworkControl: Record "Portal Fwk. Control CPFTMN" temporary; var PortalFwkControlMetadata: Record "PF Control Metadata CPFTMN" temporary; var PortalFrameworkControlDataValue: Record "Portal Fwk Ctl Data Val CPFTMN" temporary; ActivityLogEntryNo: Integer);
    var
        MESSetup: Record "MES Setup CMESTMN";
        MESActivityMgt: Codeunit "MES - Activity Mgt. CMESTMN";
        MESPageDefinitionMgt: Codeunit "MES Page Def. Mgt. CMESTMN";
    begin
        //ActivityCode = OutputScreenCode. This means we are building the output screen.
        //This al code adds a button to the navigation panel before the "Notes" button that will link to external content.
        case ActivityCode of
            MESActivityMgt.OutputScreenCode():
                begin
                    PortalFrameworkControl.Get(UpperCase(MESPageDefinitionMgt.NotesBtnCode()), false);
                    PortalFrameworkControl.AddNewEntryBefore(RedirectBtnTxt);
                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'Button');
                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'subform', 1, 'false');
                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, CleverDynamicsCaption);
                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'value', 0, CleverDynamicsCaption);
                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'colour', 1, 'bg-red');
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MES - Activity Mgt. CMESTMN", 'OnBeforeGetNextActivity', '', false, false)]
    local procedure RedirectOnBeforeGetNextActivity(PortalFwkApplicationDevice: Record "Portal Fwk. App. Device CPFTMN"; PortalFrameworkActivityLog: Record "Portal Fwk Activity Log CPFTMN"; var NextActivityCode: Code[20]; var DataTypeCode: Code[20]; var RebuildPreviousPage: Boolean; var CloseSubform: Boolean; var RefreshForm: Boolean; var Handled: Boolean)
    var
        MESActivityMgt: Codeunit "MES - Activity Mgt. CMESTMN";
        PortalFwkActivityMgt: Codeunit "Portal Fwk Activity Mgt CPFTMN";
    begin
        //ActivityCode = OutputScreenCode. We are processing an output screen activity.
        //Command = RedirectBtn. The custom button has been clicked.
        //This al code sets a COMMAND of "Redirect" and supplies the appropriate redirect to the Azure portal 
        if PortalFrameworkActivityLog."Activity Code" <> MESActivityMgt.OutputScreenCode() then
            exit;
        if PortalFrameworkActivityLog.Command <> UpperCase(RedirectBtnTxt) then
            exit;
        PortalFwkActivityMgt.SetRedirectURLCommand('https://www.cleverdynamics.com');
        NextActivityCode := MESActivityMgt.OutputScreenCode();
        Handled := true;
    end;
}