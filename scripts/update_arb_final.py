import json
import os

def update_arb(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Missing keys for Reports
    data["reportsAnonymizeTitle"] = "ANONYMIZE BSSID"
    data["@reportsAnonymizeTitle"] = {"description": "Title for anonymizing BSSID in reports"}
    
    data["reportsAnonymizeDesc"] = "Masks last 3 octets (XX:XX:XX) before export"
    data["@reportsAnonymizeDesc"] = {"description": "Description for anonymizing BSSID in reports"}
    
    data["exportCsv"] = "Export CSV"
    data["@exportCsv"] = {"description": "Label for exporting report as CSV"}
    
    data["pdfReportFilename"] = "Torcav Scan Report"
    data["@pdfReportFilename"] = {"description": "Filename for the PDF report"}

    # Missing keys for Security Severities
    data["severityCritical"] = "CRITICAL"
    data["@severityCritical"] = {"description": "Critical severity label"}
    
    data["severityHigh"] = "HIGH"
    data["@severityHigh"] = {"description": "High severity label"}
    
    data["severityMedium"] = "MEDIUM"
    data["@severityMedium"] = {"description": "Medium severity label"}
    
    data["severityLow"] = "LOW"
    data["@severityLow"] = {"description": "Low severity label"}
    
    data["severityInfo"] = "INFO"
    data["@severityInfo"] = {"description": "Info severity label"}

    # Missing keys for Profile Hub
    data["profileNoSnapshot"] = "No scan snapshot is available yet. Run a Wi-Fi scan first."
    data["@profileNoSnapshot"] = {"description": "Message shown when no snapshot is available in profile"}

    # Missing keys for Terms of Service
    data["termsTitle"] = "TERMS OF SERVICE"
    data["@termsTitle"] = {"description": "Title for Terms of Service page"}
    
    data["termsAcceptanceTitle"] = "1. ACCEPTANCE"
    data["@termsAcceptanceTitle"] = {"description": "Acceptance section title"}
    
    data["termsAcceptanceDesc"] = "By accessing or using Torcav, you agree to be bound by these Terms. If you do not agree, you must immediately cease use of the App."
    data["@termsAcceptanceDesc"] = {"description": "Acceptance section description"}
    
    data["termsAuthorizedTestingTitle"] = "2. AUTHORIZED TESTING ONLY"
    data["@termsAuthorizedTestingTitle"] = {"description": "Authorized testing section title"}
    
    data["termsAuthorizedTestingDesc"] = "You represent and warrant that you will only use the App to analyze networks and devices that you own or for which you have received explicit, written authorization to test. Unauthorized access to networks is strictly prohibited and may be illegal in your jurisdiction."
    data["@termsAuthorizedTestingDesc"] = {"description": "Authorized testing section description"}
    
    data["termsDisclaimerTitle"] = "3. DISCLAIMER OF WARRANTIES"
    data["@termsDisclaimerTitle"] = {"description": "Disclaimer section title"}
    
    data["termsDisclaimerDesc"] = "The App is provided \"as is\" and \"as available\". We do not guarantee that the App will identify all security vulnerabilities or that its results are 100% accurate. Use at your own risk."
    data["@termsDisclaimerDesc"] = {"description": "Disclaimer section description"}
    
    data["termsLiabilityTitle"] = "4. LIMITATION OF LIABILITY"
    data["@termsLiabilityTitle"] = {"description": "Liability section title"}
    
    data["termsLiabilityDesc"] = "In no event shall the developers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the App."
    data["@termsLiabilityDesc"] = {"description": "Liability section description"}
    
    data["termsModificationsTitle"] = "5. MODIFICATIONS"
    data["@termsModificationsTitle"] = {"description": "Modifications section title"}
    
    data["termsModificationsDesc"] = "We reserve the right to modify these terms at any time. Continued use of the App following any changes constitutes acceptance of the new terms."
    data["@termsModificationsDesc"] = {"description": "Modifications section description"}
    
    data["termsLegalNotice"] = "LEGAL NOTICE"
    data["@termsLegalNotice"] = {"description": "Legal notice header"}
    
    data["termsLegalNoticeDesc"] = "This application is a security auditing tool. Misuse of this software to access or monitor networks without permission is strictly prohibited."
    data["@termsLegalNoticeDesc"] = {"description": "Legal notice description"}
    
    data["termsLastUpdated"] = "Last Updated: {date}"
    data["@termsLastUpdated"] = {
        "description": "Last updated text for terms",
        "placeholders": {
            "date": {
                "type": "String"
            }
        }
    }

    # Sort keys alphabetically (optional but good for consistency)
    sorted_data = dict(sorted(data.items()))

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(sorted_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    arb_path = "/home/garuda/Masaüstü/torcav/lib/core/l10n/app_en.arb"
    update_arb(arb_path)
    print(f"Updated {arb_path}")
