import { Hook } from "phoenix_live_view";

const SELECTOR = {
  textarea: "[data-type*='WysiwygEditor.textarea']",
} as const;

const CLASSES = {
  toolbar: "absolute z-50 flex gap-1 p-2 bg-white border border-gray-300 rounded-lg shadow-lg",
  button: "px-3 py-1 text-sm rounded hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500",
  buttonActive: "bg-blue-500 text-white hover:bg-blue-600",
  buttonInactive: "bg-gray-50 text-gray-700 border border-gray-200",
} as const;

interface SelectionInfo {
  start: number;
  end: number;
  selectedText: string;
  hasSelection: boolean;
}

const getSelection = (textarea: HTMLTextAreaElement): SelectionInfo => {
  const start = textarea.selectionStart;
  const end = textarea.selectionEnd;
  return {
    start,
    end,
    selectedText: textarea.value.substring(start, end),
    hasSelection: start !== end,
  };
};

const setSelection = (textarea: HTMLTextAreaElement, start: number, end: number) => {
  textarea.focus();
  textarea.setSelectionRange(start, end);
};

const insertText = (textarea: HTMLTextAreaElement, newText: string, start: number, end: number) => {
  const beforeText = textarea.value.substring(0, start);
  const afterText = textarea.value.substring(end);
  
  textarea.value = beforeText + newText + afterText;
  
  // Trigger input event to notify LiveView of changes
  const inputEvent = new Event('input', { bubbles: true });
  textarea.dispatchEvent(inputEvent);
  
  return newText.length;
};

const toggleFormat = (textarea: HTMLTextAreaElement, startTag: string, endTag: string) => {
  const selection = getSelection(textarea);
  const { start, end, selectedText } = selection;
  
  if (selectedText.length === 0) {
    // No selection, just insert the tags and position cursor between them
    const newText = startTag + endTag;
    insertText(textarea, newText, start, end);
    setSelection(textarea, start + startTag.length, start + startTag.length);
  } else {
    // Check if selection is already wrapped with the tags
    const beforeSelection = textarea.value.substring(start - startTag.length, start);
    const afterSelection = textarea.value.substring(end, end + endTag.length);
    
    if (beforeSelection === startTag && afterSelection === endTag) {
      // Remove existing formatting
      const beforeText = textarea.value.substring(0, start - startTag.length);
      const afterText = textarea.value.substring(end + endTag.length);
      textarea.value = beforeText + selectedText + afterText;
      
      // Trigger input event
      const inputEvent = new Event('input', { bubbles: true });
      textarea.dispatchEvent(inputEvent);
      
      setSelection(textarea, start - startTag.length, end - startTag.length);
    } else {
      // Add formatting
      const newText = startTag + selectedText + endTag;
      insertText(textarea, newText, start, end);
      setSelection(textarea, start + startTag.length, start + startTag.length + selectedText.length);
    }
  }
};

const isFormatActive = (textarea: HTMLTextAreaElement, startTag: string, endTag: string): boolean => {
  const selection = getSelection(textarea);
  const { start, end } = selection;
  
  const beforeSelection = textarea.value.substring(start - startTag.length, start);
  const afterSelection = textarea.value.substring(end, end + endTag.length);
  
  return beforeSelection === startTag && afterSelection === endTag;
};

const createFloatingToolbar = (): HTMLElement => {
  const toolbar = document.createElement('div');
  toolbar.className = CLASSES.toolbar;
  toolbar.style.display = 'none';
  
  // Bold button  
  const boldBtn = document.createElement('button');
  boldBtn.type = 'button';
  boldBtn.innerHTML = '<strong>B</strong>';
  boldBtn.title = 'Bold (Ctrl+B)';
  boldBtn.className = `${CLASSES.button} ${CLASSES.buttonInactive}`;
  boldBtn.setAttribute('data-format', 'bold');
  
  // Italic button
  const italicBtn = document.createElement('button');
  italicBtn.type = 'button';
  italicBtn.innerHTML = '<em>I</em>';
  italicBtn.title = 'Italic (Ctrl+I)';
  italicBtn.className = `${CLASSES.button} ${CLASSES.buttonInactive}`;
  italicBtn.setAttribute('data-format', 'italic');
  
  toolbar.appendChild(boldBtn);
  toolbar.appendChild(italicBtn);
  
  document.body.appendChild(toolbar);
  return toolbar;
};

const positionToolbar = (toolbar: HTMLElement, textarea: HTMLTextAreaElement) => {
  const selection = getSelection(textarea);
  if (!selection.hasSelection) {
    toolbar.style.display = 'none';
    return;
  }
  
  // Get textarea bounds
  const textareaRect = textarea.getBoundingClientRect();
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
  const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
  
  // Calculate approximate position of selection
  // This is a simplified approach - for better positioning, we'd need more complex calculations
  const x = textareaRect.left + scrollLeft + (textareaRect.width / 2);
  const y = textareaRect.top + scrollTop - toolbar.offsetHeight - 10;
  
  toolbar.style.left = `${x - toolbar.offsetWidth / 2}px`;
  toolbar.style.top = `${y}px`;
  toolbar.style.display = 'flex';
};

const updateButtonStates = (toolbar: HTMLElement, textarea: HTMLTextAreaElement) => {
  const boldBtn = toolbar.querySelector('[data-format="bold"]') as HTMLButtonElement;
  const italicBtn = toolbar.querySelector('[data-format="italic"]') as HTMLButtonElement;
  
  if (!boldBtn || !italicBtn) return;
  
  // Update bold button
  if (isFormatActive(textarea, '\\textbf{', '}')) {
    boldBtn.className = `${CLASSES.button} ${CLASSES.buttonActive}`;
  } else {
    boldBtn.className = `${CLASSES.button} ${CLASSES.buttonInactive}`;
  }
  
  // Update italic button
  if (isFormatActive(textarea, '\\textit{', '}')) {
    italicBtn.className = `${CLASSES.button} ${CLASSES.buttonActive}`;
  } else {
    italicBtn.className = `${CLASSES.button} ${CLASSES.buttonInactive}`;
  }
};

const showToolbar = (toolbar: HTMLElement, textarea: HTMLTextAreaElement) => {
  const selection = getSelection(textarea);
  if (selection.hasSelection) {
    positionToolbar(toolbar, textarea);
    updateButtonStates(toolbar, textarea);
  } else {
    toolbar.style.display = 'none';
  }
};

const hideToolbar = (toolbar: HTMLElement) => {
  toolbar.style.display = 'none';
};

export default (): Hook => ({
  mounted() {
    const textarea = this.el.querySelector(SELECTOR.textarea) as HTMLTextAreaElement;
    if (!textarea) return;
    
    // Create floating toolbar
    const toolbar = createFloatingToolbar();
    
    // Store reference for cleanup
    (this as any).toolbar = toolbar;
    
    let hideTimeout: number;
    
    // Button click handlers
    toolbar.addEventListener('click', (e) => {
      const target = e.target as HTMLElement;
      const button = target.closest('[data-format]') as HTMLButtonElement;
      if (!button) return;
      
      e.preventDefault();
      e.stopPropagation();
      
      const format = button.getAttribute('data-format');
      if (format === 'bold') {
        toggleFormat(textarea, '\\textbf{', '}');
      } else if (format === 'italic') {
        toggleFormat(textarea, '\\textit{', '}');
      }
      
      updateButtonStates(toolbar, textarea);
    });
    
    // Keyboard shortcuts
    textarea.addEventListener('keydown', (e) => {
      if (e.ctrlKey || e.metaKey) {
        switch (e.key.toLowerCase()) {
          case 'b':
            e.preventDefault();
            toggleFormat(textarea, '\\textbf{', '}');
            updateButtonStates(toolbar, textarea);
            break;
          case 'i':
            e.preventDefault();
            toggleFormat(textarea, '\\textit{', '}');
            updateButtonStates(toolbar, textarea);
            break;
        }
      }
    });
    
    // Show toolbar on text selection
    const handleSelectionChange = () => {
      clearTimeout(hideTimeout);
      setTimeout(() => {
        if (document.activeElement === textarea) {
          showToolbar(toolbar, textarea);
        }
      }, 10);
    };
    
    textarea.addEventListener('mouseup', handleSelectionChange);
    textarea.addEventListener('keyup', handleSelectionChange);
    
    // Hide toolbar when clicking outside or losing focus
    document.addEventListener('click', (e) => {
      if (!toolbar.contains(e.target as Node) && e.target !== textarea) {
        hideTimeout = setTimeout(() => hideToolbar(toolbar), 100);
      }
    });
    
    textarea.addEventListener('blur', () => {
      hideTimeout = setTimeout(() => hideToolbar(toolbar), 200);
    });
    
    // Show toolbar when focusing if there's a selection
    textarea.addEventListener('focus', () => {
      clearTimeout(hideTimeout);
      setTimeout(() => showToolbar(toolbar, textarea), 10);
    });
  },
  
  updated() {
    const textarea = this.el.querySelector(SELECTOR.textarea) as HTMLTextAreaElement;
    const toolbar = (this as any).toolbar;
    if (textarea && toolbar) {
      updateButtonStates(toolbar, textarea);
    }
  },
  
  destroyed() {
    // Clean up floating toolbar
    const toolbar = (this as any).toolbar;
    if (toolbar && toolbar.parentNode) {
      toolbar.parentNode.removeChild(toolbar);
    }
  },
});