const fs = require('fs');
const path = require('path');

const scenesDir = path.join(__dirname, 'scenes');

fs.readdirSync(scenesDir).forEach(file => {
    if (file.endsWith('.tscn')) {
        const filePath = path.join(scenesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');

        // Extract ext_resources and sub_resources
        const extMatch = content.match(/\[ext_resource/g);
        const subMatch = content.match(/\[sub_resource/g);
        
        const extCount = extMatch ? extMatch.length : 0;
        const subCount = subMatch ? subMatch.length : 0;
        
        const steps = extCount + subCount + 1;
        
        content = content.replace(/\[gd_scene load_steps=\d+ format=3\]/, `[gd_scene load_steps=${steps} format=3]`);
        
        // Also ensure IDs are simple integers if we're at it, but maybe safer to just fix load_steps first
        
        fs.writeFileSync(filePath, content);
    }
});

console.log("Fixed load_steps.");
