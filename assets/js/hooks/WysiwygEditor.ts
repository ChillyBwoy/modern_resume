import { Hook } from "phoenix_live_view";

const SELECTOR = {
  textarea: "[data-type='WysiwygEditor.textarea']",
  toolbar: "[data-type='WysiwygEditor.toolbar']",
  boldBtn: "[data-type='WysiwygEditor.bold']",
  italicBtn: "[data-type='WysiwygEditor.italic']",
} as const;

const CLASSES = {
  active: "bg-primary text-white",
  inactive: "bg-gray-200 text-gray-700",
} as const;

interface SelectionInfo {
  start: number;
  end: number;
  selectedText: string;
}

const getSelection = (textarea: HTMLTextAreaElement): SelectionInfo => {
  return {
    start: textarea.selectionStart,
    end: textarea.selectionEnd,
    selectedText: textarea.value.substring(textarea.selectionStart, textarea.selectionEnd),
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
    const insertedLength = insertText(textarea, newText, start, end);
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
      const insertedLength = insertText(textarea, newText, start, end);
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

const updateButtonStates = (el: HTMLElement) => {
  const textarea = el.querySelector(SELECTOR.textarea) as HTMLTextAreaElement;
  const boldBtn = el.querySelector(SELECTOR.boldBtn) as HTMLButtonElement;
  const italicBtn = el.querySelector(SELECTOR.italicBtn) as HTMLButtonElement;
  
  if (!textarea || !boldBtn || !italicBtn) return;
  
  // Update bold button
  if (isFormatActive(textarea, '\\textbf{', '}')) {
    boldBtn.classList.remove(...CLASSES.inactive.split(' '));
    boldBtn.classList.add(...CLASSES.active.split(' '));
  } else {
    boldBtn.classList.remove(...CLASSES.active.split(' '));
    boldBtn.classList.add(...CLASSES.inactive.split(' '));
  }
  
  // Update italic button
  if (isFormatActive(textarea, '\\textit{', '}')) {
    italicBtn.classList.remove(...CLASSES.inactive.split(' '));
    italicBtn.classList.add(...CLASSES.active.split(' '));
  } else {
    italicBtn.classList.remove(...CLASSES.active.split(' '));
    italicBtn.classList.add(...CLASSES.inactive.split(' '));
  }
};

export default (): Hook => ({
  mounted() {
    const textarea = this.el.querySelector(SELECTOR.textarea) as HTMLTextAreaElement;
    const boldBtn = this.el.querySelector(SELECTOR.boldBtn) as HTMLButtonElement;
    const italicBtn = this.el.querySelector(SELECTOR.italicBtn) as HTMLButtonElement;
    
    if (!textarea || !boldBtn || !italicBtn) return;
    
    // Bold button click handler
    boldBtn.addEventListener('click', (e) => {
      e.preventDefault();
      toggleFormat(textarea, '\\textbf{', '}');
      updateButtonStates(this.el);
    });
    
    // Italic button click handler
    italicBtn.addEventListener('click', (e) => {
      e.preventDefault();
      toggleFormat(textarea, '\\textit{', '}');
      updateButtonStates(this.el);
    });
    
    // Keyboard shortcuts
    textarea.addEventListener('keydown', (e) => {
      if (e.ctrlKey || e.metaKey) {
        switch (e.key.toLowerCase()) {
          case 'b':
            e.preventDefault();
            toggleFormat(textarea, '\\textbf{', '}');
            updateButtonStates(this.el);
            break;
          case 'i':
            e.preventDefault();
            toggleFormat(textarea, '\\textit{', '}');
            updateButtonStates(this.el);
            break;
        }
      }
    });
    
    // Update button states on selection change
    textarea.addEventListener('selectionchange', () => {
      updateButtonStates(this.el);
    });
    
    textarea.addEventListener('keyup', () => {
      updateButtonStates(this.el);
    });
    
    textarea.addEventListener('click', () => {
      updateButtonStates(this.el);
    });
    
    // Initial button state update
    updateButtonStates(this.el);
  },
  
  updated() {
    updateButtonStates(this.el);
  },
});