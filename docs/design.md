# Design Document
## TestVerse

Visual and UX design reference for a clean, low-distraction interface â€” important for an exam-taking app where clarity beats decoration.

---

## 1. Design Principles

- **Clarity over decoration.** A student under time pressure should never be confused about what to click.
- **No surprises during a test.** Nothing on `takeTest.jsp` should move, resize, or pop up unexpectedly â€” it breaks focus and risks losing time.
- **Consistent chrome.** Header/nav stays identical across all pages so the app feels like one system, not disconnected screens.
- **Obvious system state.** Logged-in user's name/role always visible; timer always visible during a test; success/error messages always in the same location.

---

## 2. Color Palette

| Role | Color | Hex | Usage |
|---|---|---|---|
| Primary | Deep Blue | `#1E3A8A` | Header bar, primary buttons, links |
| Secondary | Slate Gray | `#475569` | Body text, secondary buttons |
| Success | Green | `#16A34A` | Success messages, pass/good score |
| Danger | Red | `#DC2626` | Errors, timer under 1 minute, delete actions |
| Warning | Amber | `#D97706` | Timer under 5 minutes, caution notices |
| Background | Off-white | `#F8FAFC` | Page background |
| Surface | White | `#FFFFFF` | Cards, forms, tables |
| Border | Light Gray | `#E2E8F0` | Table borders, input borders |

Keep it to this palette â€” avoid introducing new colors per page.

---

## 3. Typography

- **Font stack:** `'Segoe UI', Arial, sans-serif` (safe, widely available, readable)
- **Headings:** Bold, Primary Blue (`#1E3A8A`)
- **Body text:** Slate Gray (`#475569`), 16px base size for readability during exams
- **Timer display:** Larger, bold, monospace-style number so digits don't jitter/reflow as they count down (e.g., `font-variant-numeric: tabular-nums`)

---

## 4. Layout Structure (shared across pages)

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  HEADER: Logo/Title | [User: Name (Role)] | Logout    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                          â”‚
â”‚                   PAGE CONTENT (card)                   â”‚
â”‚                                                          â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  FOOTER: (optional) course/project name, small text     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

- Max content width ~900px, centered â€” avoids overly wide lines of text/forms on large screens.
- Content sits inside a white "card" (`box-shadow`, rounded corners) against the off-white page background.

---

## 5. Page-by-Page Notes

### 5.1 `login.jsp` / `register.jsp`
- Centered single card, no header/nav (user isn't authenticated yet)
- Fields stacked vertically, full-width inputs
- Primary button full-width, clearly labeled ("Login" / "Register")
- Error message appears directly above the form, red text on light red background

### 5.2 `adminDashboard.jsp`
- Simple menu/card grid: "Manage Questions", "Create Test", "View Reports"
- Each card links to its respective page â€” no deep nesting of menus

### 5.3 `addQuestion.jsp`
- Question text as a textarea (not single-line input)
- Four option fields labeled Aâ€“D
- Radio buttons to mark which option is correct
- Table below the form listing existing questions with Edit/Delete actions

### 5.4 `createTest.jsp`
- Top: subject, duration (minutes), test name/marks fields
- Below: checkbox list of available questions (filterable by subject if time permits)
- Submit button disabled (or validated) until at least 1 question is selected

### 5.5 `studentDashboard.jsp`
- Card list of available tests: subject, duration, marks, a "Start Test" button
- If a test was already attempted, show "Completed â€” Score: X/Y" instead of the Start button

### 5.6 `takeTest.jsp` â€” most important screen
- **Sticky header row** showing: test subject + countdown timer (top-right, always visible while scrolling)
- One question per block: question text, then 4 radio-button options (Aâ€“D)
- Progress indicator: "Question 3 of 10 answered" or a simple progress bar
- Timer color changes: Slate Gray â†’ Amber (under 5 min) â†’ Red (under 1 min)
- Submit button fixed at the bottom; confirm dialog ("Are you sure you want to submit?") before manual submit
- On auto-submit (timer hits 0): disable all inputs immediately, show "Time's up â€” submitting..." message, then redirect to `result.jsp`

### 5.7 `result.jsp`
- Large, centered score display: `Score: 8 / 10`
- Optional: color-coded (green if â‰¥ 60%, amber 40â€“60%, red < 40%) â€” adjust thresholds as needed
- Button back to `studentDashboard.jsp`

### 5.8 `viewReport.jsp`
- Simple table: Student Name | Test | Score | Date Attempted
- Sortable by column if time permits (basic JS or just default DB ORDER BY)

---

## 6. Component Style Reference

**Buttons**
```css
.btn-primary {
  background-color: #1E3A8A;
  color: #FFFFFF;
  border-radius: 6px;
  padding: 10px 20px;
  border: none;
}
.btn-danger {
  background-color: #DC2626;
  color: #FFFFFF;
}
```

**Cards**
```css
.card {
  background: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  padding: 24px;
}
```

**Timer**
```css
.timer {
  font-size: 1.5rem;
  font-weight: bold;
  font-variant-numeric: tabular-nums;
}
.timer.warning { color: #D97706; }
.timer.danger  { color: #DC2626; }
```

---

## 7. Accessibility Notes (nice-to-have, not required for a lab project)

- Ensure sufficient contrast between text and background (the palette above meets WCAG AA for body text)
- Label all form inputs properly (`<label for="...">`) rather than placeholder-only text
- Radio button groups should be keyboard-navigable (native `<input type="radio">` already supports this â€” don't replace with custom JS-only widgets)

---

## 8. What to Deliberately Skip

Given this is a lab project, don't over-invest time in:
- Dark mode
- Animations/transitions beyond simple hover states
- Mobile-first responsive design (desktop/laptop is the expected demo environment)
- Custom icon sets â€” plain text labels are fine
