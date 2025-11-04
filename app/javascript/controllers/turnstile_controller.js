import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turnstile"
export default class extends Controller {
  static targets = ["helpText", "widget", "legend", "container", "errorAlert", "errorMessageVisible", "errorMessageInvisible"]
  
  connect() {
    // Prevent duplicate initialization on the same element
    if (this.element.dataset.turnstileInitialized === 'true') {
      return
    }
    
    // Mark as initialized
    this.element.dataset.turnstileInitialized = 'true'
    
    // Store widget ID to track if already rendered
    this.widgetId = null
    
    // Hide all captcha UI elements by default
    this.hideCaptchaUI()
    this.hideErrorAlert()
    
    // Set up global callback functions for Turnstile (only if not already set)
    if (!window.turnstileSuccessCallback) {
      this.setupTurnstileCallbacks()
    }
    
    // Wait for Turnstile API to be available, then render explicitly
    this.waitForTurnstileAndRender()
  }
  
  setupTurnstileCallbacks() {
    // Store reference to controller instance for callbacks
    const controller = this
    
    // Make callbacks globally available for Turnstile to call
    window.turnstileSuccessCallback = function(token) {
      controller.hideErrorAlert()
      controller.enableSubmitButton()
    }
    
    window.turnstileErrorCallback = function(errorCode) {
      controller.showErrorAlert('failed_error')
      controller.disableSubmitButton()
    }
    
    window.turnstileExpiredCallback = function() {
      controller.showErrorAlert('expired_error')
      controller.disableSubmitButton()
    }
    
    window.turnstileTimeoutCallback = function() {
      controller.showErrorAlert('timeout_error')
      controller.disableSubmitButton()
    }
  }
  
  waitForTurnstileAndRender() {
    // Check if Turnstile API is already loaded
    if (window.turnstile) {
      this.renderTurnstileWidget()
    } else {
      // Wait for Turnstile API to load (check every 100ms, timeout after 10 seconds)
      let attempts = 0
      const maxAttempts = 100
      const checkInterval = setInterval(() => {
        attempts++
        if (window.turnstile) {
          clearInterval(checkInterval)
          this.renderTurnstileWidget()
        } else if (attempts >= maxAttempts) {
          clearInterval(checkInterval)
          this.showErrorAlert('network_error')
        }
      }, 100)
    }
  }
  
  renderTurnstileWidget() {
    const turnstileContainer = document.querySelector('.cf-turnstile')
    
    if (!turnstileContainer) {
      return
    }
    
    // Check if widget already rendered
    if (this.widgetId !== null) {
      return
    }
    
    // Check if container already has Turnstile content
    if (turnstileContainer.querySelector('iframe')) {
      return
    }
    
    try {
      // Render the widget explicitly
      // this.widgetId = window.turnstile.render(turnstileContainer, {
      //   sitekey: turnstileContainer.dataset.sitekey,
      //   theme: 'light',
      //   language: turnstileContainer.dataset.language || 'en',
      //   size: 'flexible',
      //   callback: 'turnstileSuccessCallback',
      //   'error-callback': 'turnstileErrorCallback',
      //   'expired-callback': 'turnstileExpiredCallback',
      //   'timeout-callback': 'turnstileTimeoutCallback'
      // })
      
      // Monitor the widget after rendering
      this.monitorTurnstileWidget()
    } catch (error) {
      this.showErrorAlert('default_message')
    }
  }
  
  monitorTurnstileWidget() {
    const turnstileContainer = document.querySelector('.cf-turnstile')
    
    if (!turnstileContainer) {
      return
    }
    
    // Check immediately for existing content (handles race conditions)
    this.checkForTurnstileInput()
    
    // Create MutationObserver to watch for new div elements being added
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            // Look specifically for DIV elements being added (matches Turnstile structure)
            if (node.nodeType === Node.ELEMENT_NODE && node.tagName === 'DIV') {
              // Check height after element is added and handle UI accordingly
              const elementHeight = turnstileContainer.offsetHeight
              
              if (elementHeight === 0) {
                this.hideCaptchaUI()
              } else {
                this.showCaptchaUI()
                this.disableSubmitButton()
              }
              
              // Stop observing once we've detected the widget
              observer.disconnect()
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
      return
    }
    
    // Check if Turnstile element has zero height (invisible mode)
    const elementHeight = turnstileElement.offsetHeight
    
    if (elementHeight === 0) {
      this.hideCaptchaUI()
      return
    }
    
    const turnstileInput = turnstileElement.querySelector('input[type="hidden"][name="cf-turnstile-response"]')
    
    if (turnstileInput) {
      // If the input exists but has no value, show the help text
      if (!turnstileInput.value || turnstileInput.value.trim() === '') {
        this.showCaptchaUI()
      }
    }
  }
  
  disableSubmitButton() {
    const submitButton = document.querySelector('#registration-submit-btn')
    if (submitButton) {
      submitButton.disabled = true
      submitButton.setAttribute('aria-disabled', 'true')
    }
  }
  
  enableSubmitButton() {
    const submitButton = document.querySelector('#registration-submit-btn')
    if (submitButton) {
      submitButton.disabled = false
      submitButton.setAttribute('aria-disabled', 'false')
    }
  }
  
  showCaptchaUI() {
    // Add margin to container when widget becomes visible
    if (this.hasContainerTarget) {
      this.containerTarget.classList.add('mb-4')
    }
    
    if (this.hasLegendTarget) {
      this.legendTarget.classList.remove('d-none')
      this.legendTarget.setAttribute('aria-hidden', 'false')
    }
    
    if (this.hasHelpTextTarget) {
      this.helpTextTarget.classList.remove('d-none')
      this.helpTextTarget.setAttribute('aria-hidden', 'false')
    }
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
    }
  }
  
  hideErrorAlert() {
    if (this.hasErrorAlertTarget) {
      this.errorAlertTarget.classList.add('d-none')
      this.hideAllErrorMessages()
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
    } else {
      // Fallback to default message if specific type not found
      const defaultElement = targetArray.find(element => 
        element.getAttribute('data-error-type') === 'default_message'
      )
      if (defaultElement) {
        defaultElement.classList.remove('d-none')
      }
    }
  }
  
  disconnect() {
    // Remove the widget if it exists
    if (this.widgetId !== null && window.turnstile) {
      try {
        window.turnstile.remove(this.widgetId)
        this.widgetId = null
      } catch (error) {
        // Silent error handling
      }
    }
    
    // Clean up Turnstile observer if still active
    if (this.turnstileObserver) {
      this.turnstileObserver.disconnect()
      this.turnstileObserver = null
    }
    
    // Clear initialization flag so it can be re-initialized if the element comes back
    if (this.element) {
      delete this.element.dataset.turnstileInitialized
    }
    
    // Note: We don't delete global callbacks as they might be reused on reconnect
    // The callbacks reference 'controller' which will update to the new instance
  }
}