$fp = 'd:\NEW\CMM\chaoperty\lib\AdminScaffold\AdminScaffold.dart'
$content = [System.IO.File]::ReadAllText($fp, [System.Text.Encoding]::UTF8)

$old = "                              : (Value_Route == 'AdminSupport')`n                                  ?  AdminSupport()"
$new = "                              : (Value_Route == 'AdminSupport')`n                                  ? const AdminSupport()"

$old2 = "                              : (Value_Route == 'AdminSupport')`n                                  ? AdminSupport()"
$new2 = "                              : (Value_Route == 'AdminSupport')`n                                  ? const AdminSupport()"

$n1 = ([regex]::Matches($content, [regex]::Escape($old))).Count
$n2 = ([regex]::Matches($content, [regex]::Escape($old2))).Count
Write-Host "Before: double-space occurrences=$n1, single-space occurrences=$n2"

$content = $content.Replace($old, $new)
$content = $content.Replace($old2, $new2)

[System.IO.File]::WriteAllText($fp, $content, [System.Text.UTF8Encoding]::new($false))

$verify = [System.IO.File]::ReadAllText($fp, [System.Text.Encoding]::UTF8)
$constCount = ([regex]::Matches($verify, 'const AdminSupport\(\)')).Count
$plainCount = ([regex]::Matches($verify, ' AdminSupport\(\)')).Count
Write-Host "After: const=$constCount, plain=$plainCount"