import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turnstile"
export default class extends Controller {
  static targets = ["helpText", "widget", "legend", "container", "errorAlert", "errorMessageVisible", "errorMessageInvisible"]
  
  connect() {
    // Hide all captcha UI elements by default
    this.hideCaptchaUI()
    this.hideErrorAlert()
    
    // Set up global callback functions for Turnstile
    this.setupTurnstileCallbacks()
    
    // Watch for Turnstile widget to load and disable submit button
    this.monitorTurnstileWidget()
  }
  
  setupTurnstileCallbacks() {
    // Store reference to controller instance for callbacks
    const controller = this
    
    // Make callbacks globally available for Turnstile to call
    window.turnstileSuccessCallback = function(token) {
      console.log('Turnstile challenge completed successfully')
      controller.hideErrorAlert()
      controller.enableSubmitButton()
    }
    
    window.turnstileErrorCallback = function(errorCode) {
      console.log('Turnstile error occurred:', errorCode)
      controller.showErrorAlert('failed_error')
      controller.disableSubmitButton()
    }
    
    window.turnstileExpiredCallback = function() {
      console.log('Turnstile token expired')
      controller.showErrorAlert('expired_error')
      controller.disableSubmitButton()
    }
    
    window.turnstileTimeoutCallback = function() {
      console.log('Turnstile challenge timed out')
      controller.showErrorAlert('timeout_error')
      controller.disableSubmitButton()
    }
  }
  
  monitorTurnstileWidget() {
    const turnstileContainer = document.querySelector('.cf-turnstile')
    
    if (!turnstileContainer) {
      console.log('No .cf-turnstile container found for monitoring')
      return
    }
    
    console.log('Setting up MutationObserver for Turnstile widget')
    
    // Check immediately for existing content (handles race conditions)
    this.checkForTurnstileInput()
    
    // Create MutationObserver to watch for new div elements being added
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            // Look specifically for DIV elements being added (matches Turnstile structure)
            if (node.nodeType === Node.ELEMENT_NODE && node.tagName === 'DIV') {
              console.log('DIV element added to .cf-turnstile:', {
                tagName: node.tagName,
                className: node.className,
                innerHTML: node.innerHTML.substring(0, 100) + '...'
              })
              
              // Check height after element is added and handle UI accordingly
              const elementHeight = turnstileContainer.offsetHeight
              console.log('Turnstile container height after DIV added:', elementHeight)
              
              if (elementHeight === 0) {
                console.log('Zero height detected - hiding help text (invisible mode)')
                this.hideCaptchaUI()
              } else {
                console.log('Non-zero height detected - showing help text and disabling submit')
                this.showCaptchaUI()
                this.disableSubmitButton()
              }
              
              // Stop observing once we've detected the widget
              observer.disconnect()
              console.log('Stopped observing after detecting Turnstile widget')
            }
          })
        }
      })
    })
    
    // Start observing
    observer.observe(turnstileContainer, {
      childList: true,
      subtree: true
    })
  }
  
  checkForTurnstileInput() {
    // Look for the hidden Turnstile response input field within the .cf-turnstile element
    const turnstileElement = document.querySelector('.cf-turnstile')
    if (!turnstileElement) {
      console.log('No .cf-turnstile element found')
      return
    }
    
    // Check if Turnstile element has zero height (invisible mode)
    const elementHeight = turnstileElement.offsetHeight
    console.log('Turnstile element height:', elementHeight)
    
    if (elementHeight === 0) {
      console.log('Turnstile element has zero height - hiding help text (invisible mode)')
      this.hideCaptchaUI()
      return
    }
    
    const turnstileInput = turnstileElement.querySelector('input[type="hidden"][name="cf-turnstile-response"]')
    
    if (turnstileInput) {
      console.log('Found Turnstile response input:', {
        id: turnstileInput.id,
        value: turnstileInput.value,
        hasValue: !!turnstileInput.value,
        parentDiv: turnstileInput.parentElement.tagName,
        elementHeight: elementHeight
      })
      
      // If the input exists but has no value, show the help text
      if (!turnstileInput.value || turnstileInput.value.trim() === '') {
        console.log('Turnstile input found with no value - showing help text')
        this.showCaptchaUI()
      } else {
        console.log('Turnstile input already has value - challenge completed')
      }
    } else {
      console.log('No Turnstile response input found within .cf-turnstile element')
    }
  }
  
  disableSubmitButton() {
    const submitButton = document.querySelector('#registration-submit-btn')
    if (submitButton) {
      submitButton.disabled = true
      submitButton.setAttribute('aria-disabled', 'true')
      console.log('Submit button disabled')
    }
  }
  
  enableSubmitButton() {
    const submitButton = document.querySelector('#registration-submit-btn')
    if (submitButton) {
      submitButton.disabled = false
      submitButton.setAttribute('aria-disabled', 'false')
      console.log('Submit button enabled')
    }
  }
  
  showCaptchaUI() {
    // Add margin to container when widget becomes visible
    if (this.hasContainerTarget) {
      this.containerTarget.classList.add('mb-4')
      console.log('Added margin to container')
    }
    
    if (this.hasLegendTarget) {
      this.legendTarget.classList.remove('d-none')
      this.legendTarget.setAttribute('aria-hidden', 'false')
      console.log('Showed legend')
    }
    
    if (this.hasHelpTextTarget) {
      this.helpTextTarget.classList.remove('d-none')
      this.helpTextTarget.setAttribute('aria-hidden', 'false')
      console.log('Showed help text')
    }
    
    console.log('Captcha UI now visible')
  }
  
  hideCaptchaUI() {
    // Remove margin from container when widget is hidden
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove('mb-4')
    }
    
    if (this.hasLegendTarget) {
      this.legendTarget.classList.add('d-none')
      this.legendTarget.setAttribute('aria-hidden', 'true')
    }
    
    if (this.hasHelpTextTarget) {
      this.helpTextTarget.classList.add('d-none')
      this.helpTextTarget.setAttribute('aria-hidden', 'true')
    }
    
    console.log('Captcha UI now hidden')
  }
  
  showErrorAlert(errorType = 'default_message') {
    if (this.hasErrorAlertTarget) {
      // Check if Turnstile is in invisible mode (height = 0)
      const isInvisibleMode = this.isInvisibleMode()
      
      // Hide all error messages first
      this.hideAllErrorMessages()
      
      // Show the appropriate error message based on mode and type
      this.showErrorMessage(errorType, isInvisibleMode)
      
      // Show the error alert container
      this.errorAlertTarget.classList.remove('d-none')
      console.log(`Error alert shown for type: ${errorType}, invisible mode: ${isInvisibleMode}`)
    }
  }
  
  hideErrorAlert() {
    if (this.hasErrorAlertTarget) {
      this.errorAlertTarget.classList.add('d-none')
      this.hideAllErrorMessages()
      console.log('Error alert hidden')
    }
  }
  
  isInvisibleMode() {
    const turnstileElement = document.querySelector('.cf-turnstile')
    if (!turnstileElement) return false
    
    return turnstileElement.offsetHeight === 0
  }
  
  hideAllErrorMessages() {
    // Hide all visible mode messages
    if (this.hasErrorMessageVisibleTarget) {
      this.errorMessageVisibleTargets.forEach(element => {
        element.classList.add('d-none')
      })
    }
    
    // Hide all invisible mode messages
    if (this.hasErrorMessageInvisibleTarget) {
      this.errorMessageInvisibleTargets.forEach(element => {
        element.classList.add('d-none')
      })
    }
  }
  
  showErrorMessage(errorType, isInvisibleMode) {
    const targetArray = isInvisibleMode ? this.errorMessageInvisibleTargets : this.errorMessageVisibleTargets
    
    // Find the matching error message element
    const messageElement = targetArray.find(element => 
      element.getAttribute('data-error-type') === errorType
    )
    
    if (messageElement) {
      messageElement.classList.remove('d-none')
      console.log(`Showing ${isInvisibleMode ? 'invisible' : 'visible'} error message for type: ${errorType}`)
    } else {
      // Fallback to default message if specific type not found
      const defaultElement = targetArray.find(element => 
        element.getAttribute('data-error-type') === 'default_message'
      )
      if (defaultElement) {
        defaultElement.classList.remove('d-none')
        console.log(`Showing ${isInvisibleMode ? 'invisible' : 'visible'} default error message as fallback`)
      }
    }
  }
  
  disconnect() {
    // Clean up Turnstile observer if still active
    if (this.turnstileObserver) {
      this.turnstileObserver.disconnect()
      this.turnstileObserver = null
    }
    

    
    // Clean up global callbacks when controller is disconnected
    delete window.turnstileSuccessCallback
    delete window.turnstileErrorCallback
    delete window.turnstileExpiredCallback
    delete window.turnstileTimeoutCallback
  }
}