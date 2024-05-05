const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

let interval = null;

// Function to perform glitch effect
function performGlitchEffect(element, callback) {
  let iteration = 0;
  
  clearInterval(interval);
  
  interval = setInterval(() => {
    element.innerText = element.innerText
      .split("")
      .map((letter, index) => {
        if(index < iteration) {
          return element.dataset.value[index];
        }
      
        return letters[Math.floor(Math.random() * 26)]
      })
      .join("");
    
    if(iteration >= element.dataset.value.length){ 
      clearInterval(interval);
      callback();
    }
    
    iteration += 1 / 3;
  }, 30);
}

// Event listener for mouseover on the h1 element
document.querySelector("h1").onmouseover = event => {  
  // Perform glitch effect
  performGlitchEffect(event.target, () => {
    // Redirect to /selection after glitch animation completes
    window.location.href = "/selection";
  });
}

// document.querySelector("h1").onmouseover = event => {  
//   let iteration = 0;
  
//   clearInterval(interval);
  
//   interval = setInterval(() => {
//     event.target.innerText = event.target.innerText
//       .split("")
//       .map((letter, index) => {
//         if(index < iteration) {
//           return event.target.dataset.value[index];
//         }
      
//         return letters[Math.floor(Math.random() * 26)]
//       })
//       .join("");
    
//     if(iteration >= event.target.dataset.value.length){ 
//       clearInterval(interval);
//     }
    
//     iteration += 1 / 3;
//   }, 30);
// }