const fs = require('fs');
const path = require('path');

const scenesDir = path.join(__dirname, 'scenes');

function generateUid() {
    return 'uid://' + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}

fs.readdirSync(scenesDir).forEach(file => {
    if (file.endsWith('.tscn')) {
        const filePath = path.join(scenesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');

        if (!content.includes('uid="uid://')) {
            content = content.replace(/\[gd_scene load_steps=(\d+) format=3\]/, (match, steps) => {
                return `[gd_scene load_steps=${steps} format=3 uid="${generateUid()}"]`;
            });
        }
        
        fs.writeFileSync(filePath, content);
    }
});
