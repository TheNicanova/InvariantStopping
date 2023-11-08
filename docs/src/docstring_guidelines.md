# Julia Docstring Best Practices

When documenting functions, types, and other objects in our package, follow these best practices:

## 1. **Placement**
Place the docstring immediately before the object it documents, such as a function, type, or macro.

## 2. **Usage Statement**
- Start with a brief usage statement showing the function signature.
- The usage statement should be indented and set apart from the main description.

## 3. **Description**
Provide a detailed description of the function or type, elaborating on its purpose, behavior, and any relevant context.

## 4. **Arguments & Returns**
- Organize details under `# Arguments` and `# Returns` sections.
- For each argument, start with its name, followed by a colon, and then its description.
- Describe the return value in a similar manner.

## 5. **Examples**
- Offer practical examples to illustrate and clarify usage.
- Enclose examples within a Julia code block.

## 6. **Additional Sections**
For objects of greater complexity, consider adding sections like `# Notes`, `# References`, or `# See Also`.

## 7. **Markdown Support**
Use Markdown formatting for clarity and emphasis. This includes **bold**, *italic*, and [links](#).




