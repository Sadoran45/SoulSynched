const fs = require('fs');
const path = require('path');

const scenesDir = path.join(__dirname, 'scenes');

fs.readdirSync(scenesDir).forEach(file => {
    if (file.endsWith('.tscn')) {
        const filePath = path.join(scenesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');

        // Fix invalid uids
        content = content.replace(/ uid="[^u][^i][^d][^:]?[^/][^/][^"]*"/g, '');
        content = content.replace(/ uid="[0-9]+[^"]*"/g, '');
        content = content.replace(/ uid="[^"]*"/g, (match) => {
            if (match.includes('uid://')) return match;
            return '';
        });

        // Fix Color with 3 args
        content = content.replace(/Color\(([^,]+),\s*([^,]+),\s*([^,)]+)\)/g, 'Color($1, $2, $3, 1)');
        
        fs.writeFileSync(filePath, content);
    }
});

console.log("Fixed files.");
