codeunit 50100 "MES Scan Prod. Order Op."
{
    var
        ScanBarcodeTxt: Label 'Scan Barcode';
        ProdScanControlIdTxt: Label 'PROD_SCAN', Locked = true;
        NextTxt: Label 'Next';
        BackTxt: Label 'Back';
        SignOutTxt: Label 'Sign out';
        RefreshTxt: Label 'Refresh';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MES Page Def. Mgt. CMESTMN", 'OnBeforeBuildPage2', '', false, false)]
    local procedure ProdScanOnBeforeBuildPage(ActivityCode: Code[20]; PortalFwkApplicationDevice2: Record "Portal Fwk. App. Device CPFTMN"; DataTypeCode: Code[20]; var PortalFrameworkControl: Record "Portal Fwk. Control CPFTMN" temporary; var PortalFrameworkControlDataValue: Record "Portal Fwk Ctl Data Val CPFTMN" temporary; var PortalFwkControlMetadata: Record "PF Control Metadata CPFTMN" temporary; ActivityLogEntryNo: Integer; var Handled: Boolean)
    var
        MESSetup: Record "MES Setup CMESTMN";
        PortalFrameworkDataType: Record "Portal Fwk. Data Type CPFTMN";
        MESActivityMgt: Codeunit "MES - Activity Mgt. CMESTMN";
        MESPageDefMgt: Codeunit "MES Page Def. Mgt. CMESTMN";
        MESManagement: Codeunit "MES Management CMESTMN";
        EnvInfo: Codeunit "Environment Information";
    begin
        //ActivityCode = Data Selection. This means we are gathering device data.
        //DataTypeCode = Production Order. This means we are gathering the production order data.
        //This functionality replaces the standard list selection for production orders.
        //We build a replacement page to prompt for a barcode, and set Handled = true to prevent our page being overridden by standard functionality.
        case ActivityCode of
            MESActivityMgt.DataSelectionCode():
                begin
                    case DataTypeCode of
                        MESManagement.ProdOrderDataTypeCode():
                            begin
                                Handled := true; //Set handled to prevent any further code executing on return
                                MESSetup.Get();
                                PortalFrameworkDataType.Get(DataTypeCode);

                                //Build a page with a textbox
                                //Navigation Panel to contain the button controls
                                PortalFrameworkControl.NewPanel();
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'layout', 1, 'nav');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'expand', 1, 'true');

                                //Back button
                                PortalFrameworkControl.AddNewEntry(MESSetup."Portal Fwk. Application ID", MESPageDefMgt.BackBtnCode());
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'Button');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, BackTxt);
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'value', 0, BackTxt);
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'link', 1, StrSubstNo('resourceurlinline:/device/'));

                                //Next button
                                PortalFrameworkControl.AddNewEntry(MESSetup."Portal Fwk. Application ID", MESPageDefMgt.NextBtnCode());
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'Button');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, NextTxt);
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'value', 0, NextTxt);

                                //Refresh button
                                PortalFrameworkControl.AddNewEntry(MESSetup."Portal Fwk. Application ID", MESPageDefMgt.RefreshBtnCode());
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'Button');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'placement', 1, 'right');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, RefreshTxt);
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'value', 0, 'action:home');

                                //Sign out button
                                if EnvInfo.IsSaaS() then begin
                                    PortalFrameworkControl.AddNewEntry(MESSetup."Portal Fwk. Application ID", MESPageDefMgt.SignOutBtnCode());
                                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'Button');
                                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'colour', 1, 'bg-red');
                                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'placement', 1, 'bottom');
                                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, SignOutTxt);
                                    PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'value', 0, 'action:signout');
                                end;

                                //1 column Panel to contain the PROD_ORDER textbox
                                PortalFrameworkControl.NewPanel();
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'layout', 1, '1-column');

                                //Title
                                PortalFrameworkControl.AddNewEntry(MESSetup."Portal Fwk. Application ID", MESPageDefMgt.DataSelectionTitleCode());
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'Text');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, ScanBarcodeTxt);

                                //textbox control to enter production order/line/operation
                                PortalFrameworkControl.AddNewEntry(MESSetup."Portal Fwk. Application ID", ProdScanControlIdTxt);
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'type', 0, 'textbox');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'caption', 0, ScanBarcodeTxt);
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'value', 0, '');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'colSpan', 1, '6');
                                PortalFrameworkControl.AddMetadata(PortalFwkControlMetadata, 'placement', 1, 'left');

                            end;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MES - Post Mgt. CMESTMN", 'OnBeforeHandleActivity2', '', false, false)]
    local procedure ProdScanOnBeforeHandleActivity(var PortalFrameworkControl: Record "Portal Fwk. Control CPFTMN" temporary; var PortalFrameworkCtlDataVal: Record "Portal Fwk Ctl Data Val CPFTMN" temporary; PortalFwkApplicationDevice: Record "Portal Fwk. App. Device CPFTMN"; ActivityCode: Code[20]; Command: Code[20]; var PortalFrameworkActivityLog: Record "Portal Fwk Activity Log CPFTMN"; var Handled: Boolean)
    var
        PortalFwkPostMgt: Codeunit "Portal Fwk. Post Mgt. CPFTMN";
        MESManagement: Codeunit "MES Management CMESTMN";
        MESActivityMgt: Codeunit "MES - Activity Mgt. CMESTMN";
        MESPageDefMgt: Codeunit "MES Page Def. Mgt. CMESTMN";
        ProdScanValue: Text;
    begin
        if ActivityCode <> MESActivityMgt.DataSelectionCode() then //Device Data Selection activity
            exit;
        if Command <> MESPageDefMgt.NextBtnCode() then //Next has been clicked
            exit;

        //Get the control value from the textbox
        ProdScanValue := PortalFwkPostMgt.GetControlValue(PortalFrameworkCtlDataVal, ProdScanControlIdTxt, false);
        if ProdScanValue = '' then
            exit;

        //Record the control value against the device data type PROD_ORDER
        PortalFwkApplicationDevice.StoreData(MESManagement.ProdOrderDataTypeCode(), '');
        PortalFwkApplicationDevice.AppendData(MESManagement.ProdOrderDataTypeCode(), ProdScanValue);
        Handled := true;
    end;
}