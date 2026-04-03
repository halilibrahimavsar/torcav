import json

files = {
    'en': 'lib/core/l10n/app_en.arb',
    'tr': 'lib/core/l10n/app_tr.arb',
    'de': 'lib/core/l10n/app_de.arb',
    'ku': 'lib/core/l10n/app_ku.arb'
}

keys = {
    'en': {
        'channelInterferenceDescription': 'Wi-Fi channels are like radio stations. When many networks share the same channel they slow each other down — like everyone talking at the same time. Switching to a less crowded channel can improve your speed and reliability.',
        'threatsDetected': 'THREATS DETECTED',
        'securityEventType': '{type, select, rogueApSuspected{Rogue AP Suspected} deauthBurstDetected{Deauth Burst} handshakeCaptureStarted{Handshake Capture Started} handshakeCaptureCompleted{Handshake Captured} captivePortalDetected{Captive Portal Detected} evilTwinDetected{Evil Twin Detected} deauthAttackSuspected{Deauth Attack Suspected} encryptionDowngraded{Encryption Downgraded} unsupportedOperation{Unsupported Operation} other{{type}}}',
        'securityEventSeverity': '{severity, select, low{Low} medium{Medium} info{Info} warning{Warning} high{High} critical{Critical} other{{severity}}}',
        'evilTwinEvidence': 'BSSID mismatch! Expected: {expected}, Found: {found}. High probability of an Evil Twin Access Point.',
        'rogueApEvidence': 'Randomized/LAA MAC detected on known network! This is highly unusual for legitimate Access Points and may indicate a rogue device.',
        'downgradeEvidence': 'Encryption profile changed from {oldSec} to {newSec}. Possible downgrade attack.'
    },
    'tr': {
        'channelInterferenceDescription': 'Wi-Fi kanalları radyo istasyonları gibidir. Birçok ağ aynı kanalı paylaştığında birbirlerini yavaşlatırlar - herkesin aynı anda konuşması gibi. Daha az kalabalık bir kanala geçmek hızınızı ve güvenilirliğinizi artırabilir.',
        'threatsDetected': 'TEHDİT TESPİT EDİLDİ',
        'securityEventType': '{type, select, rogueApSuspected{Sahte AP Şüphesi} deauthBurstDetected{Ağdan Atma Saldırısı Serisi} handshakeCaptureStarted{El Sıkışma Yakalama Başladı} handshakeCaptureCompleted{El Sıkışma Yakalandı} captivePortalDetected{Tutsak Portalı Algılandı} evilTwinDetected{Kötü İkiz Algılandı} deauthAttackSuspected{Ağdan Atma Saldırısı Şüphesi} encryptionDowngraded{Şifreleme Düşürüldü} unsupportedOperation{Desteklenmeyen İşlem} other{{type}}}',
        'securityEventSeverity': '{severity, select, low{Düşük} medium{Orta} info{Bilgi} warning{Uyarı} high{Yüksek} critical{Kritik} other{{severity}}}',
        'evilTwinEvidence': 'BSSID uyuşmazlığı! Beklenen: {expected}, Bulunan: {found}. Yüksek Evil Twin (Kötü İkiz) Erişim Noktası olasılığı.',
        'rogueApEvidence': 'Bilinen ağda Rastgele/LAA MAC algılandı! Bu meşru Erişim Noktaları için oldukça olağandışıdır ve sahte bir cihaza işaret edebilir.',
        'downgradeEvidence': 'Şifreleme profili {oldSec} değerinden {newSec} değerine değişti. Olası düşürme (downgrade) saldırısı.'
    },
    'de': {
        'channelInterferenceDescription': 'Wi-Fi-Kanäle sind wie Radiosender. Wenn viele Netzwerke denselben Kanal nutzen, verlangsamen sie sich gegenseitig – als würden alle gleichzeitig sprechen. Ein Wechsel zu einem weniger überfüllten Kanal kann Ihre Geschwindigkeit und Zuverlässigkeit verbessern.',
        'threatsDetected': 'BEDROHUNGEN ERKANNT',
        'securityEventType': '{type, select, rogueApSuspected{Rogue AP Verdacht} deauthBurstDetected{Deauth-Serie Erkannt} handshakeCaptureStarted{Handshake-Aufzeichnung Gestartet} handshakeCaptureCompleted{Handshake Aufgezeichnet} captivePortalDetected{Captive Portal Erkannt} evilTwinDetected{Evil Twin Erkannt} deauthAttackSuspected{Deauth-Angriff Verdacht} encryptionDowngraded{Verschlüsselung Herabgestuft} unsupportedOperation{Nicht Unterstützter Vorgang} other{{type}}}',
        'securityEventSeverity': '{severity, select, low{Niedrig} medium{Mittel} info{Info} warning{Warnung} high{Hoch} critical{Kritisch} other{{severity}}}',
        'evilTwinEvidence': 'BSSID-Nichtübereinstimmung! Erwartet: {expected}, Gefunden: {found}. Hohe Wahrscheinlichkeit eines Evil Twin Access Points.',
        'rogueApEvidence': 'Zufällige/LAA-MAC in bekanntem Netzwerk erkannt! Dies ist für legitime Access Points höchst ungewöhnlich und kann auf ein bösartiges Gerät hinweisen.',
        'downgradeEvidence': 'Verschlüsselungsprofil wurde von {oldSec} auf {newSec} geändert. Möglicher Downgrade-Angriff.'
    },
    'ku': {
        'channelInterferenceDescription': 'Kanalên Wi-Fi wekî stasyonên radyoyê ne. Dema ku gelek tor heman kanalê parve dikin ew hev hêdî dikin - mîna ku her kes di heman demê de diaxive. Veguhestina ser kanalekî kêmtir qelebalix dikare lez û rehetiya we baştir bike.',
        'threatsDetected': 'XETER HATIN DÎTIN',
        'securityEventType': '{type, select, rogueApSuspected{Gumana AP ya Sexte} deauthBurstDetected{Êrîşa Qutkirinê Serî Hatiye Dîtin} handshakeCaptureStarted{Girtina Destguhartinê Dest Pê Kir} handshakeCaptureCompleted{Destguhartin Hat Girtin} captivePortalDetected{Portala Girtî Hat Dîtin} evilTwinDetected{Cêwîyê Xirab Hat Dîtin} deauthAttackSuspected{Gumana Êrîşa Qutkirinê} encryptionDowngraded{Şîfrekirin Hat Daxistin} unsupportedOperation{Kareke Nayê Piştgirîkirin} other{{type}}}',
        'securityEventSeverity': '{severity, select, low{Kêm} medium{Navîn} info{Zanyarî} warning{Hişyarî} high{Bilind} critical{Krîtîk} other{{severity}}}',
        'evilTwinEvidence': 'Lihevnehatina BSSID! Ya Tê Çaverêkirin: {expected}, Ya Hatî Dîtin: {found}. Îhtîmaleke mezin a Xala Gihîştina Cêwîyê Xirab.',
        'rogueApEvidence': 'MAC-a Ketober/LAA di tora naskirî de hat dîtin! Ev ji bo Xalên Gihîştina rewa pir neasayî ye û dibe ku nîşan bide ku amûrek sexte heye.',
        'downgradeEvidence': 'Profîla şîfrekirinê ji {oldSec} ber bi {newSec} ve hat guhartin. Gumana êrîşa daxistinê.'
    }
}

metadata = {
    '@channelInterferenceDescription': {
        'description': 'Explanation of channel interference'
    },
    '@threatsDetected': {
        'description': 'Status text when threats are detected'
    },
    '@securityEventType': {
        'description': 'Name of security event type',
        'placeholders': {
            'type': {
                'type': 'String'
            }
        }
    },
    '@securityEventSeverity': {
        'description': 'Name of security severity',
        'placeholders': {
            'severity': {
                'type': 'String'
            }
        }
    },
    '@evilTwinEvidence': {
        'description': 'Evil twin evidence text',
        'placeholders': {
            'expected': {
                'type': 'String'
            },
            'found': {
                'type': 'String'
            }
        }
    },
    '@rogueApEvidence': {
        'description': 'Rogue AP evidence text'
    },
    '@downgradeEvidence': {
        'description': 'Downgrade evidence text',
        'placeholders': {
            'oldSec': {
                'type': 'String'
            },
            'newSec': {
                'type': 'String'
            }
        }
    }
}

for lang, filepath in files.items():
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for k, v in keys[lang].items():
        data[k] = v
        if lang == 'en':
            data['@'+k] = metadata['@'+k]
            
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        
print("Updated ARB files.")
