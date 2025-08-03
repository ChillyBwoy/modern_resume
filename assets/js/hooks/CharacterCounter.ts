export default () => ({
  mounted() {
    this.updateCounter();
    this.el.addEventListener("input", () => this.updateCounter());
    this.el.addEventListener("keyup", () => this.updateCounter());
    this.el.addEventListener("paste", () => {
      // Delay to allow paste content to be processed
      setTimeout(() => this.updateCounter(), 10);
    });
  },

  updated() {
    this.updateCounter();
  },

  updateCounter() {
    const currentLength = this.el.value.length;
    const maxLength = parseInt(this.el.getAttribute("maxlength") || "0");
    const counterId = `${this.el.id}-counter-current`;
    const counterElement = document.getElementById(counterId);
    
    if (counterElement && maxLength > 0) {
      counterElement.textContent = currentLength.toString();
      
      // Add visual feedback when approaching limit
      const counterContainer = document.getElementById(`${this.el.id}-counter`);
      if (counterContainer) {
        const percentage = (currentLength / maxLength) * 100;
        
        if (percentage >= 90) {
          counterContainer.classList.remove("text-gray-500", "text-amber-600");
          counterContainer.classList.add("text-red-600");
        } else if (percentage >= 75) {
          counterContainer.classList.remove("text-gray-500", "text-red-600");
          counterContainer.classList.add("text-amber-600");
        } else {
          counterContainer.classList.remove("text-red-600", "text-amber-600");
          counterContainer.classList.add("text-gray-500");
        }
      }
    }
  }
});