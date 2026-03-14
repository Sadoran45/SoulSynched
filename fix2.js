const fs = require('fs');
const path = require('path');

const scenesDir = path.join(__dirname, 'scenes');

fs.readdirSync(scenesDir).forEach(file => {
    if (file.endsWith('.tscn')) {
        const filePath = path.join(scenesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');

        // Fix the path=" bug
        content = content.replace(/type="([^"]+)"res:\/\//g, 'type="$1" path="res://');
        
        fs.writeFileSync(filePath, content);
    }
});

console.log("Fixed path bugs.");
