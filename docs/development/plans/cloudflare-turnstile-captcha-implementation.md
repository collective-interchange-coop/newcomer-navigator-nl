# Cloudflare Turnstile Captcha Implementation Plan

**Feature**: Integration of Cloudflare Turnstile captcha protection for user registration
**Target Application**: New to NL (host app)
**Engine**: Better Together Community Engine
**Date**: October 28, 2025
**Development Approach**: Test-Driven Development (TDD)

## Overview

This plan implements Cloudflare Turnstile captcha protection for user registrations using a hook-based architecture. The Community Engine will provide integration hooks while the host application implements the actual captcha validation, maintaining clean separation of concerns.

## Technical Architecture

- **Hook Pattern**: Engine provides `validate_captcha_if_enabled?` hook for host app customization
- **Host Override**: New-to-NL overrides registration controller and view to implement Turnstile
- **Gem Integration**: Uses `cloudflare-turnstile-rails` gem for seamless Rails integration
- **Accessibility**: WCAG AA compliant implementation with proper ARIA labels
- **Hotwire Compatible**: Leverages gem's built-in Turbo and Turbo Streams support

## Implementation Steps

### Phase 1: Foundation Setup
- [x] **Step 1: Add Turnstile Gem to Host App** ✅
  - Add `cloudflare-turnstile-rails` gem to new-to-nl Gemfile
  - Run `bundle install` to install dependencies
  - Verify gem installation and version compatibility
  - **Test**: Confirm gem loads without errors

- [x] **Step 2: Generate Turnstile Configuration** ✅
  - Run `rails generate cloudflare_turnstile:install` in host app
  - Create initializer with environment variable configuration
  - Set up dummy keys for development/testing
  - **Test**: Verify initializer loads with proper configuration

- [x] **Step 3: Add Environment Variables** ✅
  - Configure `CLOUDFLARE_TURNSTILE_SITE_KEY` in environment files
  - Configure `CLOUDFLARE_TURNSTILE_SECRET_KEY` in environment files  
  - Use Cloudflare dummy keys for development/testing
  - Document production key setup process
  - **Test**: Confirm environment variables are accessible

### Phase 2: Engine Integration Hooks

- [x] **Step 4: Create Turnstile Hook in Engine** ✅
  - Add `validate_captcha_if_enabled?` method to registrations controller
  - Design hook to be overridable by host applications
  - Ensure hook doesn't break existing functionality when unused
  - Add before_action hook integration point
  - **Test**: Verify engine still works without captcha implementation

### Phase 3: Host Application Implementation

- [x] **Step 5: Create Host Registration Controller** ✅
  - Override `BetterTogether::Users::RegistrationsController` in host app
  - Implement Turnstile validation using `valid_turnstile?` method
  - Handle validation errors with proper user feedback
  - Maintain all existing registration functionality
  - **Test**: Test both successful and failed captcha validation

- [x] **Step 6: Override Registration View in Host** ✅
  - Create custom registration view in host app views directory
  - Add `<%= cloudflare_turnstile_tag %>` before submit button
  - Configure widget theme and language to match app design
  - Ensure accessibility compliance with proper labels
  - **Test**: Verify widget renders correctly in different scenarios

- [ ] **Step 7: Update I18n Translations**
  - Add captcha error message translations for en, es, fr locales
  - Add captcha field labels and help text
  - Include accessibility-focused message content
  - Follow existing translation key patterns
  - **Test**: Verify all translations display correctly

### Phase 4: Testing & Validation

- [ ] **Step 8: Create Comprehensive Test Suite**
  - Write feature specs for registration with captcha
  - Test successful registration with valid captcha
  - Test failed registration with invalid captcha  
  - Test registration without captcha token
  - Test accessibility compliance
  - Use Cloudflare dummy keys for reliable test scenarios
  - **Test**: Achieve >95% code coverage for new functionality

- [ ] **Step 9: Security Verification**
  - Run `bin/dc-run bundle exec brakeman --quiet --no-pager`
  - Address any high-confidence security vulnerabilities
  - Verify no unsafe reflection or SQL injection risks
  - Review captcha bypass possibilities
  - **Test**: Confirm clean Brakeman scan

- [ ] **Step 10: Documentation Update**
  - Document captcha setup process for future deployments
  - Add troubleshooting guide for common issues
  - Document dummy keys usage for testing
  - Create production deployment checklist
  - **Test**: Verify documentation completeness

### Phase 5: Production Readiness

- [ ] **Step 11: Production Environment Setup**
  - Obtain production Cloudflare Turnstile keys
  - Configure production environment variables
  - Test captcha in staging environment
  - Verify performance impact is minimal
  - **Test**: Complete end-to-end production testing

- [ ] **Step 12: Monitoring & Observability**
  - Add logging for captcha validation events
  - Monitor captcha success/failure rates  
  - Set up alerts for captcha service outages
  - Document operational procedures
  - **Test**: Verify monitoring captures expected events

## Test-Driven Development Guidelines

### Testing Strategy
1. **Write Tests First**: Create failing tests before implementing features
2. **Red-Green-Refactor**: Follow TDD cycle religiously  
3. **Comprehensive Coverage**: Test happy path, edge cases, and error conditions
4. **Integration Tests**: Focus on full user workflows over unit tests
5. **Accessibility Testing**: Verify WCAG AA compliance in feature specs

### Test Types Required
- **Feature Specs**: End-to-end registration workflows
- **Request Specs**: Controller behavior and response handling  
- **System Specs**: JavaScript widget behavior and form interactions
- **Integration Specs**: Engine hook integration functionality
- **Security Specs**: Captcha bypass prevention

### Dummy Keys for Testing
```
Site Keys:
- Always passes (visible): 1x00000000000000000000AA
- Always blocks (visible): 2x00000000000000000000AB  
- Always passes (invisible): 1x00000000000000000000BB

Secret Keys:
- Always passes: 1x0000000000000000000000000000000AA
- Always fails: 2x0000000000000000000000000000000AA
```

## Acceptance Criteria

### End User Experience
- [ ] Registration form displays captcha widget seamlessly
- [ ] Captcha integrates with existing form validation
- [ ] Error messages are clear and actionable
- [ ] Form submission works with JavaScript disabled (graceful degradation)
- [ ] Widget respects user's theme preference (light/dark)

### Security Requirements  
- [ ] Bot registration attempts are blocked effectively
- [ ] Captcha cannot be bypassed through direct API calls
- [ ] No new security vulnerabilities introduced
- [ ] User data remains protected during captcha validation
- [ ] Rate limiting works in conjunction with captcha

### Technical Requirements
- [ ] Zero breaking changes to existing registration flow
- [ ] Performance impact < 100ms additional load time
- [ ] Works with Turbo and Turbo Streams
- [ ] Compatible with existing accessibility tools
- [ ] Graceful fallback when captcha service unavailable

### Operational Requirements
- [ ] Clear deployment documentation available
- [ ] Monitoring and alerting configured
- [ ] Rollback procedure documented and tested
- [ ] Support team training materials created
- [ ] Production troubleshooting guide available

## Risk Mitigation

### Technical Risks
- **Captcha Service Outage**: Implement graceful degradation mode
- **Performance Impact**: Load testing and optimization
- **Accessibility Issues**: Comprehensive screen reader testing
- **Integration Conflicts**: Thorough compatibility testing

### Security Risks  
- **Captcha Bypass**: Multiple validation layers and monitoring
- **False Positives**: Provide clear user guidance and support
- **Key Exposure**: Secure environment variable management
- **Bot Evolution**: Regular captcha effectiveness review

## Success Metrics

- **Security**: >95% reduction in automated registration attempts
- **Performance**: <100ms additional page load time
- **Accessibility**: 100% WCAG AA compliance score  
- **User Experience**: <5% increase in registration abandonment
- **Reliability**: 99.9% captcha service uptime

## Implementation Timeline

- **Phase 1-2**: Foundation (Days 1-2)
- **Phase 3**: Host Implementation (Days 3-4)
- **Phase 4**: Testing & Validation (Days 5-6)  
- **Phase 5**: Production Readiness (Days 7-8)

## Dependencies

- Cloudflare Turnstile service availability
- Better Together Community Engine v0.8.1+
- Rails 7.2+ compatibility
- Production Cloudflare account setup
- DevOps team coordination for environment variables

## Rollback Plan

1. **Immediate**: Feature flag to disable captcha validation
2. **Short-term**: Revert to previous registration controller
3. **Full rollback**: Remove gem and restore original views
4. **Database**: No schema changes, no rollback needed

---

**Document Status**: ✅ Initial Plan Created  
**Next Review**: After Phase 1 Completion  
**Last Updated**: October 28, 2025