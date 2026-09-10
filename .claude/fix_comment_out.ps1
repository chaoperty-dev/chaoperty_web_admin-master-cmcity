# Fix: properly comment out previously-wrapped files by prepending // to every line
# of the original content. The first wrapper line "// /*" gets replaced too so the
# resulting file is just a sequence of // comments, then closing "// */".
$ErrorActionPreference = 'Stop'

$paths = @(
'lib/Account/Ac_searchBar.dart'
'lib/Account/Pay_check_CM.dart'
'lib/AdminScaffold/AdminScaffold_coppy.dart'
'lib/AdminScaffold/GlassHeade.dart'
'lib/APIS-V2/payment-intents-upslip.dart'
'lib/APIS-V2/payment-qr-session.dart'
'lib/ChaoArea/ChaoArea_ScreenTem.dart'
'lib/ChiangMai_Municipality/Area_menu/models/area_menu_config.dart'
'lib/ChiangMai_Municipality/Area_menu/views/area_menu_detail_page.dart'
'lib/ChiangMai_Municipality/License_menu/license_contract_page/views/widgets/next_step_button.dart'
'lib/ChiangMai_Municipality/List_CMM/Register_CMM/SetupPage_temp.dart'
'lib/ChiangMai_Municipality/main_request_cmm.dart'
'lib/ChiangMai_Municipality/Make_contract_CMM/renew_contract_cmm.dart'
'lib/ChiangMai_Municipality/mobile_upload_grid_cmm.dart'
'lib/ChiangMai_Municipality/Model/ApprovalsLastaction_Mode.dart'
'lib/ChiangMai_Municipality/Model/ApprovalsRoles_Mode.dart'
'lib/ChiangMai_Municipality/PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm_temp.dart'
'lib/ChiangMai_Municipality/Report_menu/areas/views/theme/areas_report_theme.dart'
'lib/ChiangMai_Municipality/Report_menu/views/theme/report_page_theme.dart'
'lib/ChiangMai_Municipality/Report_menu/views/widgets/report_menu_card.dart'
'lib/ChiangMai_Municipality/Report_menu/views/widgets/report_page_header.dart'
'lib/ChiangMai_Municipality/request_examiner2_cmm_tem.dart'
'lib/ChiangMai_Municipality/Setting_menu/setting_page/general_data/widgets/general_data_footer.dart'
'lib/ChiangMai_Municipality/Setting_menu/setting_page/general_data/widgets/image_viewer_dialog.dart'
'lib/ChiangMai_Municipality/Setting_menu/setting_page/general_data/widgets/rental_general_header.dart'
'lib/ChiangMai_Municipality/Setting_menu/setting_page/general_data/widgets/rental_general_stat_chip.dart'
'lib/ChiangMai_Municipality/unity/API-Admin-Request-Snapshots/API-Preview-Snapshot-Attachment.dart'
'lib/ChiangMai_Municipality/unity/API-Admin-Request-Snapshots/API-Show-Snapshot.dart'
'lib/ChiangMai_Municipality/unity/API-Admin-Request-Snapshots/Models/api_request_snapshots_show.dart'
'lib/CRC_16_Prompay/format_amount.dart'
'lib/Man_PDF_copy/Man_Temporary3_Receipt_PDF.dart'
'lib/Man_PDF/Man_Temporary3_Receipt_PDF.dart'
'lib/Model_copy/GC_keyuser.dart'
'lib/Model_copy/GetBill_Model.dart'
'lib/Model_copy/GetBillset_Model.dart'
'lib/Model_copy/GetBillsetDefault_Model.dart'
'lib/Model_copy/GetCal_Model.dart'
'lib/Model_copy/GetCrunbill_Model.dart'
'lib/Model_copy/GetDept_Model.dart'
'lib/Model_copy/GetDoctypeDefault_Model.dart'
'lib/Model_copy/GetExpDefault_Model.dart'
'lib/Model_copy/GetExpTypeDefault_Model.dart'
'lib/Model_copy/GetNkadContract_Model.dart'
'lib/Model_copy/GetObjTest_Model.dart'
'lib/Model_copy/GetQuot_Model.dart'
'lib/Model_copy/GetSubUser_Model.dart'
'lib/Model_copy/GetTeNt_Cont_model.dart'
'lib/Model_copy/GetTestDup_Model.dart'
'lib/Model_copy/GetUserBackUp_Model.dart'
'lib/Model_copy/GetUserT_Model.dart'
'lib/Model/GC_keyuser.dart'
'lib/Model/GetBill_Model.dart'
'lib/Model/GetBillset_Model.dart'
'lib/Model/GetBillsetDefault_Model.dart'
'lib/Model/GetCal_Model.dart'
'lib/Model/GetCrunbill_Model.dart'
'lib/Model/GetDept_Model.dart'
'lib/Model/GetDoctypeDefault_Model.dart'
'lib/Model/GetExpDefault_Model.dart'
'lib/Model/GetExpTypeDefault_Model.dart'
'lib/Model/GetNkadContract_Model.dart'
'lib/Model/GetObjTest_Model.dart'
'lib/Model/GetQuot_Model.dart'
'lib/Model/GetSubUser_Model.dart'
'lib/Model/GetTeNt_Cont_model.dart'
'lib/Model/GetTestDup_Model.dart'
'lib/Model/GetUserBackUp_Model.dart'
'lib/Model/GetUserT_Model.dart'
'lib/PDF_TP10/PDF_Receipt_TP10/pdf_LockReceipt_TP10.dart'
'lib/PDF_TP7_Ama1000/PDF_Receipt_TP7/pdf_LockReceipt_TP7.dart'
'lib/PDF_TP7/PDF_Receipt_TP7/pdf_LockReceipt_TP7.dart'
'lib/PDF_TP8_Choice/PDF_Receipt_TP8_Choice/pdf_LockReceipt_TP8_Choice.dart'
'lib/PDF_TP8_Choice/PDF_Temporary_Receipt_TP8_Choice/pdf_Temporar_TP8_Choice.dart'
'lib/PDF_TP8_Ortorkor/PDF_Receipt_TP8_Ortorkor/pdf_LockReceipt_TP8.dart'
'lib/PDF_TP8/PDF_Receipt_TP8/pdf_LockReceipt_TP8.dart'
'lib/PDF_TP9_Lao/PDF_Receipt_TP9/pdf_LockReceipt_TP9.dart'
'lib/PDF_TP9/PDF_Receipt_TP9/pdf_LockReceipt_TP9.dart'
'lib/PDF/PDF_Agreement/pdf_RentalInformaLao.dart'
'lib/PeopleChao_coppy/discount_bill copy.dart'
'lib/PeopleChao_coppy/History_Bills2.dart'
'lib/PeopleChao/discount_bill copy.dart'
'lib/PeopleChao/History_Bills2.dart'
'lib/PeopleChao/Intents/payment_intents_InvAll.dart'
'lib/Report_2/Report_Ui2_Screen.dart'
'lib/Report_2/Report2_Function.dart'
'lib/Report_2/Report2_Screen1.dart'
'lib/Report_choice/Excel_SumBillPayMonRent_Report_Choice.dart'
'lib/Report_cm/Excel_Mon_income_category_cm.dart'
'lib/Report_cm/Report_cm_Screen2.dart'
'lib/Report_Dashboard/Dashboard_ScreenPDF1.dart'
'lib/Setting/QRCodeGenerationPage.dart'
'lib/Setting/ttt7.dart'
'lib/Style/OCR_Home.dart'
'lib/Style/test_limit.dart'
)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$fixed = 0
$alreadyDone = 0
$missing = 0
$failed = 0

foreach ($rel in $paths) {
    $full = Join-Path (Get-Location) $rel
    if (-not (Test-Path $full -PathType Leaf)) {
        Write-Host "MISSING: $rel"
        $missing++
        continue
    }
    try {
        $content = [System.IO.File]::ReadAllText($full, $utf8NoBom)
        if ($content.StartsWith('// /*' + [Environment]::NewLine + '// ') -and $content.EndsWith('// */')) {
            # Already fully commented line-by-line
            Write-Host "ALREADY FIXED: $rel"
            $alreadyDone++
            continue
        }

        # Detect whether this file has my old broken wrap
        $lines = $content -split "`r?`n"
        $bodyLines = $lines
        $hasOldWrap = $false
        if ($lines.Length -ge 2 -and $lines[0] -eq '// /*') {
            $hasOldWrap = $true
            # Drop first ("// /*") and last ("// */") lines
            $bodyLines = $lines[1..($lines.Length - 2)]
        }

        # Prepend // to every body line. Trim trailing empty body line.
        $commented = $bodyLines | ForEach-Object { '// ' + $_ }
        $wrapped = "// /*`n" + ($commented -join "`n") + "`n// */`n"

        [System.IO.File]::WriteAllText($full, $wrapped, $utf8NoBom)
        Write-Host "FIXED: $rel (hadOldWrap=$hasOldWrap)"
        $fixed++
    } catch {
        Write-Host "FAIL: $rel - $($_.Exception.Message)"
        $failed++
    }
}

Write-Host ""
Write-Host "Total: $($paths.Count)"
Write-Host "Fixed: $fixed"
Write-Host "Already fixed: $alreadyDone"
Write-Host "Failed: $failed"
Write-Host "Missing: $missing"