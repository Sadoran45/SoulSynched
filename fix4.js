const fs = require('fs');
const path = require('path');

const scenesDir = path.join(__dirname, 'scenes');

fs.readdirSync(scenesDir).forEach(file => {
    if (file.endsWith('.tscn')) {
        const filePath = path.join(scenesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');

        // Fix load_steps
        const extMatch = content.match(/\[ext_resource/g);
        const subMatch = content.match(/\[sub_resource/g);
        const steps = (extMatch ? extMatch.length : 0) + (subMatch ? subMatch.length : 0) + 1;
        content = content.replace(/\[gd_scene load_steps=\d+ format=3\]/, `[gd_scene load_steps=${steps} format=3]`);

        // Ensure Color(r, g, b) has 4 args
        content = content.replace(/Color\(([^,]+),\s*([^,]+),\s*([^,)]+)\)/g, 'Color($1, $2, $3, 1)');
        
        fs.writeFileSync(filePath, content);
    }
});
