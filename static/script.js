// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
    // Get the datetime element
    const datetimeElement = document.getElementById("datetime");
    
    // Make sure the element exists before trying to update it
    if (datetimeElement) {
        datetimeElement.textContent = new Date().toLocaleString();
        
        // Update the time every second
        setInterval(function() {
            datetimeElement.textContent = new Date().toLocaleString();
        }, 1000);
    } else {
        console.error("Element with id 'datetime' not found");
    }
});
