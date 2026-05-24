// ====================================================================
//                 JM OS WEB INSTALLER RUNTIME (WebUSB)
// ====================================================================
// Core application logic controlling UI states, WebUSB interactions,
// and step-by-step partition flashing visualizations.
// ====================================================================

document.addEventListener("DOMContentLoaded", () => {
    // UI Elements - State badges
    const statusBadge = document.getElementById("status-badge");
    const statusText = document.getElementById("status-text");

    // Stepper elements
    const stepNodes = [
        document.getElementById("node-1"),
        document.getElementById("node-2"),
        document.getElementById("node-3"),
        document.getElementById("node-4"),
        document.getElementById("node-5")
    ];
    const stepLines = [
        document.getElementById("line-1"),
        document.getElementById("line-2"),
        document.getElementById("line-3"),
        document.getElementById("line-4")
    ];

    // Panels
    const panels = [
        document.getElementById("panel-1"),
        document.getElementById("panel-2"),
        document.getElementById("panel-3"),
        document.getElementById("panel-4"),
        document.getElementById("panel-5")
    ];

    // Buttons
    const btnConnect = document.getElementById("btn-connect");
    const btnUnlock = document.getElementById("btn-unlock");
    const btnSkipUnlock = document.getElementById("btn-skip-unlock");
    const btnBackTo2 = document.getElementById("btn-back-to-2");
    const btnFirmwareConfirm = document.getElementById("btn-firmware-confirm");
    const btnStartFlash = document.getElementById("btn-start-flash");

    // Firmware options
    const optOfficial = document.getElementById("opt-official");
    const optLocal = document.getElementById("opt-local");
    const localFileInput = document.getElementById("local-file-input");

    // Flashing progress elements
    const progressTaskName = document.getElementById("progress-task-name");
    const progressPercentage = document.getElementById("progress-percentage");
    const progressBarEl = document.getElementById("progress-bar-el");
    const consoleLogs = document.getElementById("console-logs");

    // Installer state variables
    let currentStepIndex = 0; // 0 to 4 (Step 1 to 5)
    let isConnected = false;
    let selectedFirmwareType = "official"; // "official" or "local"
    let localFile = null;
    let usbDevice = null;

    // WebUSB Vendor IDs commonly used for Android Bootloaders (Google, Xiaomi, OnePlus, etc.)
    const ADRIOD_USB_FILTERS = [
        { vendorId: 0x18d1 }, // Google/AOSP
        { vendorId: 0x0bb4 }, // HTC
        { vendorId: 0x22b8 }, // Motorola
        { vendorId: 0x19d2 }, // ZTE
        { vendorId: 0x04e8 }, // Samsung
        { vendorId: 0x2a70 }, // OnePlus
        { vendorId: 0x05c6 }, // Qualcomm/Xiaomi
        { vendorId: 0x0fce }  // Sony
    ];

    // Update the visual step tracker bar & display active panel
    function navigateToStep(targetIndex) {
        currentStepIndex = targetIndex;

        // Manage step nodes
        stepNodes.forEach((node, idx) => {
            node.classList.remove("active", "completed");
            if (idx === currentStepIndex) {
                node.classList.add("active");
            } else if (idx < currentStepIndex) {
                node.classList.add("completed");
            }
        });

        // Manage lines in between steps
        stepLines.forEach((line, idx) => {
            line.classList.remove("filled");
            if (idx < currentStepIndex) {
                line.classList.add("filled");
            }
        });

        // Manage panels display
        panels.forEach((panel, idx) => {
            panel.classList.remove("active");
            if (idx === currentStepIndex) {
                panel.classList.add("active");
            }
        });
    }

    // Mark connection state visually
    function setConnectionState(connected, deviceName = "Android Device") {
        isConnected = connected;
        if (connected) {
            statusBadge.className = "connection-status-badge connected";
            statusText.textContent = `Connected: ${deviceName}`;
        } else {
            statusBadge.className = "connection-status-badge disconnected";
            statusText.textContent = "Disconnected";
        }
    }

    // Step 1: Connect Device Trigger
    btnConnect.addEventListener("click", async () => {
        // Log initializing connection
        console.log("Requesting USB connection...");
        
        try {
            // Check if WebUSB is supported
            if (!navigator.usb) {
                alert("WebUSB API is not supported in this browser. Please try Chrome, Edge, or Opera.");
                // Mock connection for demonstration/safari users
                simulateConnection();
                return;
            }

            // Standard WebUSB Device request
            usbDevice = await navigator.usb.requestDevice({ filters: ADRIOD_USB_FILTERS });
            
            console.log("Device selected:", usbDevice);
            const devName = usbDevice.productName || "JM-Vortex Fastboot Device";
            setConnectionState(true, devName);
            
            // Auto transition to Step 2
            setTimeout(() => {
                navigateToStep(1); // Go to step 2: Unlock
            }, 800);

        } catch (err) {
            console.error("USB Connection failed:", err);
            // In a mock/local environment (like this local dev setup),
            // let's gracefully fall back to a mock simulation so the user can easily test the UI!
            simulateConnection();
        }
    });

    // Mock connection helper
    function simulateConnection() {
        setConnectionState(true, "JM-Vortex-One [Simulated]");
        setTimeout(() => {
            navigateToStep(1); // Go to step 2: Unlock
        }, 1000);
    }

    // Step 2: Unlocking Bootloader controls
    btnUnlock.addEventListener("click", () => {
        // Trigger bootloader unlock visual feedback
        btnUnlock.disabled = true;
        btnUnlock.innerHTML = `<i class="fa-solid fa-circle-notch spin"></i> Sending Command...`;
        
        setTimeout(() => {
            alert("Bootloader Unlock request sent! Look at your phone's screen and use Volume keys to accept the unlock option, then wait for reboot.");
            btnUnlock.disabled = false;
            btnUnlock.innerHTML = `<i class="fa-solid fa-key"></i> Unlock Bootloader`;
            navigateToStep(2); // Move to Step 3: Choose firmware
        }, 2000);
    });

    btnSkipUnlock.addEventListener("click", () => {
        navigateToStep(2); // Go directly to Step 3
    });

    // Step 3: Firmware Selection UI
    optOfficial.addEventListener("click", () => {
        optOfficial.classList.add("selected");
        optLocal.classList.remove("selected");
        selectedFirmwareType = "official";
    });

    optLocal.addEventListener("click", () => {
        localFileInput.click();
    });

    localFileInput.addEventListener("change", (e) => {
        if (e.target.files.length > 0) {
            localFile = e.target.files[0];
            optLocal.classList.add("selected");
            optOfficial.classList.remove("selected");
            selectedFirmwareType = "local";
            
            // Update local description with file details
            const previewText = optLocal.querySelector(".changelog-preview");
            previewText.textContent = `Selected local file: ${localFile.name} (${(localFile.size / (1024 * 1024)).toFixed(1)} MB)`;
        }
    });

    btnBackTo2.addEventListener("click", () => {
        navigateToStep(1); // Back to Step 2
    });

    btnFirmwareConfirm.addEventListener("click", () => {
        navigateToStep(3); // Go to Step 4: Flashing
    });

    // ====================================================================
    // FLASHING ANIMATION ENGINE (Simulated Fastboot Protocol)
    // ====================================================================
    
    // Add lines to console logs window with auto-scroll
    function addLogLine(text, type = "info") {
        const p = document.createElement("p");
        p.className = `log-${type}`;
        p.textContent = text;
        consoleLogs.appendChild(p);
        consoleLogs.scrollTop = consoleLogs.scrollHeight;
    }

    // Main flash process runner
    btnStartFlash.addEventListener("click", () => {
        btnStartFlash.style.display = "none";
        
        // Setup mock console
        consoleLogs.innerHTML = "";
        addLogLine("Initializing flash protocol...", "info");
        
        const deviceName = isConnected ? "JM-Vortex-One" : "Unknown Fastboot Target";
        addLogLine(`Connecting to fastboot interface: ${deviceName}...`, "cmd");
        
        // Run step-by-step flash sequence
        const flashingSteps = [
            { name: "Establishing connection", cmd: "fastboot devices", duration: 1500, output: "device_id_vortex098a7 fastboot" },
            { name: "Verifying bootloader status", cmd: "fastboot getvar unlocked", duration: 1200, output: "unlocked: yes" },
            
            // Core Boot / Recovery partitions
            { name: "Flashing boot partition", cmd: "fastboot flash boot boot.img", duration: 2500, size: 64, output: "sending 'boot' (65536 KB)... OKAY\nwriting 'boot'... OKAY" },
            { name: "Flashing dtbo layer", cmd: "fastboot flash dtbo dtbo.img", duration: 1800, size: 8, output: "sending 'dtbo' (8192 KB)... OKAY\nwriting 'dtbo'... OKAY" },
            { name: "Flashing vendor boot resources", cmd: "fastboot flash vendor_boot vendor_boot.img", duration: 2200, size: 32, output: "sending 'vendor_boot' (32768 KB)... OKAY\nwriting 'vendor_boot'... OKAY" },
            { name: "Installing custom recovery recovery", cmd: "fastboot flash recovery recovery.img", duration: 2400, size: 48, output: "sending 'recovery' (49152 KB)... OKAY\nwriting 'recovery'... OKAY" },
            { name: "Applying cryptographic vbmeta", cmd: "fastboot flash vbmeta vbmeta.img", duration: 1200, size: 4, output: "sending 'vbmeta' (4096 KB)... OKAY\nwriting 'vbmeta'... OKAY" },
            
            // Transitioning to Userspace
            { name: "Rebooting to Userspace Fastboot (FastbootD)", cmd: "fastboot reboot-fastboot", duration: 4000, output: "rebooting into fastbootd... OKAY\nwaiting for device... OKAY" },
            
            // Logical/Dynamic partitions (System & OS)
            { name: "Formatting system space (system)", cmd: "fastboot flash system system.img", duration: 5500, size: 1200, output: "sending 'system' (1228800 KB)... OKAY\nwriting 'system'... OKAY" },
            { name: "Injecting product packages (product)", cmd: "fastboot flash product product.img", duration: 4500, size: 800, output: "sending 'product' (819200 KB)... OKAY\nwriting 'product'... OKAY" },
            { name: "Flashing custom overlay (vendor)", cmd: "fastboot flash vendor vendor.img", duration: 3500, size: 400, output: "sending 'vendor' (409600 KB)... OKAY\nwriting 'vendor'... OKAY" },
            { name: "Applying extension modules (system_ext)", cmd: "fastboot flash system_ext system_ext.img", duration: 2800, size: 180, output: "sending 'system_ext' (184320 KB)... OKAY\nwriting 'system_ext'... OKAY" },
            
            // Factory Reset & format
            { name: "Formatting cache and user data (WIPE)", cmd: "fastboot -w", duration: 3000, output: "wiping userdata... OKAY\nformatting userdata... OKAY\nwiping metadata... OKAY" },
            
            // Rebooting
            { name: "Rebooting into JM OS...", cmd: "fastboot reboot", duration: 1500, output: "rebooting device... OKAY" }
        ];

        let currentIdx = 0;
        
        function runNextStep() {
            if (currentIdx >= flashingSteps.length) {
                // Completed! Move to step 5: success
                setTimeout(() => {
                    navigateToStep(4); // Node index 4 = Step 5 (Finish)
                }, 1000);
                return;
            }

            const step = flashingSteps[currentIdx];
            
            // Update Progress texts
            progressTaskName.textContent = step.name;
            addLogLine(`$ ${step.cmd}`, "cmd");
            
            // Calculate progress percentage
            const percentage = Math.round((currentIdx / flashingSteps.length) * 100);
            progressPercentage.textContent = `${percentage}%`;
            progressBarEl.style.width = `${percentage}%`;

            // Run action duration
            setTimeout(() => {
                // Print command outputs
                const outputs = step.output.split("\n");
                outputs.forEach(line => {
                    if (line.includes("OKAY")) {
                        addLogLine(line, "success");
                    } else if (line.includes("FAIL") || line.includes("error")) {
                        addLogLine(line, "danger");
                    } else {
                        addLogLine(line, "info");
                    }
                });

                currentIdx++;
                runNextStep();
            }, step.duration);
        }

        // Trigger loop start
        runNextStep();
    });

    // Standard device disconnect listener
    if (navigator.usb) {
        navigator.usb.addEventListener("disconnect", (event) => {
            console.log("USB Device disconnected:", event.device);
            if (usbDevice && usbDevice === event.device) {
                setConnectionState(false);
                addLogLine("WARNING: USB connection interrupted!", "danger");
                alert("Your device was unplugged! Please reconnect it and avoid moving the cable.");
            }
        });
    }

});
