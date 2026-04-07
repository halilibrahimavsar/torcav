#!/usr/bin/env python3
"""
Device Type Classifier — Training Pipeline

Trains a small MLP that classifies LAN hosts into device categories
based on open ports, vendor OUI prefix, hostname patterns, and service names.

Output: device_classifier.tflite (~500 KB)

Usage:
    python train.py                    # Train with synthetic data
    python train.py --data scan.json   # Train with exported torcav scan data
"""

import argparse
import json
import hashlib
import random
import struct
from pathlib import Path

import numpy as np

try:
    import torch
    import torch.nn as nn
    import torch.optim as optim
except ImportError:
    raise SystemExit(
        "PyTorch is required. Install with: pip install torch numpy"
    )

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEVICE_CATEGORIES = [
    "Router/Gateway",
    "Access Point",
    "Desktop",
    "Laptop",
    "Mobile Device",
    "Tablet",
    "Smart TV",
    "IoT Sensor",
    "Printer",
    "NAS/Storage",
    "Game Console",
    "IP Camera",
    "Smart Speaker",
    "Server",
    "Unknown",
]
NUM_CLASSES = len(DEVICE_CATEGORIES)

# Top 64 ports we encode as a binary bitmap
TRACKED_PORTS = [
    20, 21, 22, 23, 25, 53, 67, 68, 69, 80, 110, 119, 123, 135, 137, 139,
    143, 161, 162, 179, 389, 443, 445, 465, 500, 515, 548, 554, 587, 631,
    636, 873, 990, 993, 995, 1080, 1194, 1433, 1723, 1883, 2049, 3000,
    3306, 3389, 4443, 5000, 5060, 5222, 5353, 5432, 5900, 6379, 7547,
    8000, 8008, 8080, 8443, 8883, 8888, 9000, 9090, 9100, 9200, 27017,
]
NUM_PORTS = len(TRACKED_PORTS)
_PORT_INDEX = {p: i for i, p in enumerate(TRACKED_PORTS)}

# Vendor OUI hash dimension
VENDOR_HASH_DIM = 32

# Hostname trigram hash dimension
HOSTNAME_HASH_DIM = 32

# Service name bag-of-words dimension
SERVICE_BOW_DIM = 32

# Total feature vector size
FEATURE_DIM = NUM_PORTS + VENDOR_HASH_DIM + HOSTNAME_HASH_DIM + SERVICE_BOW_DIM
# = 64 + 32 + 32 + 32 = 160

# ---------------------------------------------------------------------------
# Feature extraction (must match the Dart-side implementation exactly)
# ---------------------------------------------------------------------------

def _hash_to_bucket(value: str, dim: int) -> int:
    """Deterministic hash of a string into [0, dim)."""
    h = hashlib.md5(value.lower().encode("utf-8")).digest()
    return struct.unpack("<I", h[:4])[0] % dim


def _trigrams(text: str) -> list[str]:
    """Extract character trigrams from text."""
    t = text.lower().strip()
    if len(t) < 3:
        return [t] if t else []
    return [t[i : i + 3] for i in range(len(t) - 2)]


def extract_features(
    ports: list[int],
    vendor: str,
    hostname: str,
    service_names: list[str],
) -> np.ndarray:
    """Build the fixed-size feature vector for one host."""
    feat = np.zeros(FEATURE_DIM, dtype=np.float32)

    # 1. Port bitmap (64 dims)
    for p in ports:
        idx = _PORT_INDEX.get(p)
        if idx is not None:
            feat[idx] = 1.0

    # 2. Vendor hash (32 dims) — multi-hot from vendor words
    offset = NUM_PORTS
    for word in vendor.lower().split():
        bucket = _hash_to_bucket(word, VENDOR_HASH_DIM)
        feat[offset + bucket] = 1.0

    # 3. Hostname trigram hash (32 dims)
    offset += VENDOR_HASH_DIM
    for tri in _trigrams(hostname):
        bucket = _hash_to_bucket(tri, HOSTNAME_HASH_DIM)
        feat[offset + bucket] = 1.0

    # 4. Service name bag-of-words hash (32 dims)
    offset += HOSTNAME_HASH_DIM
    for svc in service_names:
        for word in svc.lower().split("-"):
            bucket = _hash_to_bucket(word, SERVICE_BOW_DIM)
            feat[offset + bucket] = 1.0

    return feat


# ---------------------------------------------------------------------------
# Synthetic training data generation
# ---------------------------------------------------------------------------

# Profiles: (device_type, port_pool, vendor_pool, hostname_pool, service_pool)
DEVICE_PROFILES: list[tuple[str, list[int], list[str], list[str], list[str]]] = [
    (
        "Router/Gateway",
        [22, 23, 53, 80, 443, 161, 8080],
        ["TP-Link", "Netgear", "Asus", "Cisco", "Huawei", "MikroTik", "D-Link", "Linksys", "Ubiquiti", "ZTE"],
        ["router", "gateway", "modem", "RT-AX86U", "Archer-C7", "R7000", "EdgeRouter"],
        ["ssh", "dns", "http", "https", "snmp", "http-proxy", "telnet"],
    ),
    (
        "Access Point",
        [22, 80, 443, 161, 5353],
        ["Ubiquiti", "Ruckus", "Aruba", "Cisco", "TP-Link", "UniFi", "Meraki"],
        ["ap", "unifi", "access-point", "UAP-AC-PRO", "RAP", "MR33"],
        ["ssh", "http", "https", "snmp", "mdns"],
    ),
    (
        "Desktop",
        [22, 80, 135, 139, 445, 3389, 5900],
        ["Dell", "HP", "Lenovo", "Intel", "ASRock", "Gigabyte", "MSI", "ASUS"],
        ["desktop", "pc", "workstation", "DESKTOP-ABC123", "WIN-SERVER"],
        ["ssh", "http", "microsoft-ds", "ms-wbt-server", "vnc", "netbios"],
    ),
    (
        "Laptop",
        [22, 80, 443, 445, 5353],
        ["Apple", "Dell", "Lenovo", "HP", "ASUS", "Acer", "Microsoft", "Samsung"],
        ["laptop", "macbook", "thinkpad", "LAPTOP-XYZ", "Surface"],
        ["ssh", "http", "https", "microsoft-ds", "mdns"],
    ),
    (
        "Mobile Device",
        [5353, 8008, 62078],
        ["Apple", "Samsung", "Xiaomi", "Huawei", "OnePlus", "Google", "Oppo", "Vivo"],
        ["iphone", "android", "galaxy", "pixel", "oneplus", "redmi"],
        ["mdns", "airdrop"],
    ),
    (
        "Tablet",
        [5353, 8008],
        ["Apple", "Samsung", "Lenovo", "Huawei", "Amazon"],
        ["ipad", "tablet", "galaxy-tab", "fire-hd", "Tab-S7"],
        ["mdns", "airdrop"],
    ),
    (
        "Smart TV",
        [80, 443, 8008, 8443, 9080],
        ["Samsung", "LG", "Sony", "TCL", "Hisense", "Vizio", "Philips"],
        ["smarttv", "tizen", "webos", "android-tv", "roku", "fire-tv", "bravia"],
        ["http", "https", "dlna", "upnp"],
    ),
    (
        "IoT Sensor",
        [80, 443, 1883, 8883, 5683],
        ["Espressif", "Tuya", "Shelly", "Sonoff", "Zigbee", "Tasmota", "ESP32"],
        ["sensor", "esp32", "shelly", "tasmota", "zigbee-bridge", "smart-plug"],
        ["http", "https", "mqtt", "coap"],
    ),
    (
        "Printer",
        [80, 443, 515, 631, 9100],
        ["HP", "Canon", "Epson", "Brother", "Xerox", "Lexmark", "Ricoh", "Kyocera"],
        ["printer", "laserjet", "officejet", "pixma", "ecotank", "MFC-L2710DW"],
        ["http", "https", "lpd", "ipp", "jetdirect"],
    ),
    (
        "NAS/Storage",
        [22, 80, 443, 445, 548, 873, 2049, 5000, 8080],
        ["Synology", "QNAP", "Western Digital", "Netgear", "Buffalo", "Asustor", "TerraMaster"],
        ["nas", "diskstation", "ds920", "ts-453d", "mycloud", "readynas"],
        ["ssh", "http", "https", "microsoft-ds", "afp", "rsync", "nfs", "upnp"],
    ),
    (
        "Game Console",
        [80, 443, 3478, 3479, 3480],
        ["Sony", "Microsoft", "Nintendo", "Valve"],
        ["playstation", "xbox", "switch", "steamdeck", "PS5", "XboxSeriesX"],
        ["http", "https"],
    ),
    (
        "IP Camera",
        [80, 443, 554, 8000, 8080],
        ["Hikvision", "Dahua", "Reolink", "Wyze", "Eufy", "Ring", "Amcrest", "TP-Link"],
        ["camera", "ipcam", "cam", "dvr", "nvr", "doorbell"],
        ["http", "https", "rtsp", "onvif"],
    ),
    (
        "Smart Speaker",
        [80, 443, 8008, 8443, 5353],
        ["Amazon", "Google", "Apple", "Sonos", "Bose", "Harman"],
        ["echo", "alexa", "google-home", "homepod", "sonos", "nest-mini"],
        ["http", "https", "mdns", "cast"],
    ),
    (
        "Server",
        [22, 25, 80, 110, 143, 443, 993, 995, 3306, 5432, 6379, 8080, 8443, 9200, 27017],
        ["Dell", "HP", "Supermicro", "Lenovo", "Intel", "IBM"],
        ["server", "srv", "mail", "web", "db", "docker-host", "k8s-node", "proxmox"],
        ["ssh", "smtp", "http", "pop3", "imap", "https", "mysql", "postgresql", "redis", "http-proxy", "elasticsearch", "mongodb"],
    ),
    (
        "Unknown",
        [],
        ["Unknown"],
        ["", "device", "host"],
        [],
    ),
]


def _generate_sample(profile_idx: int, rng: random.Random) -> tuple[np.ndarray, int]:
    """Generate one synthetic training sample from a device profile."""
    label_name, port_pool, vendor_pool, hostname_pool, service_pool = DEVICE_PROFILES[profile_idx]
    label = DEVICE_CATEGORIES.index(label_name)

    # Select a random subset of ports (with some noise)
    if port_pool:
        n_ports = rng.randint(1, min(len(port_pool), 5))
        ports = rng.sample(port_pool, n_ports)
        # 10% chance of adding a random extra port (noise)
        if rng.random() < 0.1:
            ports.append(rng.choice(TRACKED_PORTS))
    else:
        ports = []

    vendor = rng.choice(vendor_pool)
    hostname = rng.choice(hostname_pool)

    # Add some hostname variation
    if rng.random() < 0.3 and hostname:
        hostname += f"-{rng.randint(1, 99)}"

    if service_pool:
        n_svc = rng.randint(1, min(len(service_pool), 4))
        services = rng.sample(service_pool, n_svc)
    else:
        services = []

    feat = extract_features(ports, vendor, hostname, services)
    return feat, label


def generate_synthetic_dataset(
    n_samples: int = 50000, seed: int = 42
) -> tuple[np.ndarray, np.ndarray]:
    """Generate a balanced synthetic training dataset."""
    rng = random.Random(seed)
    features = []
    labels = []

    samples_per_class = n_samples // NUM_CLASSES
    for class_idx in range(NUM_CLASSES):
        for _ in range(samples_per_class):
            feat, label = _generate_sample(class_idx, rng)
            features.append(feat)
            labels.append(label)

    # Shuffle
    combined = list(zip(features, labels))
    rng.shuffle(combined)
    features, labels = zip(*combined)

    return np.array(features, dtype=np.float32), np.array(labels, dtype=np.int64)


def load_torcav_export(path: Path) -> tuple[np.ndarray, np.ndarray]:
    """Load training data from torcav JSON export (optional enrichment)."""
    with open(path) as f:
        data = json.load(f)

    features = []
    labels = []
    for entry in data:
        ports = [s["port"] for s in entry.get("services", [])]
        service_names = [s["serviceName"] for s in entry.get("services", []) if s.get("serviceName")]
        feat = extract_features(
            ports=ports,
            vendor=entry.get("vendor", "Unknown"),
            hostname=entry.get("hostName", ""),
            service_names=service_names,
        )
        label_name = entry.get("deviceType", "Unknown")
        if label_name in DEVICE_CATEGORIES:
            label = DEVICE_CATEGORIES.index(label_name)
        else:
            label = DEVICE_CATEGORIES.index("Unknown")
        features.append(feat)
        labels.append(label)

    return np.array(features, dtype=np.float32), np.array(labels, dtype=np.int64)


# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------

class DeviceClassifierMLP(nn.Module):
    """Small 3-layer MLP for device classification. ~80K parameters."""

    def __init__(self, input_dim: int = FEATURE_DIM, num_classes: int = NUM_CLASSES):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(input_dim, 128),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(64, num_classes),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.net(x)


# ---------------------------------------------------------------------------
# Training
# ---------------------------------------------------------------------------

def train_model(
    X_train: np.ndarray,
    y_train: np.ndarray,
    X_val: np.ndarray,
    y_val: np.ndarray,
    epochs: int = 60,
    batch_size: int = 256,
    lr: float = 1e-3,
) -> DeviceClassifierMLP:
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = DeviceClassifierMLP().to(device)

    param_count = sum(p.numel() for p in model.parameters())
    print(f"Model parameters: {param_count:,}")
    print(f"Training on: {device}")
    print(f"Train samples: {len(X_train):,}, Val samples: {len(X_val):,}")

    optimizer = optim.Adam(model.parameters(), lr=lr)
    criterion = nn.CrossEntropyLoss()
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=epochs)

    X_t = torch.from_numpy(X_train).to(device)
    y_t = torch.from_numpy(y_train).to(device)
    X_v = torch.from_numpy(X_val).to(device)
    y_v = torch.from_numpy(y_val).to(device)

    best_val_acc = 0.0
    best_state = None

    for epoch in range(1, epochs + 1):
        model.train()
        indices = torch.randperm(len(X_t), device=device)
        total_loss = 0.0
        n_batches = 0

        for start in range(0, len(X_t), batch_size):
            batch_idx = indices[start : start + batch_size]
            xb, yb = X_t[batch_idx], y_t[batch_idx]

            optimizer.zero_grad()
            logits = model(xb)
            loss = criterion(logits, yb)
            loss.backward()
            optimizer.step()

            total_loss += loss.item()
            n_batches += 1

        scheduler.step()

        # Validation
        model.eval()
        with torch.no_grad():
            val_logits = model(X_v)
            val_preds = val_logits.argmax(dim=1)
            val_acc = (val_preds == y_v).float().mean().item()

        if epoch % 10 == 0 or epoch == 1:
            print(
                f"Epoch {epoch:3d}/{epochs} | "
                f"Loss: {total_loss / n_batches:.4f} | "
                f"Val Acc: {val_acc:.4f}"
            )

        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_state = {k: v.clone() for k, v in model.state_dict().items()}

    if best_state:
        model.load_state_dict(best_state)
    print(f"\nBest validation accuracy: {best_val_acc:.4f}")

    return model


# ---------------------------------------------------------------------------
# Export to TFLite
# ---------------------------------------------------------------------------

def export_tflite(model: DeviceClassifierMLP, output_path: Path):
    """Export trained model to TFLite via ONNX intermediate."""
    model.eval()
    model.cpu()

    # Step 1: Export to ONNX
    onnx_path = output_path.with_suffix(".onnx")
    dummy = torch.randn(1, FEATURE_DIM)
    torch.onnx.export(
        model,
        dummy,
        str(onnx_path),
        input_names=["features"],
        output_names=["logits"],
        dynamic_axes={"features": {0: "batch"}, "logits": {0: "batch"}},
        opset_version=13,
    )
    print(f"ONNX exported to {onnx_path}")

    # Step 2: Convert ONNX -> TFLite
    try:
        import onnx
        from onnx_tf.backend import prepare
        import tensorflow as tf

        onnx_model = onnx.load(str(onnx_path))
        tf_rep = prepare(onnx_model)

        # Save as SavedModel
        saved_model_dir = output_path.parent / "saved_model"
        tf_rep.export_graph(str(saved_model_dir))

        # Convert to TFLite with INT8 quantization
        converter = tf.lite.TFLiteConverter.from_saved_model(str(saved_model_dir))
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        tflite_model = converter.convert()

        with open(output_path, "wb") as f:
            f.write(tflite_model)
        print(f"TFLite exported to {output_path} ({len(tflite_model) / 1024:.1f} KB)")

        # Cleanup
        import shutil
        shutil.rmtree(saved_model_dir, ignore_errors=True)

    except ImportError:
        print(
            "\nONNX->TFLite conversion requires: pip install onnx onnx-tf tensorflow\n"
            f"ONNX file saved at {onnx_path} — convert manually if needed.\n"
            "You can also use the ONNX model directly with onnxruntime_flutter."
        )


def export_labels(output_path: Path):
    """Export the label list for Dart-side decoding."""
    with open(output_path, "w") as f:
        json.dump(DEVICE_CATEGORIES, f, indent=2)
    print(f"Labels exported to {output_path}")


def export_dart_constants(output_path: Path):
    """Export feature extraction constants for the Dart implementation."""
    constants = {
        "tracked_ports": TRACKED_PORTS,
        "port_index": _PORT_INDEX,
        "vendor_hash_dim": VENDOR_HASH_DIM,
        "hostname_hash_dim": HOSTNAME_HASH_DIM,
        "service_bow_dim": SERVICE_BOW_DIM,
        "feature_dim": FEATURE_DIM,
        "num_ports": NUM_PORTS,
        "device_categories": DEVICE_CATEGORIES,
    }
    with open(output_path, "w") as f:
        json.dump(constants, f, indent=2)
    print(f"Dart constants exported to {output_path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Train device type classifier")
    parser.add_argument("--data", type=Path, help="Torcav scan export JSON (optional)")
    parser.add_argument("--samples", type=int, default=50000, help="Synthetic samples")
    parser.add_argument("--epochs", type=int, default=60, help="Training epochs")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).parent / "output" / "device_classifier.tflite",
    )
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)

    # Generate / load data
    print("Generating synthetic training data...")
    X_synth, y_synth = generate_synthetic_dataset(args.samples, args.seed)

    if args.data and args.data.exists():
        print(f"Loading additional data from {args.data}...")
        X_real, y_real = load_torcav_export(args.data)
        X_all = np.concatenate([X_synth, X_real])
        y_all = np.concatenate([y_synth, y_real])
    else:
        X_all, y_all = X_synth, y_synth

    # Split: 90% train, 10% val
    n_val = max(int(len(X_all) * 0.1), 1)
    X_train, y_train = X_all[n_val:], y_all[n_val:]
    X_val, y_val = X_all[:n_val], y_all[:n_val]

    # Train
    print("\nTraining model...")
    model = train_model(X_train, y_train, X_val, y_val, epochs=args.epochs)

    # Export
    print("\nExporting model...")
    export_tflite(model, args.output)
    export_labels(args.output.parent / "device_categories.json")
    export_dart_constants(args.output.parent / "feature_constants.json")

    # Also save the PyTorch model for future fine-tuning
    torch_path = args.output.parent / "device_classifier.pt"
    torch.save(model.state_dict(), torch_path)
    print(f"PyTorch model saved to {torch_path}")

    print("\nDone! Next steps:")
    print("  1. Copy the .tflite (or .onnx) to torcav/assets/models/")
    print("  2. Copy device_categories.json to torcav/assets/models/")
    print("  3. Run `flutter pub get` after adding tflite_flutter to pubspec.yaml")


if __name__ == "__main__":
    main()
