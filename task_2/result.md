## Bug: Logout button doesn’t work on Safari

**Description:**  
Clicking the logout button in Safari does not trigger any action. The button appears clickable but does not log the user out or redirect to the login page. This issue occurs consistently on both desktop and mobile versions of Safari.

### Steps to Reproduce:
1. Open the application in Safari.
2. Log in with a valid user account.
3. Click the "Logout" button.
4. Observe that nothing happens.

### Expected Behavior:
Clicking the logout button should log the user out and redirect to the login page.

### Actual Behavior:
The logout button does not respond. No logout occurs and the user remains on the current page.

### Environment:
- Browser: Safari (versions 15 and 16)
- Devices: MacBook Pro, iPhone 13
- Operating Systems: macOS Ventura, iOS 17

### Severity:
Medium

### Priority:
High

### Additional Notes:
- The logout function works correctly in Chrome and Firefox.
- Likely related to a JavaScript event listener not firing in Safari.