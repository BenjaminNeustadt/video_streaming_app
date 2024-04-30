// Set up scene, camera, and renderer
var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera(65, window.innerWidth / window.innerHeight, 1, 100);
var renderer = new THREE.WebGLRenderer();
renderer.setClearColor(0xffffff);
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Create a group to hold all the cubes
var cubesGroup = new THREE.Group();

// Function to check if a cube is central on a face
function isCentralCube(x, y, z, size) {
    return Math.abs(x) === size && Math.abs(y) === 0 && Math.abs(z) <= 0.25 ||
        Math.abs(y) === size && Math.abs(x) === 0 && Math.abs(z) <= 0.25 ||
        Math.abs(z) === size && Math.abs(x) === 0 && Math.abs(y) <= 0.25;
}

// Create cubes and add them to the group
var size = 2;
var gap = 0.1;
for (var x = -size; x <= size; x += (1 + gap)) {
    for (var y = -size; y <= size; y += (1 + gap)) {
        for (var z = -size; z <= size; z += (1 + gap)) {
            var cubeGeometry = new THREE.BoxGeometry(0.5, 0.5, 0.5);
            var cubeMaterial = new THREE.MeshStandardMaterial({ color: 0x800000 });
            var cube = new THREE.Mesh(cubeGeometry, cubeMaterial);
            cube.position.set(x, y, z);
            cubesGroup.add(cube); // Add each cube to the group

            // Apply pulsating effect to central cubes
            if (isCentralCube(x, y, z, size)) {
                cube.originalScale = cube.scale.clone(); // Store original scale
                cube.addEventListener("mouseenter", function () {
                    var targetScale = 1.2; // Define the target scale for pulsating effect
                    TweenMax.to(this.scale, 0.5, { x: targetScale, y: targetScale, z: targetScale });
                });

                cube.addEventListener("mouseleave", function () {
                    TweenMax.to(this.scale, 0.5, { x: this.originalScale.x, y: this.originalScale.y, z: this.originalScale.z });
                });
            }
        }
    }
}

scene.add(cubesGroup); // Add the group to the scene

// Set camera position
camera.position.set(0, 0, 8);

// Define animation function
var animate = function () {
    requestAnimationFrame(animate);

    // Rotate the group around its center
    cubesGroup.rotation.x += 0.001;
    cubesGroup.rotation.y += 0.01;

    renderer.render(scene, camera);
};

// Update renderer size
window.addEventListener("resize", function () {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
});

animate();
