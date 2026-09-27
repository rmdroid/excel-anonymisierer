# Bestandteile Dritter

Der KI-Anonymisierer Excel enthält Software und ein Sprachmodell Dritter.
Für diese Bestandteile gelten deren Lizenzbedingungen vorrangig.

## Sprachmodell

| Bestandteil | Lizenz | Quelle |
|---|---|---|
| `urchade/gliner_multi_pii-v1` | Apache 2.0 | https://huggingface.co/urchade/gliner_multi_pii-v1 |
| Basismodell `microsoft/mdeberta-v3-base` | MIT | https://huggingface.co/microsoft/mdeberta-v3-base |

Das Modell ist unverändert im Container-Abbild enthalten.

## Programmbibliotheken

| Bestandteil | Lizenz |
|---|---|
| GLiNER | Apache 2.0 |
| PyTorch | BSD-3-Clause |
| Transformers | Apache 2.0 |
| ONNX Runtime | MIT |
| sentencepiece | Apache 2.0 |
| FastAPI | MIT |
| Starlette | BSD-3-Clause |
| Uvicorn | BSD-3-Clause |
| Pydantic | MIT |
| openpyxl | MIT |
| Faker | MIT |
| ReportLab | BSD |
| cryptography | Apache 2.0 oder BSD-3-Clause |
| regex | Apache 2.0 |
| python-multipart | Apache 2.0 |
| Python | PSF License |

Die vollständigen Lizenztexte liegen den jeweiligen Paketen im Abbild bei
(`/usr/local/lib/python3.12/site-packages/*/LICENSE*`).
