# Introduction
This project is a set of samples intended to demonstrate to developers the various different means of extending Clever MES.

## MESScanProductionOrderOp - Replace the standard list selection for production orders

The Production Order Routing is typically one of the "Device Data Selections" prompted for after selecting a device (Data Type Code
PROD_ORDER). Ordinarily this is presented as a list. This example replaces the list selection with a textbox control.

MESScanProdOrderOp.al/ProdScanOnBeforeBuildPage() is a subscriber to 'OnBeforeBuildPage2' in MES Management. This overrides behaviour
when prompting for the PROD_ORDER device data type, replacing the list with a new page built from a panel, Next and Back buttons,
and a textbox control to hold the scanned/entered production order information.

MESScanProdOrderOp.al/ProdScanOnBeforeHandleActivity() is a subscriber to 'OnBeforeHandleActivity2' in MES Management.
This takes the value recorded against the textbox control and records it against the device data type PROD_ORDER.

## MESRedirect - Add a button the the Output screen to redirect to a specific URL

This adds a button captioned "Clever Dynamics" to the Output screen immediately before "Notes".

When the button is clicked the Azure portal is instructed to redirect to https://www.cleverdynamics.com.

MESRedirect.codeunit.al/RedirectButtonOnAfterBuildPage() is a subscriber to 'OnAfterBuildPage2' in MES Management. This allows us
to add the button to the screen.

MESRedirect.codeunit.al/RedirectOnBeforeGetNextActivity() is a subscriber to 'OnBeforeGetNextActivity' in MES Activity Management.
This code executes when the button is clicked.
