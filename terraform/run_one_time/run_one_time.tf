
resource "null_resource" "PowerShellScriptRunFirstTimeOnly" {
    provisioner "local-exec" {
        command = "C:\\Users\\yec\\OneDrive\\dev_cloud\\vs_code\\_common_iot\\15-stack_hci\\stackhciauto\\terraform\\run_one_time\\helpers\\get_processes.ps1 -First 10"
        
        interpreter = ["PowerShell", "-Command"]
    }
}