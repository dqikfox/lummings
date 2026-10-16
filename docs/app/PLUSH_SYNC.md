# Plush Heartlight Sync — Technical Design (Phase 1.1)

## Goal
Physical Lummings plush “wakes” when near the phone: LED Heartlight matches app phase/bond.

## Hardware (v1 prototype)
| Part | Spec |
|------|------|
| MCU | nRF52840 or ESP32-C3 (BLE 5) |
| LED | Addressable RGB (WS2812) behind translucent chest vessel |
| NFC | NTAG213/216 passive tag in ear or tag (pair + ID) |
| Battery | LiPo 200–400 mAh + USB-C charge |
| Shell | Soft plush; sealed electronics pouch |

## Pairing flow
1. Parent enables **Sync Plush** in Care (or Parent → Devices).
2. App scans NFC tag → unique `plush_id` bound to family account + active Lumming.
3. BLE connect using advertising name `LUM-<plush_id short>`.
4. Store bond: `plush_id ↔ child_profile ↔ lumming_id`.

## BLE GATT (draft)
| Characteristic | Direction | Payload |
|----------------|-----------|---------|
| `phase` | App → Plush | uint8: dimmed=0, caring=1, glowing=2, radiant=3 |
| `bond_level` | App → Plush | uint8 level |
| `heartlight_hue` | App → Plush | RGB for Questlight/Dreamlight/… |
| `pulse_ms` | App → Plush | pulse period |
| `battery` | Plush → App | percent |
| `tap_event` | Plush → App | soft squeeze → optional Care prompt |

## LED mapping
| App phase | Plush LED |
|-----------|-----------|
| dimmed | slow soft breath, 15% brightness |
| caring | warm swell 2s |
| glowing | steady brand colour 60% |
| radiant | rainbow sparkle 4s then glowing |

## Safety
- No microphone on plush in v1.
- BLE range short; no open pairing after first bind without parent PIN.
- Firmware signed OTA only.
- “Airplane / sleep” parent toggle kills BLE advertise.

## App API (Flutter)
```dart
abstract class PlushSync {
  Future<bool> pairViaNfc();
  Future<void> pushHeartlight(CompanionState s, Lumming l);
  Stream<PlushEvent> events(); // squeeze, low battery
  Future<void> unpair(String plushId);
}
```
v0 stub: SnackBar “Phase 1.1” (already in CareScreen).

## Acceptance (prototype)
- [ ] NFC pair under 5s  
- [ ] Phase change in app → LED update < 1s when connected  
- [ ] Out of range → plush soft-dim after 30s  
- [ ] Parent can unpair  

## Timeline
Week 1 hardware bring-up · Week 2 BLE GATT · Week 3 app stub → real · Week 4 safety + parent controls.
