const fs = require('fs');
const path = require('path');

const scenesDir = path.join(__dirname, 'scenes');

fs.readdirSync(scenesDir).forEach(file => {
    if (file.endsWith('.tscn')) {
        const filePath = path.join(scenesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');

        // Map old IDs to new integer IDs
        const extResources = [];
        const subResources = [];
        
        // Match [ext_resource type="..." path="..." id="..."]
        const extRegex = /\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]/g;
        let match;
        let i = 1;
        while ((match = extRegex.exec(content)) !== null) {
            extResources.push({ type: match[1], path: match[2], oldId: match[3], newId: i++ });
        }
        
        // Match [sub_resource type="..." id="..."]
        const subRegex = /\[sub_resource type="([^"]+)" id="([^"]+)"\]/g;
        let j = 1;
        while ((match = subRegex.exec(content)) !== null) {
            subResources.push({ type: match[1], oldId: match[2], newId: j++ });
        }
        
        // Replace ext_resource definitions
        extResources.forEach(res => {
            const oldDef = `[ext_resource type="${res.type}" path="${res.path}" id="${res.oldId}"]`;
            const newDef = `[ext_resource type="${res.type}" path="${res.path}" id="${res.newId}"]`;
            content = content.split(oldDef).join(newDef);
        });
        
        // Replace sub_resource definitions
        subResources.forEach(res => {
            const oldDef = `[sub_resource type="${res.type}" id="${res.oldId}"]`;
            const newDef = `[sub_resource type="${res.type}" id="${res.newId}"]`;
            content = content.split(oldDef).join(newDef);
        });
        
        // Replace ExtResource usages
        extResources.forEach(res => {
            content = content.split(`ExtResource("${res.oldId}")`).join(`ExtResource("${res.newId}")`);
            // Also handle numeric ones just in case
            content = content.split(`ExtResource(${res.oldId})`).join(`ExtResource("${res.newId}")`);
        });
        
        // Replace SubResource usages
        subResources.forEach(res => {
            content = content.split(`SubResource("${res.oldId}")`).join(`SubResource("${res.newId}")`);
            content = content.split(`SubResource(${res.oldId})`).join(`SubResource("${res.newId}")`);
        });
        
        // Fix load_steps
        const steps = extResources.length + subResources.length + 1;
        content = content.replace(/\[gd_scene load_steps=\d+ format=3\]/, `[gd_scene load_steps=${steps} format=3]`);

        fs.writeFileSync(filePath, content);
    }
});
