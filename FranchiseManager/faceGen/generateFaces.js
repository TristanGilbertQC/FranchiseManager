// generateFaces.js
import fs from "fs";

// First, let's check what you actually have installed
console.log("Checking installed packages...");

try {
  // Try the correct package name - it should be 'facesjs', not 'facejs'
  const { generate, faceToSvgString } = await import('facesjs');
  console.log("✅ Successfully imported facesjs");
  
  const outputDir = "./faces";
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
    console.log(`📁 Created output directory: ${outputDir}`);
  }

  // Precompute races with exact distribution
  const races = [
    ...Array(600).fill("white"),
    ...Array(200).fill("black"),
    ...Array(150).fill("brown"),
    ...Array(50).fill("asian"),
  ];

  // Shuffle the races array so they're not all in a block
  for (let i = races.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [races[i], races[j]] = [races[j], races[i]];
  }

  console.log("🎭 Starting face generation...");

  for (let i = 0; i < 1000; i++) {
    try {
      // Generate face with specific race and random gender
      const race = races[i];
      const gender = "male";
      
      const face = generate(undefined, { race, gender });
      const svgString = faceToSvgString(face);
      
      // Save to file
      const filename = `face_${String(i + 1).padStart(4, '0')}.svg`;
      const filepath = `${outputDir}/${filename}`;
      
      fs.writeFileSync(filepath, svgString);
      
      // Progress update every 50 faces
      if ((i + 1) % 50 === 0) {
        console.log(`✨ Generated ${i + 1}/1000 faces`);
      }
    } catch (error) {
      console.error(`❌ Error generating face ${i + 1}:`, error.message);
    }
  }

  console.log("🎉 Successfully generated 1000 face SVGs!");
  console.log(`📂 Files saved to: ${outputDir}/`);

} catch (importError) {
  console.error("❌ Failed to import facesjs:", importError.message);
  console.log("\n🔧 SETUP INSTRUCTIONS:");
  console.log("1. Make sure you have the correct package installed:");
  console.log("   npm uninstall facejs");
  console.log("   npm install facesjs");
  console.log("\n2. Make sure your package.json has:");
  console.log('   "type": "module"');
  console.log("\n3. Run this script with:");
  console.log("   node generateFaces.js");
}
