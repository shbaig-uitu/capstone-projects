# Stage 09: Floorplanning (OpenROAD)

**Stage Duration:** ~2 seconds  
**Tool:** OpenROAD Floorplan  
**Status:** ✅ SUCCESS

---

## Stage Overview

Floorplanning defines the core area, die boundaries, and initial placement of major macros and I/O pads.

---

## Floorplanning Parameters

| Parameter | Value | Unit |
|-----------|-------|------|
| **Die Area** | 3600 × 3600 | µm |
| **Core Area** | 3500 × 3500 | µm |
| **Core Margin** | 50 | µm |
| **Total Area** | 12.96 | mm² |
| **Core Utilization Target** | 75 | % |

---

## Floorplan Configuration

```
Die:   (0,0) to (3600, 3600)
Core:  (50, 50) to (3550, 3550)

Power Ring: Enabled
VDD Track Spacing: 2.720 µm
VSS Track Spacing: 2.720 µm
```

---

## I/O Placement

**Total Pads:** 150+
**Distribution:**
- Clock/Reset: 2 pads
- UART Interface: 2 pads
- GPIO: 8 pads
- AXI Debug: 16 pads
- Power/Ground: 126 pads

---

## Floorplan Output

### Core Definition
- ✅ Core boundaries set
- ✅ Aspect ratio verified
- ✅ Area sufficient for 75% utilization

### Power Delivery Planning
- ✅ VDD/VSS tracks planned
- ✅ Power ring placement verified
- ✅ Initial PDN structure defined

---

## Status: ✅ FLOORPLANNING SUCCESSFUL

Floorplan metrics all within specification. Die and core area properly defined for optimal placement.

**Next Stage:** Placement & Optimization

---

*Floorplanning completed: 2026-09-10 08:55:28*
